;;; init-vundo.el --- Visual Undo Tree with Vundo -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Vundo 核心配置与字符集设置
;; ============================================================================
(use-package vundo
  :straight t
  :general
  ("C-x u" '("visual undo tree" . vundo))
  (:keymaps 'vundo-mode-map
   "h" '("previous branch" . vundo-backward)
   "l" '("next branch" . vundo-forward)
   "j" '("next node" . vundo-next)
   "k" '("previous node" . vundo-previous)
   "a" '("branch root" . vundo-stem-root)
   "e" '("branch end" . vundo-stem-end)
   "d" '("show diff" . vundo-diff)
   "q" '("quit" . vundo-quit)
   "C-g" '("confirm" . vundo-confirm)
   "RET" '("confirm" . vundo-confirm))
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
    "u" '("undo tree (vundo)" . vundo)))

(provide 'init-vundo)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-x u' 或 `C-c u' 打开当前 Buffer 的可视撤销树。
;; - 树中 `h/l' 切换前后分支，`j/k' 移到下/上节点，`a/e' 到分支根/末端。
;; - `d' 查看所选节点差异；`RET' 或 `C-g' 确认选中状态，`q' 放弃并退出。
;; - 撤销树使用 Unicode 线条与紧凑布局，底部窗口最大高度为 12 行。
;;; init-vundo.el ends here
