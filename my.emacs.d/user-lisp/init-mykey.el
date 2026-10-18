;;; -*- lexical-binding: t -*-

(defconst my/match-pair--tag-regexp
  "<\\(/?\\)\\([[:alnum:]_:.-]+\\)\\(?:[ \t\n][^>]*\\)?\\(/?\\)>"
  "Regexp used to recognize ordinary HTML/XML start and end tags.")

(defun my/match-pair--tag-at-point ()
  "Return metadata for the HTML/XML tag containing point, or nil."
  (save-excursion
    (let ((origin (point)))
      (when (or (eq (char-after) ?<)
                (search-backward "<" (line-beginning-position) t))
        (when (and (looking-at my/match-pair--tag-regexp)
                   (<= (match-beginning 0) origin)
                   (<= origin (match-end 0)))
          (list :start (match-beginning 0)
                :end (match-end 0)
                :name (downcase (match-string-no-properties 2))
                :closing (equal (match-string-no-properties 1) "/")
                :self-closing (equal (match-string-no-properties 3) "/")))))))

(defun my/match-pair--find-tag-match (tag)
  "Return the matching tag position for TAG metadata, or nil.
Nested tags with the same name are counted, so an outer HTML element matches
its own closing tag rather than an inner sibling's closing tag."
  (let* ((name (plist-get tag :name))
         (closing (plist-get tag :closing))
         (self-closing (plist-get tag :self-closing))
         (regexp (concat "<\\(/?\\)" (regexp-quote name)
                         "\\(?:[ \t\n][^>]*\\)?\\(/?\\)>"))
         (case-fold-search t))
    (unless self-closing
      (save-excursion
        (goto-char (if closing (plist-get tag :start) (plist-get tag :end)))
        (let ((depth 1)
              target)
          (while (and (not target)
                      (if closing
                          (re-search-backward regexp nil t)
                        (re-search-forward regexp nil t)))
            (unless (equal (match-string-no-properties 3) "/")
              (let ((found-closing (equal (match-string-no-properties 1) "/")))
                (setq depth
                      (if (eq closing found-closing)
                          (1+ depth)
                        (1- depth)))
                (when (zerop depth)
                  (setq target (match-beginning 0))))))
          target)))))

