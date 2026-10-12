;;; init-window.el --- Window management with ace-window -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Ace-Window: 窗口快速跳转、关闭、交换与切分核心
;; ============================================================================
(use-package ace-window
  :straight t
  :custom
  ;; 设置窗口选择标签：优先使用键盘 Home Row（中排按键），击键最快
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

  ;; 作用域：只在当前 Frame（窗口帧）内选择，避免跳到其他 Monitor/Frame
  (aw-scope 'frame)

  ;; 只有 2 个窗口时也强制显示编号标签，保持逻辑一致（默认 2 个窗口会自动直接跳转）
  (aw-dispatch-always t)

  :config
  ;; 自定义 Ace-Window 的快捷 Dispatch 动作列表 (按下 M-o 后，再按以下字母执行动作)：
  ;;  x - 关闭窗口 (Delete Window)
  ;;  m - 移动/交换窗口 (Swap Window)
  ;;  c - 复制当前 Buffer 到目标窗口 (Copy Window)
  ;;  v - 竖向切分 (Split Vertically / Side-by-side)
  ;;  b - 横向切分 (Split Horizontally / Below)
  ;;  o - 全屏化当前窗口 (Maximize / Delete Other Windows)
  (setq aw-dispatch-alist
        '((?x aw-delete-window "Delete Window")
          (?m aw-swap-window "Swap Window")
          (?c aw-copy-window "Copy Window")
          (?v aw-split-window-vert "Split Vertically")
          (?b aw-split-window-horiz "Split Horizontally")
          (?o delete-other-windows "Maximize Window")
          (?? aw-show-dispatch-help))))


(use-package hydra
  :straight t
  :config
  ;; 定义一个专门用于调整窗口大小的 Transient Hydra 键盘态
  (defhydra hydra-window-resize (:hint nil)
;;    "
;;  ^Resizing Window^
;;  -----------------------------------------
;;  _h_ / _<left>_  : 缩小宽度 (Narrow)
;;  _l_ / _<right>_ : 放大宽度 (Widen)
;;  _k_ / _<up>_    : 缩小高度 (Shrink)
;;  _j_ / _<down>_  : 放大高度 (Enlarge)
;;  _=_             : 均分所有窗口 (Balance)
;;  _q_ / _<return>_: 退出 (Quit)
;;  "
    ("h" shrink-window-horizontally)
    ("l" enlarge-window-horizontally)
    ("j" enlarge-window)
    ("k" shrink-window)
    ("<up>" shrink-window)
    ("=" balance-windows)
    ("q" nil :exit t)
    ("<return>" nil :exit t)))

;; ============================================================================
;; 2. 将所有窗口操作集中到 C-c w（C-t 是同一 keymap 的别名）
;; ============================================================================
(with-eval-after-load 'general
  (my-window-def
    ;; 窗口方向移动
    "h" '(windmove-left           :which-key "move left")
    "j" '(windmove-down           :which-key "move down")
    "k" '(windmove-up             :which-key "move up")
    "l" '(windmove-right          :which-key "move right")

    ;; 窗口选择与交换
    "w" '(ace-window              :which-key "ace window select/jump")
    "M" '(ace-swap-window         :which-key "swap window with target")

    ;; 窗口切分
    "v" '(split-window-right      :which-key "split vertically (|)")
    "s" '(split-window-below      :which-key "split horizontally (-)")
    "b" '(split-window-below      :which-key "split horizontally (-)")

    ;; 窗口关闭与全屏
    "d" '(delete-window           :which-key "delete current window")
    "x" '(ace-delete-window       :which-key "delete target window")
    "m" '(delete-other-windows    :which-key "maximize current window")
    "o" '(delete-other-windows    :which-key "delete other windows")

    ;; 窗口尺寸
    "r" '(hydra-window-resize/body :which-key "resize window mode")
    "=" '(balance-windows          :which-key "balance windows size")))

(use-package dimmer
  :straight t
  :custom
  ;; 设置非活动窗口的变暗比例（0.0 到 1.0 之间，数值越小背景压得越暗）
  ;; 0.15 - 0.25 是一个既能清晰区分主次，又不会看不清文字的黄金区间
  (dimmer-fraction 0.35)

;; 2. 更改调整模式：使用更明显的颜色计算方式
  ;; 可选值有 :foreground, :background, 或组合。使用 background 调整背景色对比度最高
  (dimmer-adjustment-mode :background)

  ;; 排除某些特定的特殊窗口（如 Which-key、Help、Side 窗口等），避免不必要的闪烁
  (dimmer-exclusion-regexps
   '("^ \\*which-key\\*"
     "^\\*Minibuf"
     "^\\* компас"
     "^\\*Completions\\*"))

  :config
  ;; 开启全局 Dimmer 模式
  (dimmer-mode t))


(provide 'init-window)
;;; init-window.el ends here
