;;; -*- lexical-binding: t -*-

;;; 中文导读：重写“按词移动/删除”，把连续标点也视作一个可操作单元，并跨行处理
;;; 边界。M-f/C-右 前进一个词，M-b/C-左 后退一个词；C-Delete 向后方删除一个
;;; 词或空白段，C-Backspace 向前方删除。若区域已选中，删除命令优先删除选区。
(defconst my--word-re "[[:word:]]+\\|[^[:word:]\t ]+"
  "A word: a run of word chars or a run of punctuation.")

(defconst my--word-chars
  "[:word:]" "Word chars (skip-chars set).")

(defconst my--sep-chars
  "^[:word:]\t " "Punctuation (skip-chars set).")

;; 判断 POS 处字符是否属于 Emacs 语法表中的“单词字符”。
(defun my--word-char-p (pos)
  "Non-nil if char at POS is a word char."
  (let ((c (char-after pos))) (and c (eq (char-syntax c) ?w))))

;; 在点位之后、LIM 之前查找下一个单词或连续标点，返回起止位置。
(defun my--next-word (lim)
  "Return (START . END) of the word at/after point, within LIMIT."
  (when (re-search-forward my--word-re lim t)
    (cons (match-beginning 0) (match-end 0))))

;; 在点位之前、LIM 之后查找上一个单词或连续标点，返回起止位置。
(defun my--prev-word (lim)
  "Return (START . END) of the word at/just before point, bounded by LIMIT."
  (save-excursion
    (goto-char (max lim (1- (point))))
    (when (looking-at "[ \t]")
      (skip-chars-backward " \t" lim)
      (when (> (point) lim) (backward-char 1)))
    (when (> (point) lim)
      (let* ((cs (if (my--word-char-p (point)) my--word-chars my--sep-chars))
             (end (save-excursion (skip-chars-forward cs (line-end-position)) (point))))
        (skip-chars-backward cs lim)
        (cons (point) end)))))

;; 对单字符标点与相邻单词作合并跳转；REV 非空时按反方向计算目标位置。
(defun my--skip (w lim rev)
  "If word W is one punct char followed by a word char, skip over it:
return next word's END (or previous word's START when REV), else W's end/start."
  (if (and (= (cdr w) (1+ (car w))) (my--word-char-p (cdr w)))
      (let ((w2 (save-excursion
                  (goto-char (if rev (car w) (cdr w)))
                  (if rev (my--prev-word lim) (my--next-word lim)))))
        (if w2 (if rev (car w2) (cdr w2)) lim))
    (if rev (car w) (cdr w))))

;; 向前移动到当前/下一个词尾；SKIP 非空时跳过紧邻单词的单字符标点。
(defun my--fwd (&optional skip)
  "Move point to end of current/next word."
  (let ((eol (line-end-position)))
    (if (< (point) eol)
        (let ((w (my--next-word eol)))
          (goto-char (if w (if skip (my--skip w eol nil) (cdr w)) eol)))
      (when (< (point) (point-max))
        (forward-char 1) (my--fwd skip)))))

;; 向后移动到上一个词首，并在行边界处继续跨行。
(defun my--bwd (&optional skip)
  "Move point to start of previous word."
  (let ((bol (line-beginning-position)))
    (if (= (point) bol)
        (when (> (point) (point-min))
          (backward-char 1) (my--bwd skip))
      (let ((w (my--prev-word bol)))
        (goto-char (if w (if skip (my--skip w bol t) (car w)) bol))))))

;; 交互式向前移动 ARG 个自定义“词”。
(defun my-forward-word (&optional arg)
  (interactive "^p")
  (dotimes (_ (or arg 1)) (my--fwd t)))

;; 交互式向后移动 ARG 个自定义“词”。
(defun my-backward-word (&optional arg)
  (interactive "^p")
  (dotimes (_ (or arg 1)) (my--bwd t)))

;; DIR 为正时向前、为负时向后删除一个词；活动选区存在时直接删除选区。
(defun my-delete-word (dir)
  "Delete word toward DIR (+1 forward, -1 backward)."
  (interactive)
  (if (and mark-active (not (eq (mark) (point))))
      (delete-region (min (mark) (point)) (max (mark) (point)))
    (let* ((pos (point))
           (dst (save-excursion
                  (if (> dir 0)
                      (if (looking-at "[ \t]")
                          (skip-chars-forward " \t" (line-end-position))
                        (my--fwd nil))
                    (if (memq (char-before) '(?\s ?\t))
                        (skip-chars-backward " \t")
                      (my--bwd nil)))
                  (point))))
      (when (if (> dir 0) (> dst pos) (< dst pos))
        (delete-region (min pos dst) (max pos dst))))))

(keymap-global-set "M-f" #'my-forward-word)
(keymap-global-set "M-b" #'my-backward-word)
(keymap-global-set "C-<right>" #'my-forward-word)
(keymap-global-set "C-<left>" #'my-backward-word)
(keymap-global-set "C-<delete>" (lambda () (interactive) (my-delete-word 1)))
(keymap-global-set "C-<backspace>" (lambda () (interactive) (my-delete-word -1)))

(provide 'init-word-move)
