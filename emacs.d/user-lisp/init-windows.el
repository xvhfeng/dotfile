;;; -*- lexical-binding: t -*-

(use-package posframe
  :defer t)

(use-package ace-window
  :bind (("M-o" . ace-window))
  :custom
  (aw-background t)
  (aw-keys '(?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9))
  :custom-face
  (aw-leading-char-face
   ((t (:foreground "#ff3b30"
        :background "#1c1c1e"
        :weight bold
        :height 4.0))))
  :config
  (when (display-graphic-p)
    (require 'ace-window-posframe)
    (ace-window-posframe-mode 1)))

(provide 'init-windows)
