;;; init-modeline.el --- Doom-modeline setup with custom elements -*- lexical-binding: t; -*-

(use-package nerd-icons
  :straight t
  :demand t
  :custom
  ;; Doom Modeline 默认使用 Symbols Nerd Font Mono，但本机安装的是
  ;; JetBrainsMono Nerd Font Mono。显式指定现有字体，避免图标显示成方框或乱码。
  (nerd-icons-font-family "JetBrainsMono Nerd Font Mono"))

(use-package doom-modeline
  :straight t
  :demand t
  :custom
  ;; 基础外观。
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-color-icon t)

  ;; 文件与 Git。
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-vcs-max-length 12)
  (doom-modeline-minor-modes nil)

  ;; 面向编程的右侧信息：LSP、诊断、缩进方式以及非默认编码。
  (doom-modeline-lsp t)
  (doom-modeline-check 'auto)
  (doom-modeline-indent-info t)
  (doom-modeline-buffer-encoding 'nondefault)

  ;; 时间保留纯文本即可，关闭重复且信息量低的时钟图标。
  (doom-modeline-time-icon nil)
  (doom-modeline-time-live-icon nil)

  :config
  (setq display-time-format "%H:%M"
        display-time-default-load-average nil)
  (display-time-mode 1)
  (doom-modeline-mode 1))

(provide 'init-modeline)
;;; init-modeline.el ends here
