;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; Ranger: 类似终端 Ranger 的文件管理器 (整合 Dired + 实时预览)
;; ============================================================================

(use-package ranger
  :straight (:host github :repo "punassuming/ranger.el")

  :bind ("C-c r" . ranger)
  
  :custom
  ;; 1. 是否在启动 dired 时自动替换为 ranger 界面（建议先设为 nil，用 C-c r 手动调出）
  (ranger-override-dired nil)

  ;; 2. 界面与外观优化
  (ranger-show-hidden t)             ; 显示隐藏文件
  (ranger-cleanup-on-disable t)      ; 关闭时清理后台临时 Buffer
  (ranger-max-preview-size 10)       ; 限制文件预览大小为 10MB
  (ranger-dont-show-binary t)        ; 不预览二进制文件
  (ranger-parent-depth 1)            ; 左侧父目录深度
  (ranger-preview-file t)            ; 开启右侧文件预览
(ranger-show-literal t)              ; 开启排版美化

  :config
;; 核心修复：强制在启动 ranger 时加载图标渲染
  (add-hook 'ranger-mode-hook
            (lambda ()
              (when (display-graphic-p)
                (all-the-icons-dired-mode 1))))


  ;; 设置标题栏样式
  (setq ranger-header-func 'ranger-header-line))




(use-package all-the-icons
  :straight t
  :if (display-graphic-p))


;; 2. 为 Dired / Ranger 注入图标渲染（核心关键！）
(use-package all-the-icons-dired
  :straight t
  :after (all-the-icons dired)
  :hook (dired-mode . all-the-icons-dired-mode))


(provide 'init-ranger)
