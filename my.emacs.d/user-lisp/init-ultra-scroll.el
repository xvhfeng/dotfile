;;; init-ultra-scroll.el --- High-performance smooth scrolling -*- lexical-binding: t; -*-

;; 保留 init.el 中已有的滚动距离、边缘留白和鼠标速度设置；Ultra Scroll
;; 只接管像素级滚动路径，不改变现有按键与滚轮偏好。
(let ((build-directory
       (my/runtime-file "straight/build/ultra-scroll/")))
  ;; 迁移 Straight 后，已运行 Emacs 的内部路径缓存可能仍指向旧目录；
  ;; 显式注册新 build 路径，确保重载配置时也能立即找到插件。
  (when (file-directory-p build-directory)
    (add-to-list 'load-path build-directory))
  ;; 不经 use-package/straight 的延迟路径加载。这样正在运行的旧会话即使
  ;; 仍缓存了迁移前的 Straight 状态，也会直接使用上面已验证的 build 文件。
  ;; 始终登记 recipe，确保 Straight profile/版本锁定记录该依赖；首次启动
  ;; 会先安装，后续启动仅复用既有 build。
  (when (fboundp 'straight-use-package)
    (straight-use-package
     '(ultra-scroll :type git :host github :repo "jdtsmith/ultra-scroll")))
  (require 'ultra-scroll nil t)
  (if (featurep 'ultra-scroll)
      (ultra-scroll-mode 1)
    (message "Ultra Scroll 安装或加载失败")))

(provide 'init-ultra-scroll)
;;; init-ultra-scroll.el ends here
