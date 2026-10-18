;;; init-ultra-scroll.el --- High-performance smooth scrolling -*- lexical-binding: t; -*-

;; 保留 init.el 中已有的滚动距离、边缘留白和鼠标速度设置；Ultra Scroll
;; 只接管像素级滚动路径，不改变现有按键与滚轮偏好。
(use-package ultra-scroll
  :straight (:host github :repo "jdtsmith/ultra-scroll")
  :demand t
  :config
  (ultra-scroll-mode 1))

(provide 'init-ultra-scroll)
;;; init-ultra-scroll.el ends here
