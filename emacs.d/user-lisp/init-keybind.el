;;; -*- lexical-binding: t -*-

;;; 中文导读：全局快捷键集中表。前面的 my-* 函数实现上下文感知复制/剪切、窗口
;;; 分割、成对符号替换、大小写和行移动；文件末尾统一绑定，便于查找冲突。
;;; 滚动：C-c C-d/C-c C-u 半屏上/下滚，C-1/C-2 整屏滚，C-3 重定位。
;;; 窗口：C-c o f/b/n/p（或 l/h/j/k）向右/左/下/上分割并进入；C-M-h/j/k/l
;;; 切换窗口；M-S-h/l 加宽/缩窄，M-S-k/j 增高/降低；M-F11 全屏。
;;; 编辑：ESC 取消，C-! 替换，C-c w r/R/w 替换包围符/成对替换/包围单词；M-w
;;; 复制、C-w 剪切、C-v 粘贴、C-z/C-S-z 撤销/重做；C-x C-d 删除整行但不进
;;; kill-ring，C-, 复制当前行并下移，M-k/M-j 上下移动行，M-l/M-r 转小/大写。
;;; 导航：C-c C-r 到项目根，C-c C-j 打开项目 Dired，C-~ 打开主目录，C-' 打开
;;; Imenu；C-TAB/C-S-TAB 切换下/上一个缓冲区；C-a 到缩进首字符，C-M-a 到行首。
;;; 缓冲区：C-x k 执行带保护的关闭，C-x C-k 直接关闭；S-TAB 左移缩进。
;; 若有活动选区则剪切选区，否则剪切当前整行，并把内容放入 kill-ring。
(defun my-cut ()
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))

;; 若有活动选区则复制选区，否则复制当前整行；复制后内容可由 yank 粘贴。
(defun my-copy ()
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

;; 复制当前整行到 kill-ring，然后把光标移到下一行同一逻辑位置。
(defun my-copy-line-and-move-down ()
  (interactive)
  (duplicate-line)
  (next-line 1))

;; 删除当前整行但不写入 kill-ring，避免覆盖刚复制/剪切的内容。
(defun my-delete-whole-line-no-kill ()
  (interactive)
  (delete-region (line-beginning-position) (line-beginning-position 2)))

;; 根据当前上下文安全关闭窗口或缓冲区，避免直接 kill 带来的误关闭。
(defun my-kill ()
  (interactive)
  (when (and (buffer-file-name)
             (file-exists-p (buffer-file-name))
             (buffer-modified-p))
    (save-buffer))
  (kill-current-buffer)
  (when (= (count-windows) 2)
    (delete-window)))

;; 有选区时把选区转小写，否则把光标处单词转小写（DWIM：按上下文执行）。
(defun my-downcase-dwim ()
  (interactive)
  (if (use-region-p)
      (downcase-region (region-beginning) (region-end))
    (call-interactively #'downcase-word)))

;; 有选区时把选区转大写，否则把光标处单词转大写。
(defun my-upcase-dwim ()
  (interactive)
  (if (use-region-p)
      (upcase-region (region-beginning) (region-end))
    (call-interactively #'upcase-word)))

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
(defun my-replace (from to &optional delimited start end)
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
(defun scroll-half-screen-up ()
  "向下滚动半屏（文字向上移动）。"
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

;; 将文本向下滚动当前窗口高度的一半。
(defun scroll-half-screen-down ()
  "向上滚动半屏（文字向下移动）。"
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

;; 绑定快捷键（可以根据个人习惯修改）

(keymap-global-set "C-c C-d"  #'scroll-half-screen-up)
(keymap-global-set "C-c C-u"  #'scroll-half-screen-down)


(keymap-global-set "<escape>" #'keyboard-escape-quit)
(keymap-global-set "C-!" #'my-replace)
(keymap-global-set "C-c o f" #'my-split-right-and-switch)
(keymap-global-set "C-c o b" #'my-split-left-and-switch)
(keymap-global-set "C-c o n" #'my-split-below-and-switch)
(keymap-global-set "C-c o p" #'my-split-above-and-switch)
(keymap-global-set "C-c o l" #'my-split-right-and-switch)
(keymap-global-set "C-c o h" #'my-split-left-and-switch)
(keymap-global-set "C-c o j" #'my-split-below-and-switch)
(keymap-global-set "C-c o k" #'my-split-above-and-switch)
(keymap-global-set "C-c w r" #'my-surround-replace)
(keymap-global-set "C-c w R" #'my-surround-replace-pair)
(keymap-global-set "C-c w w" #'my-surround-word)
(keymap-global-set "C-c C-r" #'my-switch-to-project-root)
(keymap-global-set "C-c C-j" #'project-dired)
(keymap-global-set "M-w" #'my-copy)
(keymap-global-set "C-w" #'my-cut)
(keymap-global-set "C-x k" #'my-kill)
(keymap-global-set "C-x C-k" #'kill-buffer)
(keymap-global-set "C-x C-d" #'my-delete-whole-line-no-kill)
(keymap-global-set "C-," #'my-copy-line-and-move-down)
(keymap-global-set "C-~" #'my-home-dired)
(keymap-global-set "C-'" #'imenu)
(keymap-global-set "C-9" #'scroll-up-command)
(keymap-global-set "C-0" #'scroll-down-command)
(keymap-global-set "C-l" #'recenter-top-bottom)
;; (keymap-global-set "S-<tab>" #'indent-rigidly-left-to-tab-stop)
;; (keymap-global-set "C-<tab>" #'next-buffer)
;; (keymap-global-set "C-S-<tab>" #'bs-cycle-previous)
(keymap-global-set "C-a" #'back-to-indentation)
(keymap-global-set "C-M-a" #'move-beginning-of-line)
(keymap-global-set "C-v" #'yank)
(keymap-global-set "C-z" #'undo)
(keymap-global-set "C-S-z" #'undo-redo)
(keymap-global-set "C-M-k" #'windmove-up)
(keymap-global-set "C-M-j" #'windmove-down)
(keymap-global-set "C-M-h" #'windmove-left)
(keymap-global-set "C-M-l" #'windmove-right)
(keymap-global-set "M-<f11>" #'toggle-frame-fullscreen)
(keymap-global-set "M-S-l" #'shrink-window-horizontally)
(keymap-global-set "M-S-h" #'enlarge-window-horizontally)
(keymap-global-set "M-S-j" #'shrink-window)
(keymap-global-set "M-S-k" #'enlarge-window)
(keymap-global-set "M-l" #'my-downcase-dwim)
(keymap-global-set "M-r" #'my-upcase-dwim)
(keymap-global-set "M-k" #'my-move-line-up)
(keymap-global-set "M-j" #'my-move-line-down)

(provide 'init-keybind)
