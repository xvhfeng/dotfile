;;; init-fold.el --- Manual marker-based code folding -*- lexical-binding: t; -*-

;;; Commentary:
;; 使用 vimish-fold 管理任意区域的手工折叠，并提供命令根据当前 major mode
;; 的注释语法插入、删除 {{{ / }}} 折叠标记。它与 treesit-fold 并行工作：
;; treesit-fold 负责语法结构，vimish-fold 负责用户明确标记的任意范围。

;;; Code:

(require 'cl-lib)
(require 'subr-x)
(require 'thingatpt)

(declare-function vimish-fold "vimish-fold" (beg end))
(declare-function vimish-fold-delete "vimish-fold" ())
(declare-function vimish-fold-from-marks "vimish-fold" ())
(declare-function vimish-fold-mode "vimish-fold" (&optional arg))
(declare-function vimish-fold-toggle "vimish-fold" ())
(declare-function vimish-fold--folds-in "vimish-fold" (beg end))
(declare-function vimish-fold--vimish-overlay-folded-p "vimish-fold" (overlay))
(declare-function treesit-node-at "treesit" (pos &optional parser-or-lang named))
(declare-function treesit-node-child-by-field-name "treesit" (node field-name))
(declare-function treesit-node-end "treesit" (node))
(declare-function treesit-node-parent "treesit" (node))
(declare-function treesit-node-start "treesit" (node))
(declare-function treesit-node-type "treesit" (node))
(declare-function treesit-parser-list "treesit" (&optional buffer))

(defvar vimish-fold-marks)

(use-package vimish-fold
  :straight t
  :commands (vimish-fold
             vimish-fold-delete
             vimish-fold-from-marks
             vimish-fold-toggle
             vimish-fold-toggle-all
             vimish-fold-unfold-all
             vimish-fold-refold-all
             vimish-fold-next-fold
             vimish-fold-previous-fold
             vimish-fold-mode)
  :hook ((prog-mode . vimish-fold-mode)
         (text-mode . vimish-fold-mode))
  :init
  ;; 源码中的默认标记为 {{{ / }}}；插件也会在打开文件时识别这些标记。
  (setq-default vimish-fold-marks '("{{{" . "}}}"))
  ;; vimish-fold 自带的标记扫描按“第一个开始 + 第一个结束”配对，不能识别
  ;; 嵌套标记；关闭它，统一使用下面的栈式配对器。
  (setq vimish-fold-find-marks-on-open nil
        vimish-fold-persist-on-saving t
        vimish-fold-dir
        (expand-file-name "runtimes/vimish-fold/" user-emacs-directory)))

(declare-function add-log-current-defun "add-log" ())

(defconst my/vimish-fold-structural-node-regexp
  (regexp-opt '("block" "body" "function" "method" "lambda" "class"
                "struct" "enum" "namespace" "module" "interface"
                "implementation" "declaration" "definition" "object"
                "statement" "array" "table" "list" "section" "element"
                "rule"))
  "Tree-sitter node type fragments suitable for point-based folding.")

(defun my/vimish-fold--multiline-bounds-p (bounds)
  "Return non-nil when BOUNDS describes a non-empty multi-line range."
  (and bounds
       (< (car bounds) (cdr bounds))
       (< (line-number-at-pos (car bounds))
          (line-number-at-pos (cdr bounds)))))

(defun my/vimish-fold--delimiter-body-bounds (beg end)
  "Return the nonblank body between delimiters at BEG and END.

BEG points at the opening delimiter and END points after the closing one."
  (save-excursion
    (goto-char (1+ beg))
    (skip-chars-forward " \t\r\n" end)
    (let ((body-beg (line-beginning-position)))
      (goto-char (max (1+ beg) (1- end)))
      (skip-chars-backward " \t\r\n" (1+ beg))
      (let ((body-end (line-end-position)))
        (and (< body-beg body-end) (cons body-beg body-end))))))

(defun my/vimish-fold--node-text (node)
  "Return NODE text without properties, or nil."
  (when node
    (string-trim
     (buffer-substring-no-properties
      (treesit-node-start node) (treesit-node-end node)))))

(defun my/vimish-fold--treesit-context-at-point ()
  "Return the nearest foldable Tree-sitter context at point."
  (when (and (require 'treesit nil t)
             (fboundp 'treesit-node-at)
             (treesit-parser-list))
    (condition-case nil
        (let ((node (treesit-node-at (point))))
          (catch 'context
            (while node
              (let* ((type (treesit-node-type node))
                     (body (treesit-node-child-by-field-name node "body"))
                     (scope (or body node))
                     (scope-beg (treesit-node-start scope))
                     (scope-end (treesit-node-end scope))
                     (delimited
                      (and (< scope-beg scope-end)
                           (memq (char-after scope-beg) '(?\{ ?\( ?\[))
                           (my/vimish-fold--delimiter-body-bounds
                            scope-beg scope-end)))
                     (bounds (or delimited (cons scope-beg scope-end)))
                     (function-p
                      (string-match-p "function\\|method\\|lambda" type))
                     (name-node
                      (treesit-node-child-by-field-name node "name"))
                     (name (if function-p
                               (my/vimish-fold--node-text name-node)
                             (car (split-string type "_" t)))))
                (when (and (string-match-p
                            my/vimish-fold-structural-node-regexp
                            type)
                           bounds
                           (my/vimish-fold--multiline-bounds-p
                            (cons scope-beg scope-end)))
                  (throw 'context
                         (list :beg (car bounds) :end (cdr bounds)
                               :kind (if function-p 'function 'block)
                               :name name))))
              (setq node (treesit-node-parent node)))))
      (error nil))))

(defun my/vimish-fold--current-defun-info ()
  "Return current defun boundaries and name, or nil."
  (require 'add-log)
  (condition-case nil
      (save-excursion
        (let ((origin (point))
              (name (add-log-current-defun))
              beg end)
          (beginning-of-defun)
          (setq beg (point))
          (goto-char origin)
          (end-of-defun)
          (setq end (point))
          (and (<= beg origin end)
               (list :beg beg :end end :name name))))
    (error nil)))

(defun my/vimish-fold--first-code-brace (beg end)
  "Return first opening code brace between BEG and END."
  (save-excursion
    (goto-char beg)
    (catch 'brace
      (while (search-forward "{" end t)
        (let ((position (1- (point))))
          (unless (nth 8 (syntax-ppss position))
            (throw 'brace position)))))))

(defun my/vimish-fold--block-name-before (position limit)
  "Return a control-flow name before POSITION, searching back to LIMIT."
  (save-excursion
    (goto-char position)
    (when (re-search-backward
           "\\_<\\(if\\|else\\|for\\|while\\|do\\|switch\\|case\\|try\\|catch\\|finally\\)\\_>"
           limit t)
      (match-string-no-properties 1))))

(defun my/vimish-fold--syntax-context-at-point ()
  "Return nearest enclosing multi-line syntax body and its semantic name."
  (condition-case nil
      (save-excursion
        (let ((start (nth 1 (syntax-ppss)))
              (defun (my/vimish-fold--current-defun-info)))
          (catch 'context
            (while start
              (let* ((end (scan-sexps start 1))
                     (bounds (and end
                                  (my/vimish-fold--delimiter-body-bounds
                                   start end)))
                     (function-brace
                      (and defun
                           (my/vimish-fold--first-code-brace
                            (plist-get defun :beg) (plist-get defun :end))))
                     (function-p (and function-brace (= start function-brace)))
                     (name (if function-p
                               (plist-get defun :name)
                             (my/vimish-fold--block-name-before
                              start (or (plist-get defun :beg) (point-min))))))
                (when (and bounds
                           (my/vimish-fold--multiline-bounds-p
                            (cons start end)))
                  (throw 'context
                         (list :beg (car bounds) :end (cdr bounds)
                               :kind (if function-p 'function 'block)
                               :name name))))
              (goto-char (max (point-min) (1- start)))
              (setq start (nth 1 (syntax-ppss)))))))
    (error nil)))

(defun my/vimish-fold--defun-context-at-point ()
  "Return a fallback context for the body of the current defun."
  (when-let ((info (my/vimish-fold--current-defun-info)))
    (save-excursion
      (goto-char (plist-get info :beg))
      (forward-line 1)
      (let ((beg (line-beginning-position)))
        (goto-char (plist-get info :end))
        (skip-chars-backward " \t\r\n")
        (let ((end (line-end-position)))
          (when (my/vimish-fold--multiline-bounds-p (cons beg end))
            (list :beg beg :end end :kind 'function
                  :name (plist-get info :name))))))))

(defun my/vimish-fold--context-at-point ()
  "Return semantic folding context for the current selection or point."
  (if (use-region-p)
      (list :beg (region-beginning) :end (region-end) :kind 'region)
    ;; Braces and parentheses give the most precise nested block in C-like and
    ;; Lisp modes.  Tree-sitter covers indentation-based and other languages.
    (or (my/vimish-fold--syntax-context-at-point)
        (my/vimish-fold--treesit-context-at-point)
        (my/vimish-fold--defun-context-at-point)
        (user-error "无法确定光标所属的多行代码范围，请先选择需要操作的区域"))))

(defun my/vimish-fold--context-bounds-at-point ()
  "Return the most useful fold range for the current selection or point."
  (let ((context (my/vimish-fold--context-at-point)))
    (cons (plist-get context :beg) (plist-get context :end))))

(defun my/vimish-fold--comment-parts ()
  "Return normalized comment start and end strings for current mode."
  (comment-normalize-vars)
  (cons (string-trim (or comment-start ""))
        (string-trim (or comment-end ""))))

(defun my/vimish-fold--marker-line (marker indentation &optional label)
  "Build a commented MARKER line with INDENTATION and optional LABEL."
  (pcase-let* ((`(,comment-beg . ,comment-end)
                (my/vimish-fold--comment-parts))
               (clean-label
                (string-trim
                 (replace-regexp-in-string "[\n\r]+" " " (or label ""))))
               (body (concat marker
                             (unless (string-empty-p clean-label)
                               (concat " " clean-label)))))
    (concat (make-string indentation ?\s)
            (unless (string-empty-p comment-beg)
              (concat comment-beg " "))
            body
            (unless (string-empty-p comment-end)
              (concat " " comment-end)))))

(defun my/vimish-fold--standalone-marker-line-p (position marker)
  "Return non-nil when MARKER at POSITION occupies a comment-only line.
An optional label inside a block comment is allowed."
  (save-excursion
    (goto-char position)
    (let* ((line (string-trim
                  (buffer-substring-no-properties
                   (line-beginning-position) (line-end-position))))
           (comment-beg (car (my/vimish-fold--comment-parts)))
           (comment-end (cdr (my/vimish-fold--comment-parts))))
      (cond
       ((string-empty-p comment-beg)
        (string-match-p (concat "\\`" (regexp-quote marker) "[ \\t]*\\'") line))
       ((string-empty-p comment-end)
        ;; 行注释后的其余文本仍属于注释，允许作为折叠标签。
        (string-match-p (concat "\\`" (regexp-quote comment-beg)
                                "[ \\t]*" (regexp-quote marker)) line))
       (t
        (string-match-p (concat "\\`" (regexp-quote comment-beg)
                                "[ \\t]*" (regexp-quote marker)
                                ".*" (regexp-quote comment-end) "[ \\t]*\\'")
                        line))))))

(defun my/vimish-fold-insert-markers (beg end label)
  "Wrap the context range from BEG to END in fold markers named LABEL.

The marker lines use the current major mode's comment syntax, so inserting
them does not change the meaning of source code."
  (interactive
   (let* ((context (my/vimish-fold--context-at-point))
          (default-name (plist-get context :name)))
     (list (plist-get context :beg)
           (plist-get context :end)
           (read-string "Fold name (optional): " nil nil default-name))))
  (require 'vimish-fold)
  (when buffer-read-only
    (user-error "当前 Buffer 为只读状态"))
  (when (my/vimish-fold--marker-range-matches-bounds-p
         (my/vimish-fold--marker-range-at-point) beg end)
    (user-error "光标所在代码块已经有手工折叠标记"))
  (pcase-let* ((`(,region-beg . ,region-end)
                (my/vimish-fold--line-bounds beg end))
               (indentation (save-excursion
                              (goto-char region-beg)
                              (current-indentation)))
               (open-line (my/vimish-fold--marker-line
                           (car vimish-fold-marks) indentation label))
               (close-line (my/vimish-fold--marker-line
                            (cdr vimish-fold-marks) indentation))
               (fold-beg (copy-marker region-beg))
               (fold-end nil))
    ;; vimish-fold 不允许嵌套 overlay。插入内层标记前移除外层的展开
    ;; overlay，但保留外层源码标记；之后任一层都可按光标重新建立。
    (my/vimish-fold--delete-overlays-in-range region-beg region-end)
    ;; 先插入结束标记，避免开始标记改变选区末端的位置。
    (save-excursion
      (goto-char region-end)
      (insert "\n" close-line)
      (setq fold-end (copy-marker (point) t))
      (goto-char region-beg)
      (insert open-line "\n"))
    (vimish-fold-mode 1)
    (vimish-fold (marker-position fold-beg) (marker-position fold-end))
    (goto-char (marker-position fold-beg))
    (set-marker fold-beg nil)
    (set-marker fold-end nil)
    (deactivate-mark)))

(defun my/vimish-fold--overlay-p (overlay)
  "Return non-nil when OVERLAY belongs to vimish-fold."
  (memq (overlay-get overlay 'type)
        '(vimish-fold--folded vimish-fold--unfolded)))

(defun my/vimish-fold--overlay-at-point (&optional position)
  "Return the smallest vimish-fold overlay containing POSITION or point."
  (car (sort (cl-remove-if-not
              #'my/vimish-fold--overlay-p
              (overlays-at (or position (point))))
             (lambda (left right)
               (< (- (overlay-end left) (overlay-start left))
                  (- (overlay-end right) (overlay-start right)))))))

(defun my/vimish-fold--line-bounds (beg end)
  "Expand BEG and END to the complete selected source lines."
  (cons (save-excursion
          (goto-char beg)
          (line-beginning-position))
        (save-excursion
          (goto-char end)
          (when (and (> end beg) (bolp))
            (forward-line -1))
          (line-end-position))))

(defun my/vimish-fold--marker-comment-fragment-bounds (position marker)
  "Return bounds of the comment fragment containing MARKER at POSITION.
Fall back to the marker token itself when it is not inside a block comment."
  (save-excursion
    (goto-char position)
    (let* ((line-beg (line-beginning-position))
           (line-end (line-end-position))
           (comment-beg (car (my/vimish-fold--comment-parts)))
           (comment-end (cdr (my/vimish-fold--comment-parts)))
           (beg (and (not (string-empty-p comment-beg))
                     (search-backward comment-beg line-beg t)))
           (end (and beg (not (string-empty-p comment-end))
                     (search-forward comment-end line-end t))))
      (if (and beg end (<= beg position) (<= position end))
          (cons beg end)
        (cons position (+ position (length marker)))))))

(defun my/vimish-fold--marker-ranges ()
  "Return all properly nested marker ranges in the current buffer.
Standalone marker comments fold whole marker lines; inline markers fold only
the character range between the two marker tokens."
  (let ((open-mark (car vimish-fold-marks))
            (close-mark (cdr vimish-fold-marks))
        (regexp (regexp-opt (list (car vimish-fold-marks)
                                  (cdr vimish-fold-marks))))
        stack ranges)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward regexp nil t)
        (if (string= (match-string-no-properties 0) open-mark)
            (push (list :open (match-beginning 0)
                        :open-end (match-end 0)
                        :open-line (line-beginning-position))
                  stack)
          (when stack
            (let* ((opening (pop stack))
                   (open-line (plist-get opening :open-line))
                   (close-pos (match-beginning 0))
                   (close-end (match-end 0))
                   (close-line (line-beginning-position))
                   (close-line-end (line-end-position))
                   (open-standalone
                    (my/vimish-fold--standalone-marker-line-p
                     (plist-get opening :open) open-mark))
                   (close-standalone
                    (my/vimish-fold--standalone-marker-line-p
                     close-pos close-mark))
                   (open-fragment
                    (my/vimish-fold--marker-comment-fragment-bounds
                     (plist-get opening :open) open-mark))
                   (close-fragment
                    (my/vimish-fold--marker-comment-fragment-bounds
                     close-pos close-mark))
                   (fold-beg
                    (save-excursion
                      (if open-standalone
                          (progn (goto-char open-line) (forward-line 1) (point))
                        (cdr open-fragment))))
                   (fold-end
                    (save-excursion
                      (if close-standalone
                          close-line
                        (car close-fragment)))))
              (push (append opening
                            (list :close close-pos
                                  :close-end close-end
                                  :close-line close-line
                                  :close-line-end close-line-end
                                  :open-standalone open-standalone
                                  :close-standalone close-standalone
                                  :open-fragment open-fragment
                                  :close-fragment close-fragment
                                  :content-beg fold-beg
                                  :content-end fold-end
                                  :fold-beg fold-beg
                                  :fold-end fold-end))
                    ranges))))))
    (nreverse ranges)))

(defun my/vimish-fold--marker-range-at-point (&optional position)
  "Return marker positions surrounding POSITION or point.

The result is a plist containing marker and exact fold boundaries."
  (let ((origin (or position (point))))
    (car
     (sort
      (cl-remove-if-not
       (lambda (range)
         (<= (plist-get range :open-line)
             origin
             (plist-get range :close-line-end)))
       (my/vimish-fold--marker-ranges))
      (lambda (left right)
        (< (- (plist-get left :fold-end) (plist-get left :fold-beg))
           (- (plist-get right :fold-end) (plist-get right :fold-beg))))))))

(defun my/vimish-fold--marker-range-matches-bounds-p (range beg end)
  "Return non-nil when RANGE wraps the source lines from BEG through END."
  (pcase-let ((`(,line-beg . ,line-end)
               (my/vimish-fold--line-bounds beg end)))
    (and range
         (or (and (= line-beg (plist-get range :content-beg))
                  (= line-end (plist-get range :content-end)))
             ;; 标记插入后，语法体的首末非空行就是标记行本身。
             (and (= line-beg (plist-get range :fold-beg))
                  (= line-end (plist-get range :fold-end)))))))

(defun my/vimish-fold--overlay-for-range (beg end)
  "Return a vimish overlay whose exact bounds are BEG and END."
  (cl-find-if
   (lambda (overlay)
     (and (my/vimish-fold--overlay-p overlay)
          (= (overlay-start overlay) beg)
          (= (overlay-end overlay) end)))
   (overlays-in beg end)))

(defun my/vimish-fold--delete-overlays-in-range (beg end)
  "Delete every vimish-fold overlay intersecting BEG through END."
  (save-excursion
    (dolist (overlay (delete-dups
                      (append (overlays-at beg)
                              (overlays-in beg end)
                              (overlays-at end))))
      (when (and (overlay-buffer overlay)
                 (my/vimish-fold--overlay-p overlay))
        (goto-char (overlay-start overlay))
        (vimish-fold-delete)))))

(defun my/vimish-fold--generated-marker-line-p (position marker)
  "Return non-nil when line at POSITION is a generated MARKER line."
  (save-excursion
    (goto-char position)
    (let* ((line (string-trim
                  (buffer-substring-no-properties
                   (line-beginning-position) (line-end-position))))
           (comment-beg (car (my/vimish-fold--comment-parts)))
           (prefix (if (string-empty-p comment-beg)
                       (regexp-quote marker)
                     (concat (regexp-quote comment-beg)
                             "[ \t]*" (regexp-quote marker)))))
      (string-match-p (concat "\\`" prefix) line))))

(defun my/vimish-fold--delete-whole-line (position)
  "Delete the complete line containing POSITION."
  (goto-char position)
  (let* ((line-beg (line-beginning-position))
         (at-final-unterminated-line (= (line-end-position) (point-max)))
         ;; 插入结束标记时会为原本没有末尾换行的文件补一个换行；删除位于
         ;; EOF 的标记行时一并移除它，精确恢复原内容。
         (beg (if (and at-final-unterminated-line (> line-beg (point-min)))
                  (1- line-beg)
                line-beg))
         (end (if at-final-unterminated-line
                  (line-end-position)
                (line-beginning-position 2))))
    (delete-region beg end)))

(defun my/vimish-fold--delete-marker-fragment (position marker)
  "Delete the comment fragment containing MARKER at POSITION.
For a non-comment marker, delete only MARKER itself."
  (pcase-let ((`(,beg . ,end)
               (my/vimish-fold--marker-comment-fragment-bounds position marker)))
    (delete-region beg end)))

(defun my/vimish-fold-delete-markers ()
  "Delete the nearest manual fold containing point.

When the current syntax block has no fold, continue searching outward through
its containing folds.  Prefer the smallest real fold at point; source markers
are removed together with their overlay, while temporary folds lose only their
overlay.  If no containing fold exists, leave the buffer unchanged and report
that fact in the echo area."
  (interactive)
  (require 'vimish-fold)
  (when buffer-read-only
    (user-error "当前 Buffer 为只读状态"))
  (let* ((range (my/vimish-fold--marker-range-at-point))
         (overlay (my/vimish-fold--overlay-at-point))
         (range-size
          (and range
               (- (plist-get range :fold-end)
                  (plist-get range :fold-beg))))
         (overlay-size
          (and overlay (- (overlay-end overlay) (overlay-start overlay))))
         ;; 标记范围和临时 overlay 都是实际存在的折叠。选跨度最小者，等价于
         ;; 从当前结构开始逐层向外找到第一个折叠；边界相同则优先删除源码标记。
         (delete-range-p
          (and range
               (or (null overlay-size) (<= range-size overlay-size)))))
    (cond
     (delete-range-p
      (let ((open-pos (plist-get range :open))
            (close-pos (plist-get range :close))
            (close-line-end (plist-get range :close-line-end))
            (open-mark (car vimish-fold-marks))
            (close-mark (cdr vimish-fold-marks)))
        ;; 先移除覆盖层及其只读属性，再从后向前删除标记。独立标记行保留
        ;; 旧行为；行内标记只删除包围 {{{ / }}} 的注释片段。
        (save-excursion
          (dolist (item (overlays-in open-pos close-line-end))
            (when (my/vimish-fold--overlay-p item)
              (goto-char (overlay-start item))
              (vimish-fold-delete)))
          (if (plist-get range :close-standalone)
              (my/vimish-fold--delete-whole-line close-pos)
            (my/vimish-fold--delete-marker-fragment close-pos close-mark))
          (if (plist-get range :open-standalone)
              (my/vimish-fold--delete-whole-line open-pos)
            (my/vimish-fold--delete-marker-fragment open-pos open-mark)))))
     (overlay
      ;; 内层没有标记但有临时折叠时，先删除这个最近的实际折叠。
      (save-excursion
        (goto-char (overlay-start overlay))
        (vimish-fold-delete)))
     (t
      (message "当前代码结构及其外层都没有可删除的折叠")
      nil))))

(defun my/vimish-fold-toggle-at-point ()
  "Toggle the fold containing point, or create one for point's code range."
  (interactive)
  (require 'vimish-fold)
  (let* ((origin (point))
         (overlay (my/vimish-fold--overlay-at-point))
         (marker-range (my/vimish-fold--marker-range-at-point))
         (context (condition-case nil
                      (my/vimish-fold--context-at-point)
                    (error nil)))
         (context-beg (plist-get context :beg))
         (context-end (plist-get context :end))
         (marker-target-p
          (and marker-range
               (or (null context)
                   (my/vimish-fold--marker-range-matches-bounds-p
                    marker-range context-beg context-end))))
         (target-bounds
          (cond
           (marker-target-p
            (cons (plist-get marker-range :fold-beg)
                  (plist-get marker-range :fold-end)))
           (context
            (my/vimish-fold--line-bounds context-beg context-end))))
         (target-overlay
          (and target-bounds
               (my/vimish-fold--overlay-for-range
                (car target-bounds) (cdr target-bounds)))))
    (cond
     (target-overlay
      (goto-char (overlay-start target-overlay))
      (vimish-fold-toggle))
     ((and (not marker-range) overlay)
      ;; 没有源码标记的临时折叠直接按 overlay 切换。
      (goto-char (overlay-start overlay))
      (vimish-fold-toggle))
     (target-bounds
      ;; vimish-fold 不允许相互包含的 overlay。切换到内层 if/do 或外层
      ;; 函数前，先移除冲突层，再只建立光标语义范围这一层。
      (my/vimish-fold--delete-overlays-in-range
       (car target-bounds) (cdr target-bounds))
      (vimish-fold-mode 1)
      (vimish-fold (car target-bounds) (cdr target-bounds))
      (goto-char (car target-bounds)))
     (t
      (user-error "无法确定光标所属的可折叠代码范围")))
    (when (<= (point-min) origin (point-max))
      ;; 展开操作后尽量保留用户原来的代码位置。
      (unless (my/vimish-fold--overlay-at-point)
        (goto-char origin)))))

(defun my/vimish-fold--ensure-marker-folds ()
  "Create Vimish Fold overlays for marker ranges that do not have one yet.
Vimish Fold cannot nest or overlap overlays, so an existing intersecting
manual fold takes precedence over creating another overlay for that range."
  (require 'vimish-fold)
  (when-let ((ranges (my/vimish-fold--marker-ranges)))
    (vimish-fold-mode 1)
    (dolist (range ranges)
      (let ((beg (plist-get range :fold-beg))
            (end (plist-get range :fold-end)))
        (when (and (< beg end)
                   (not (cl-some #'my/vimish-fold--overlay-p
                                 (overlays-in beg end))))
          (vimish-fold beg end))))))

(defun my/vimish-fold-toggle-buffer ()
  "统一切换当前 Buffer 的全部手工折叠状态。
只要存在任一展开项就全部折叠；仅当所有折叠均已折叠时才全部展开。"
  (interactive)
  (require 'vimish-fold)
  ;; 文件中已有 {{{ / }}} 标记时，首次执行也应能直接折叠它们；不能要求
  ;; 用户先逐个执行“切换光标处折叠”来创建 Vimish Fold 覆盖层。
  (my/vimish-fold--ensure-marker-folds)
  (let ((folds (vimish-fold--folds-in (point-min) (point-max))))
    (unless folds
      (user-error "当前 Buffer 没有手工折叠"))
    (if (cl-every #'vimish-fold--vimish-overlay-folded-p folds)
        (vimish-fold-unfold-all)
      (vimish-fold-refold-all))))

;; 手工折叠属于代码大纲操作，统一放在 C-c o f 子菜单。
(with-eval-after-load 'general
  (my-leader-def
    "o f i" '("在光标或区域插入折叠" . my/vimish-fold-insert-markers)
    "o f d" '("删除光标处折叠" . my/vimish-fold-delete-markers)
    "o f t" '("切换光标处折叠" . my/vimish-fold-toggle-at-point)
    "o f a" '("整篇切换手工折叠" . my/vimish-fold-toggle-buffer)
    "o f u" '("展开全部手工折叠" . vimish-fold-unfold-all)
    "o f r" '("重新折叠全部手工折叠" . vimish-fold-refold-all)
    "o f n" '("下一个手工折叠" . vimish-fold-next-fold)
    "o f p" '("上一个手工折叠" . vimish-fold-previous-fold)))

(provide 'init-fold)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c o f i' 优先使用选区；没有选区时自动查找光标所在的最近多行
;;   Tree-sitter 语法块、括号范围或函数，插入注释化的 `{{{' / `}}}' 并折叠。
;; - 在函数中执行时只折叠大括号内的函数体，函数名、参数和外层大括号保持
;;   可见；折叠名称默认使用函数名，可以在提示中直接回车确认或自行修改。
;; - 函数已有折叠标记时，展开后仍可把光标移入 `if'、`do/while'、`for'、
;;   `switch' 等内部代码块，继续插入、切换或删除各自独立的嵌套折叠。
;; - 光标位于折叠范围内的任意位置时，`C-c o f d' 删除对应折叠；有源码
;;   标记时同时删除上下标记行，没有标记时只删除折叠覆盖层。当前结构没有
;;   折叠时会按 `if -> while -> 函数' 的顺序向外查找最近的真实折叠；如果
;;   最外层仍然没有折叠，只显示提示，不修改代码。
;; - `C-c o f t' 切换光标所属折叠；尚无折叠时自动折叠当前语法范围。
;; - `C-c o f a/u/r' 分别切换全部/全部展开/全部折叠。
;; - `C-c o f n/p' 跳转到下一个/上一个手工折叠。
;; - 手工折叠状态保存在 `runtimes/vimish-fold/'；源码标记可随文件一起保存。
;; - `treesit-fold' 继续负责语法结构折叠，两套功能互不替代。
;;; init-fold.el ends here
