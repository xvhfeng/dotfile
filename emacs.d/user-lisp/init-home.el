;;; -*- lexical-binding: t -*-

;;; 中文导读：实现自定义首页/启动面板，汇总常用入口、最近文件、项目信息或快捷
;;; 操作，并处理按钮与页面刷新。C-F1 随时打开 `nn-home-show'，作为比默认启动页
;;; 更贴合这套配置的导航中心。
(require 'recentf)
(require 'bookmark)
;; 启用最近文件记录，首页据此生成“最近文件”分组。
(recentf-mode 1)

(defconst nn-home-buffer-name "*HOME*")
(defconst nn-home-logo (create-image (concat user-lisp-directory "logo.png")))
(defconst nn-home-emacs-init-string
  (propertize
   (format "%d packages loaded in %s"
           (length package-activated-list)
           (emacs-init-time))
   'face '(:inherit font-lock-type-face :height 0.8)))

(defvar-keymap nn-home-keymap
  "q" #'kill-emacs
  "n" #'nn-home-next-line
  "p" #'nn-home-previous-line
  "g" #'nn-home-refresh
  "<up>" #'nn-home-previous-line
  "<down>" #'nn-home-next-line
  "<return>" #'nn-home-return-action)

;; 返回首页中 GROUP-NAME 分组正文的起止位置，供展开/折叠修改文本属性。
(defun nn-home-group-range (group-name)
  (save-excursion
    (forward-line 1)
    (let ((start (point)))
      (while (and (not (eobp))
                  (equal (get-text-property (point) 'nn-group-member)
                         group-name))
        (forward-line 1))
      (cons start (point)))))

;; 展开 GROUP-NAME 分组，清除该区域的隐藏属性。
(defun nn-home-expand-group (group-name)
  (let ((inhibit-read-only t)
        (range (nn-home-group-range group-name)))
    (mapc #'delete-overlay (overlays-in (car range) (cdr range)))
    (put-text-property (line-beginning-position) (line-end-position) 'nn-group-open t)))

;; 折叠 GROUP-NAME 分组，隐藏标题下的条目。
(defun nn-home-collapse-group (group-name)
  (let* ((inhibit-read-only t)
         (range (nn-home-group-range group-name))
         (overlay (make-overlay (car range) (cdr range))))
    (overlay-put overlay 'invisible t)
    (overlay-put overlay 'nn-group-overlay t)
    (overlay-put overlay 'nn-group-name group-name)
    (put-text-property (line-beginning-position) (line-end-position) 'nn-group-open nil)))

;; 根据光标所在分组的当前状态切换展开或折叠。
(defun nn-home-toggle-group ()
  (let ((group-name (get-text-property (point) 'nn-group-name)))
    (if (get-text-property (point) 'nn-group-open)
        (nn-home-collapse-group group-name)
      (nn-home-expand-group group-name))))

;; 在首页按 RET 时执行光标处按钮/条目的动作，标题处则切换分组。
(defun nn-home-return-action ()
  (interactive)
  (let ((item (get-text-property (point) 'nn-item-data)))
    (cond
     ((get-text-property (point) 'nn-group-header)
      (nn-home-toggle-group))
     (item
      (funcall (get-text-property (point) 'nn-item-action) item)))))

;; 判断光标当前是否位于可交互的首页条目上。
(defun nn-home--entry-p ()
  (and (not (invisible-p (point)))
       (or (get-text-property (point) 'nn-group-header)
           (get-text-property (point) 'nn-item-data))))

;; 按 DIRECTION 向前或向后移动到下一个可交互首页条目。
(defun nn-home--move-to-entry (direction)
  (let ((origin (point)))
    (when (or (> direction 0)
              (> (line-beginning-position) (point-min)))
      (forward-line direction)
      (while (and (not (nn-home--entry-p))
                  (if (> direction 0)
                      (not (eobp))
                    (> (point) (point-min))))
        (forward-line direction))
      (if (nn-home--entry-p)
          (skip-chars-forward " \t" (line-end-position))
        (goto-char origin)))))

;; 移到首页中的下一个可交互条目。
(defun nn-home-next-line ()
  (interactive)
  (nn-home--move-to-entry 1))

;; 移到首页中的上一个可交互条目。
(defun nn-home-previous-line ()
  (interactive)
  (nn-home--move-to-entry -1))

;; 插入一个名为 GROUP-NAME 的首页分组，并为 ITEMS 绑定可选 ITEM-ACTION。
(defun nn-home-insert-group (group-name items &optional item-action)
  (let ((action (or item-action #'find-file)))
    (let ((start (point)))
      (insert group-name "\n")
      (add-text-properties
       start (point)
       `(nn-group-header t nn-group-name ,group-name
         nn-group-open t
         face (:inherit font-lock-keyword-face))))
    (dolist (item items)
      (let ((start (point))
            (line (truncate-string-to-width
                   (format " %s" item) 64 nil nil nn-fold-string)))
        (insert line "\n")
        (add-text-properties
         start (point)
         `(nn-group-member ,group-name nn-item-data ,item
           nn-item-action ,action))))))

;; 根据窗口宽度设置首页左右边距，使内容块居中显示。
(defun nn-home-set-margins ()
  (let* ((win (get-buffer-window nn-home-buffer-name))
         (w (window-total-width win)))
    (with-current-buffer nn-home-buffer-name
      (setq-local left-margin-width (floor (- w (* w 0.25)) 2)))
    (set-window-buffer win (get-buffer nn-home-buffer-name))))

;; 创建或取得首页缓冲区，并初始化其 major mode 与只读等属性。
(defun nn-home-create ()
  (with-current-buffer (get-buffer-create nn-home-buffer-name)
    (setq-local header-line-format nil
                mode-line-format nil
                display-line-numbers-mode nil)
    (use-local-map nn-home-keymap)
    (read-only-mode)
    (add-hook 'kill-buffer-query-functions #'ignore nil t)
    (add-hook 'window-size-change-functions
              (lambda (&rest _)
                (when (get-buffer-window nn-home-buffer-name)
                  (nn-home-set-margins))))))

;; 清空并重新生成首页标题、分组和条目内容。
(defun nn-home-render ()
  (with-current-buffer nn-home-buffer-name
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "\n")
      (insert-image nn-home-logo)
      (insert "\n")
      (insert nn-home-emacs-init-string)
      (insert "\n\n")
      (nn-home-insert-group
       "Config"
       `(,user-emacs-directory ,user-lisp-directory))
      (insert "\n")
      (nn-home-insert-group
       "Recent Files"
       (seq-take recentf-list recentf-max-saved-items))
      (insert "\n")
      (nn-home-insert-group
       "Bookmarks"
       (bookmark-all-names)
       #'bookmark-jump))))

;; 显示自定义首页缓冲区，并在需要时先创建/渲染它。
(defun nn-home-show ()
  (interactive)
  (when (get-buffer nn-home-buffer-name)
    (switch-to-buffer nn-home-buffer-name)))

;; 刷新首页内容，同时尽量保留当前窗口和光标位置。
(defun nn-home-refresh ()
  (interactive)
  (when (eq (current-buffer) (get-buffer nn-home-buffer-name))
    (nn-home-render)))

(nn-home-create)
(nn-home-set-margins)
(nn-home-render)
(nn-home-show)
(goto-char (point-min))
(nn-home-next-line)

(keymap-global-set "C-<f1>" #'nn-home-show)

(provide 'init-home)
