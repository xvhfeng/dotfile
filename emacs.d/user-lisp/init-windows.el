;;; -*- lexical-binding: t -*-

;;; 中文导读：窗口选择模块。Ace Window 给每个可见窗口显示数字提示，按 M-o 后再
;;; 按 1–9 即可直接跳转；Posframe 在图形界面把提示绘制成独立悬浮 frame，
;;; `aw-background' 会暂时压暗未选窗口以突出目标。

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
    ;; 图形界面下把 Ace Window 的选择字符显示在 posframe 浮窗中。
    (ace-window-posframe-mode 1)))

(provide 'init-windows)
