;;; init-vundo.el --- Visual Undo Tree with Vundo -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Vundo 核心配置与字符集设置
;; ============================================================================
(use-package vundo
  :straight t
  :general
  ("C-x u" '(vundo :which-key "visual undo tree"))
  (:keymaps 'vundo-mode-map
   "h" '(vundo-backward :which-key "previous branch")
   "l" '(vundo-forward :which-key "next branch")
   "j" '(vundo-next :which-key "next node")
   "k" '(vundo-previous :which-key "previous node")
   "a" '(vundo-stem-root :which-key "branch root")
   "e" '(vundo-stem-end :which-key "branch end")
   "d" '(vundo-diff :which-key "show diff")
   "q" '(vundo-quit :which-key "quit")
   "C-g" '(vundo-confirm :which-key "confirm")
   "RET" '(vundo-confirm :which-key "confirm"))
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

;; Leader 键入口。
(with-eval-after-load 'general
  (my-leader-def
    "u" '(vundo :which-key "undo tree (vundo)")))

(provide 'init-vundo)
;;; init-vundo.el ends here
