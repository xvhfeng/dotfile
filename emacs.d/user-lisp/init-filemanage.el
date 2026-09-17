;;; -*- lexical-binding: t -*-

(defconst nn-neotree-icon-font-family "JetBrainsMono Nerd Font Mono"
  "Installed Nerd Font used only by Neotree buffers.")

(defun nn-neotree-setup-buffer ()
  "Apply buffer-local display settings for Neotree."
  (setq-local nerd-icons-font-family nn-neotree-icon-font-family)
  (setq-local window-size-fixed nil))

(defun nn-neotree-enable-resizing (&rest _)
  "Remove width constraints from the Neotree side window."
  (when-let* ((window (get-buffer-window neo-buffer-name)))
    (with-current-buffer (window-buffer window)
      (setq-local window-size-fixed nil))
    (window-preserve-size window t nil)))

(defun nn-neotree--goto-node-on-current-line ()
  "Move point onto the node button on the current line, if present."
  (when-let* ((button (neo-buffer--get-button-current-line)))
    (goto-char (button-start button))
    button))

(defun nn-neotree-enter (&optional arg)
  "Open the node on the current line, including from its indentation."
  (interactive "P")
  (when (nn-neotree--goto-node-on-current-line)
    (neotree-enter arg)))

(defun nn-neotree-toggle-directory (&optional arg)
  "Toggle the directory on the current line from any column."
  (interactive "P")
  (when (nn-neotree--goto-node-on-current-line)
    (neo-buffer--execute arg nil #'neo-open-dir)))

(defun nn-neotree-quick-look (&optional arg)
  "Quick-look the node on the current line from any column."
  (interactive "P")
  (when (nn-neotree--goto-node-on-current-line)
    (neotree-quick-look arg)))

(defun nn-neotree-resize (columns)
  "Resize the Neotree window horizontally by COLUMNS."
  (when-let* ((window (get-buffer-window neo-buffer-name)))
    (with-selected-window window
      (window-preserve-size window t nil)
      (setq window-size-fixed nil)
      (enlarge-window-horizontally columns))))

(defun nn-neotree-enlarge (&optional count)
  "Enlarge Neotree by five columns times COUNT."
  (interactive "p")
  (nn-neotree-resize (* 5 (or count 1))))

(defun nn-neotree-shrink (&optional count)
  "Shrink Neotree by five columns times COUNT."
  (interactive "p")
  (nn-neotree-resize (* -5 (or count 1))))

(use-package neotree
  :ensure t
  :hook (neotree-mode . nn-neotree-setup-buffer)
  :init (setq neo-window-width 35
              neo-window-fixed-size nil
              neo-show-hidden-file t
          neo-auto-indent-point t
          neo-theme (if (display-graphic-p) 'nerd-icons 'arrow))
  :bind (("C-x t n" . neotree-toggle)
         :map neotree-mode-map
         ("RET" . nn-neotree-enter)
         ("TAB" . nn-neotree-toggle-directory)
         ("SPC" . nn-neotree-quick-look)
         ("<backspace>" . neotree-select-up-node)
         ("DEL" . neotree-select-up-node)
         ("C-<right>" . nn-neotree-enlarge)
         ("C-<left>" . nn-neotree-shrink))
  :config
  (add-hook 'neo-after-create-hook #'nn-neotree-enable-resizing))

(provide 'init-filemanage)
;;  C-x t n: 打开/关闭 neotree
;;  p, n: 文件目录间上下移动
;;  SPC/RET/TAB: 这三个快捷键都可以打开文件或展开目录
;;  Backspace: 跳转到当前节点的父目录
;;  C-<left>/C-<right>: 缩小/放大 neotree 窗口
;;  U: 跳转到上一级目录
;;  g: 刷新
;;  H: 显示或隐藏 隐藏文件(dotfiles)
;;  O: 打开目录下的所有目录结构
;;  A: 最大化/最小化neotree窗口
;;  C-c C-n: 创建文件或目录(以"/"结尾)
;;  C-c C-d: 删除文件或目录
;;  C-c C-r: 重命名文件后目录
;;  C-c C-c: 设置当前目录为展示的根目录
;;  C-c C-p: 复制文件或目录
