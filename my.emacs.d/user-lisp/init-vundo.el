;;; init-vundo.el --- Visual Undo Tree with Vundo -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Vundo 核心配置与字符集设置
;; ============================================================================
(use-package vundo
  :straight t
  :custom
  ;; 限制分支树高亮显示的节点数量，提升大文件或历史记录较长时的渲染性能
  (vundo-compact-display t)
  ;; 限制底部撤销树窗口的最大高度占比
  (vundo-window-max-height 12)

  :config
  ;; `vundo-unicode-symbols' 由 Vundo 自身定义，因此必须在包加载后读取。
  ;; 旧写法 `vundo-glyphs-unicode' 在当前 Vundo 中不存在，会中断启动。
  (setq vundo-glyph-alist vundo-unicode-symbols)

  ;; 自定义撤销树节点的字体样式（可选）
  (set-face-attribute 'vundo-default nil :family "Monospace" :height 1.0))

;; ============================================================================
;; 2. Vundo 交互面板内的导航与操作按键绑定
;; ============================================================================
(with-eval-after-load 'vundo
  ;; 支持使用 Vim 习惯 (Hjkl) 与 Emacs 方向键无缝导航撤销树
  (define-key vundo-mode-map (kbd "h") #'vundo-backward)
  (define-key vundo-mode-map (kbd "l") #'vundo-forward)
  (define-key vundo-mode-map (kbd "j") #'vundo-next)
  (define-key vundo-mode-map (kbd "k") #'vundo-previous)
  (define-key vundo-mode-map (kbd "a") #'vundo-stem-root)
  (define-key vundo-mode-map (kbd "e") #'vundo-stem-end)
  (define-key vundo-mode-map (kbd "d") #'vundo-diff)      ; 对比当前节点与基准节点的 diff 差异
  (define-key vundo-mode-map (kbd "q") #'vundo-quit)      ; 退出并停留在当前选中的历史状态
  (define-key vundo-mode-map (kbd "C-g") #'vundo-confirm) ; 确认选中节点并关闭撤销树
  (define-key vundo-mode-map (kbd "RET") #'vundo-confirm))

;; ============================================================================
;; 3. 全局快捷键与 Leader 键体系挂载
;; ============================================================================
;; 覆盖 Emacs 原生默认的 C-x u (advertised-undo) 快捷键
(global-set-key (kbd "C-x u") #'vundo)

;; 保持与 General.el 的 Leader 键同步 (提供 SPC u 唤出方案)
(with-eval-after-load 'general
  (my-leader-def
    "u" '(vundo :which-key "undo tree (vundo)")))

(provide 'init-vundo)
;;; init-vundo.el ends here