(defun my/match-pair--delimiter-p (character)
  "Return non-nil if CHARACTER is a standard structural delimiter."
  (memq character '(?\( ?\) ?\[ ?\] ?\{ ?\} ?\" ?\')))

(defun my/match-pair--sexp-target ()
  "Return matching delimiter position at or after point on the current line."
  (save-excursion
    (let ((limit (line-end-position))
          character target)
      (while (and (not target) (< (point) limit))
        (setq character (char-after))
        (if (my/match-pair--delimiter-p character)
            (condition-case nil
                (cond
                 ((memq character '(?\( ?\[ ?\{))
                  (forward-sexp 1)
                  (setq target (1- (point))))
                 ((memq character '(?\) ?\] ?\}))
                  (forward-sexp -1)
                  (setq target (point)))
                 ((eq (char-syntax character) ?\")
                  (if (nth 3 (syntax-ppss (1+ (point))))
                      (progn (forward-sexp 1) (setq target (1- (point))))
                    (forward-sexp -1)
                    (setq target (point))))
                 (t (forward-char 1)))
              (scan-error (forward-char 1)))
          (forward-char 1)))
      target)))

(defun my/match-pair ()
  "跳转到当前或当前行后方的配对符号，行为类似 Vim 的 `%`。
支持 Emacs 语法表定义的 `()'、`[]'、`{}'、引号等成对符号，并按嵌套层级
匹配 HTML/XML 的开闭标签。"
  (interactive)
  (let* ((tag (or (my/match-pair--tag-at-point)
                  (save-excursion
                    (when (search-forward "<" (line-end-position) t)
                      (backward-char 1)
                      (my/match-pair--tag-at-point)))))
         (target (or (and tag (my/match-pair--find-tag-match tag))
                     (my/match-pair--sexp-target))))
    (if target
        (goto-char target)
      (user-error "未找到可匹配的成对符号或标签"))))

;;; 根据自我习惯增加/修改/重置的emacs的keybinding方式



;;; 滚动：C-c C-d/C-c C-u 半屏上/下滚，C-1/C-2 整屏滚，C-3 重定位。
;;; 窗口：C-c w f/b/n/p 向右/左/下/上分割并进入；C-M-h/j/k/l
;;; 切换窗口；M-S-h/l 加宽/缩窄，M-S-k/j 增高/降低；M-F11 全屏。
;;; 编辑：ESC 取消，C-! 替换，C-c e r/R/w 替换包围符/成对替换/包围单词；M-w
;;; 复制、C-w 剪切、C-v 粘贴、C-z/C-S-z 撤销/重做；C-x C-d 删除整行但不进
;;; kill-ring，C-, 复制当前行并下移，M-k/M-j 上下移动行，M-l/M-r 转小/大写。
;;; 导航：C-c C-r 到项目根，C-c C-j 打开项目 Dired，C-~ 打开主目录，C-' 打开
;;; Imenu；C-TAB/C-S-TAB 切换下/上一个缓冲区；C-a 到缩进首字符，C-M-a 到行首。
;;; 缓冲区：C-x k 执行带保护的关闭，C-x C-k 直接关闭；S-TAB 左移缩进。

;; 若有活动选区则剪切选区，否则剪切当前整行，并把内容放入 kill-ring。
(defun my-cut-dwim ()
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))

;; 若有活动选区则复制选区，否则复制当前整行；复制后内容可由 yank 粘贴。
(defun my-copy-dwim()
  (interactive)
  (if (use-region-p)
      (copy-region-as-kill (region-beginning) (region-end))
    (progn (kill-ring-save (line-beginning-position) (line-beginning-position 2)))))

;; 将当前行与上一行交换，并保持光标随当前行向上移动。
(defun my-move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

;; 将当前行与下一行交换，并保持光标随当前行向下移动。
(defun my-move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

;;;; 复制当前整行到 kill-ring，然后把光标移到下一行同一逻辑位置。
;;(defun my-copy-line-and-move-down ()
;;  (interactive)
;;  (duplicate-line)
;;  (next-line 1))

;; 删除当前整行但不写入 kill-ring，避免覆盖刚复制/剪切的内容。
(defun my-delete-whole-line-no-killring ()
  (interactive)
  (delete-region (line-beginning-position) (line-beginning-position 2)))

;; 根据当前上下文安全关闭窗口或缓冲区，避免直接 kill 带来的误关闭。
;; 该函数在关闭当前 Buffer 时，会自动静默保存已修改的实体文件，并在只剩双分屏时自动销毁当前窗口以恢复单屏布局。
(defun my-kill-with-save-and-delete-split-window ()
  (interactive)
  (when (and (buffer-file-name)
             (file-exists-p (buffer-file-name))
             (buffer-modified-p))
    (save-buffer))
  (kill-current-buffer)
  (when (= (count-windows) 2)
    (delete-window)))

;; 有选区时把选区转小写，否则把光标处单词转小写（DWIM：按上下文执行）。
;; (defun my-downcase-dwim ()
;;   (interactive)
;;  (if (use-region-p)
;;      (downcase-region (region-beginning) (region-end))
;;    (call-interactively #'downcase-word)))

(defun my-lower-dwim ()
  "如果选中了区域则转小写选区；否则将当前光标所在的整个单词转小写。"
  (interactive)
  (if (use-region-p)
      (downcase-region (region-beginning) (region-end))
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (if bounds
          (downcase-region (car bounds) (cdr bounds))
        (call-interactively #'downcase-word)))))

;;  如果选中了区域则大写选区；否则将当前光标所在的整个单词转大写
(defun my-upper-dwim ()
  "Upcase region if active; otherwise upcase the ENTIRE word at point."
  (interactive)
  (if (use-region-p)
      (upcase-region (region-beginning) (region-end))
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (if bounds
          (upcase-region (car bounds) (cdr bounds))
        ;; 如果光标不在任何单词上（如空白处），则按原生逻辑转换下一个单词
        (upcase-word 1)))))


;; 2. 整个单词/选区首字母大写
(defun my-capitalize-dwim ()
  "Capitalize region if active; otherwise capitalize the ENTIRE word at point."
  (interactive)
  (if (use-region-p)
      (capitalize-region (region-beginning) (region-end))
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (if bounds
          (capitalize-region (car bounds) (cdr bounds))
        (capitalize-word 1)))))

;; 有选区时把选区转大写，否则把光标处单词转大写。
;; (defun my-upcase-dwim ()
;;  (interactive)
;;  (if (use-region-p)
;;      (upcase-region (region-beginning) (region-end))
;;    (call-interactively #'upcase-word)))

;; 用 Dired 打开用户主目录。
(defun my-home-dired ()
  (interactive)
  (dired "~"))

;; 查找当前项目根目录并将 `default-directory' 切换到该目录。
(defun my-switch-to-project-root ()
  (interactive)
  (if-let* ((proj (project-current)))
      (dired (project-root proj))
    (dired default-directory)))

;; 读取一个字符 CHAR，用它（或对应的闭合符号）包围光标处单词。
(defun my-surround-word (char)
;; 用指定字符包围文本用指定字符包围文本
  "Wrap word at point or active region with CHAR."
  (interactive "cWrap char: ")
  (let ((beg (if (use-region-p) (region-beginning)
               (car (bounds-of-thing-at-point 'word))))
        (end (if (use-region-p) (region-end)
               (cdr (bounds-of-thing-at-point 'word)))))
    (when (and beg end)
      (save-excursion
        (goto-char end) (insert char)
        (goto-char beg) (insert char)))))

;; 将光标附近已有的包围符替换为用户输入的 CHAR 对应符号。
(defun my-surround-replace (char)
;; 模糊替换光标单词两侧的符号
  (interactive "cReplace surrounding chars with: ")
  (when-let ((bounds (bounds-of-thing-at-point 'word)))
    (save-excursion
      (goto-char (car bounds))
      (when (search-backward-regexp "[^[:space:]]" (line-beginning-position) t)
        (delete-char 1) (insert char))
      (goto-char (cdr bounds))
      (when (search-forward-regexp "[^[:space:]]" (line-end-position) t)
        (delete-char -1) (insert char)))))

;; 在当前位置附近查找 OLD-CHAR 成对符号，并整体替换为 NEW-CHAR 对应符号。
(defun my-surround-replace-pair (old-char new-char)
;; 精准替换成对出现的符号
  (interactive "cWrap char? \ncReplace surrounding chars with: ")
  (when-let ((bounds (bounds-of-thing-at-point 'word)))
    (save-excursion
      (goto-char (car bounds))
      (when (search-backward (string old-char) (line-beginning-position) t)
        (delete-char 1)
        (insert (string new-char)))
      (goto-char (cdr bounds))
      (when (search-forward (string old-char) (line-end-position) t)
        (delete-char -1)
        (insert (string new-char))))))

;; 在 START 到 END（默认选区或缓冲区）内把 FROM 替换为 TO；DELIMITED 限制完整单词。
(defun my-replace-dwim (from to &optional delimited start end)
;; 区域/全缓冲区全局字符串替换
  (interactive
   (let ((beg (if (use-region-p) (region-beginning) (point-min)))
         (end (if (use-region-p) (region-end)       (point-max))))
     (list (read-string "Replace: ")
           (read-string "With: ")
           nil beg end)))
  (replace-string from to delimited start end))

;; 按 DIRECTION 在指定方向分割当前窗口，并把焦点切换到新窗口。
(defun my-split-and-switch (direction)
  (let ((buf (read-buffer
              "Switch to buffer: "
              (other-buffer (current-buffer) t))))
    (pcase direction
      ('right (select-window (split-window-right)))
      ('below (select-window (split-window-below)))
      ('left  (split-window-right))
      ('above (split-window-below)))
    (switch-to-buffer buf)))

;; 以下四个交互命令分别在右、左、下、上方分割并进入新窗口。
(defun my-split-right-and-switch ()  (interactive) (my-split-and-switch 'right))
(defun my-split-left-and-switch  ()  (interactive) (my-split-and-switch 'left))
(defun my-split-below-and-switch ()  (interactive) (my-split-and-switch 'below))
(defun my-split-above-and-switch ()  (interactive) (my-split-and-switch 'above))


;; 将文本向上滚动当前窗口高度的一半。
(defun my-scroll-half-screen-up ()
  "向下滚动半屏（文字向上移动）。"
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

;; 将文本向下滚动当前窗口高度的一半。
(defun my-scroll-half-screen-down ()
  "向上滚动半屏（文字向下移动）。"
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

;;; --- 自定义保持光标不动的开辟空行函数 ---

(defun my-open-line-below ()
  "在当前行下方插入一个空行，并保持光标位置不动。"
  (interactive)
  (save-excursion
    (end-of-line)
    (open-line 1)))

(defun my-open-line-above ()
  "在当前行上方插入一个空行，并保持光标位置不动。"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (open-line 1)))

;;; --- 自定义 Toggle Mark 函数 ---

(defun my/toggle-mark-command ()
;;  "类似 C-@ / C-SPC 的 Toggle 函数：
;; 若选区未激活，则开启标记 (Set Mark)；
;; 若选区已激活，则关闭/取消选区 (Deactivate Mark)。"
  (interactive)
  (if (use-region-p)
      (deactivate-mark)
    (set-mark-command nil)))

;; --- 快捷键绑定 ---

;; 1. 原生 global-set-key 方式 (覆盖原生 C-2 的 digit-argument)
(global-set-key (kbd "C-2") #'my/toggle-mark-command)

;; 2. 如果使用 General.el 体系，可写为：
(with-eval-after-load 'general
  (general-def
    "C-2" #'my/toggle-mark-command))


;; 绑定快捷键（可以根据个人习惯修改）

;;============*  设置 my 序列改进设置 *========================
;; 上翻半页
(keymap-global-set "C-0"  #'my-scroll-half-screen-up)
;; 下翻半页
(keymap-global-set "C-9"  #'my-scroll-half-screen-down)
(keymap-global-set "C-o"  #'my-open-line-below)
(keymap-global-set "C-S-o"  #'my-open-line-above)

(keymap-global-set "M-w" #'my-copy-dwim)
;;(keymap-global-set "C-w" #'my-copy-dwim)
(global-set-key (kbd "C-t") #'kill-region)

(keymap-global-set "C-k" #'my-cut-dwim)
(keymap-global-set "M-k" #'my-move-line-up)
(keymap-global-set "M-j" #'my-move-line-down)
(keymap-global-set "C-x d" #'my-delete-whole-line-no-killring)
(keymap-global-set "M-l" #'my-lower-dwim)
(keymap-global-set "M-u" #'my-upper-dwim)
(keymap-global-set "M-c" #'my-capitalize-dwim)
(keymap-global-set "C-x C-k" #'my-kill-with-save-and-delete-split-window)
(keymap-global-set "C-!" #'my-replace-dwim)

;;============= *  更改 EMACS 自身的某些设置 *=====================
;; 普通 Buffer 的物理 ESC 与 C-g 一样取消当前操作。不能放在
;; `key-translation-map'，否则 Vterm 会在其局部按键映射之前收到 C-g。
(define-key key-translation-map (kbd "ESC") nil)
(define-key global-map (kbd "ESC") esc-map)
(keymap-global-set "<escape>" #'keyboard-quit)

;; 用全局 minor mode 覆盖运行时 ESC，而不是修改 `global-map' 中的 ESC
;; 前缀。后者会让随后定义的 M-x、M-; 等 Meta 快捷键报“非前缀键”错误。
(defun my/escape-quit-dwim (&optional keys)
  "执行当前模式明确绑定的 ESC 命令，其他情况等价于 `keyboard-quit'.
KEYS 仅供测试或特殊调用使用；交互调用时读取本次实际按键。"
  (interactive)
  (let* ((keys (or keys (this-single-command-keys)))
         (binding (local-key-binding keys)))
    (if (and (commandp binding) (not (keymapp binding))
             (not (eq binding #'my/escape-quit-dwim)))
        (call-interactively binding)
      (keyboard-quit))))

(defvar my/escape-quit-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "ESC") #'my/escape-quit-dwim)
    (define-key map [escape] #'my/escape-quit-dwim)
    map)
  "让常规 Buffer 中 ESC 与 C-g 等价的全局按键表。")

(define-minor-mode my/escape-quit-mode
  "让 ESC 取消当前操作；Vterm 通过局部 override 保留真实 Escape。"
  :global t
  :init-value t
  :lighter nil)

;; Transient 自身把原始 ESC 作为 `ESC ESC' 前缀；显式覆盖为与 C-g
;; 相同的单层退出，避免菜单仍需连按两次 ESC。
(with-eval-after-load 'transient
  (define-key transient-base-map (kbd "ESC") #'transient-quit-one)
  (define-key transient-base-map [escape] #'transient-quit-one))
 ;; 把 c-k 设置为不管什么位姿都删除当前行
;; (global-set-key (kbd "C-k") 'kill-whole-line)
(keymap-global-set "C-'" #'imenu)
(keymap-global-set "C-8" #'scroll-up-command)
(keymap-global-set "C-7" #'scroll-down-command)
(keymap-global-set "C-l" #'recenter-top-bottom)
(keymap-global-set "C-S-a" #'move-beginning-of-line)
;; 方案 A：直接用 comment-line 覆盖原生的 M-; (最顺手)
(global-set-key (kbd "M-;") #'comment-line)

(with-eval-after-load 'general
  (my-leader-def
    "t %" '("匹配成对符号或标签" . my/match-pair)))


;;(keymap-global-set "C-!" #'my-replace)
(keymap-global-set "C-c C-r" #'my-switch-to-project-root)
;;(keymap-global-set "C-c C-j" #'project-dired)
;;(keymap-global-set "M-w" #'my-copy)
;;(keymap-global-set "C-w" #'my-cut)
;;(keymap-global-set "C-x k" #'my-kill)
;;(keymap-global-set "C-x C-k" #'kill-buffer)
;;(keymap-global-set "C-," #'my-copy-line-and-move-down)
;;(keymap-global-set "C-~" #'my-home-dired)
;; (keymap-global-set "S-<tab>" #'indent-rigidly-left-to-tab-stop)
;; (keymap-global-set "C-<tab>" #'next-buffer)
;; (keymap-global-set "C-S-<tab>" #'bs-cycle-previous)
    ;;(keymap-global-set "C-a" #'back-to-indentation)
;;(keymap-global-set "C-v" #'yank)
;; (keymap-global-set "C-z" #'undo)
;; (keymap-global-set "C-S-z" #'undo-redo)
;; (keymap-global-set "M-<f11>" #'toggle-frame-fullscreen)
;; (keymap-global-set "M-S-l" #'shrink-window-horizontally)
;; (keymap-global-set "M-S-h" #'enlarge-window-horizontally)
;; (keymap-global-set "M-S-j" #'shrink-window)
;; (keymap-global-set "M-S-k" #'enlarge-window)
;;(keymap-global-set "M-l" #'my-downcase-dwim)
;;(keymap-global-set "M-r" #'my-upcase-dwim)

(provide 'init-mykey)
