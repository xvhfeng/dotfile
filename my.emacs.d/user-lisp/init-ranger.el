;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; Ranger: 类似终端 Ranger 的文件管理器 (整合 Dired + 实时预览)
;; ============================================================================

(use-package ranger
  :straight (:host github :repo "punassuming/ranger.el")
  :after dired
  :bind (:map dired-mode-map
              ;; 在 Dired 模式下按 "r" 瞬间切入/切换 Ranger 预览视图
              ("r" . ranger-mode)
              :map global-map
              ;; 全局快捷键 C-c r 打开 Ranger 文件浏览器
              ("C-c r" . ranger))
  
  :custom
  ;; 1. 默认在启动 dired 时自动开启 ranger 模式 (可根据喜好设为 t 或 nil)
  (ranger-override-dired t)

  ;; 2. 界面与外观优化
  (ranger-show-hidden t)             ; 默认显示隐藏文件 (点开头的文件)
  (ranger-cleanup-on-disable t)      ; 关闭 ranger 时自动清理后台产生的临时预览 Buffer
  (ranger-max-preview-size 10)       ; 限制文本预览最大尺寸为 10MB，防止大文件卡顿
  (ranger-dont-show-binary t)        ; 遇到二进制文件时不进行预览渲染，提升流畅度
  
  ;; 3. 布局设置 (三栏式或两栏式)
  (ranger-parent-depth 1)            ; 左侧上级目录列数
  (ranger-preview-file t)            ; 开启右侧文件内容实时预览
  
  :config
  ;; 自动跟随主主题颜色，保持界面统一
  (setq ranger-header-func 'ranger-header-line))

(use-package all-the-icons
  :straight t
  :if (display-graphic-p))

(provide 'init-ranger)
