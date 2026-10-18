;;; init-good-scroll.el --- Smooth pixel scrolling -*- lexical-binding: t; -*-

;; 使用定时渲染的像素级平滑滚动，不依赖输入设备提供连续 PIXEL-DELTA。
(use-package good-scroll
  :straight (:host github :repo "io12/good-scroll.el")
  :demand t
  :config
  (good-scroll-mode 1))

(provide 'init-good-scroll)
;;; init-good-scroll.el ends here
