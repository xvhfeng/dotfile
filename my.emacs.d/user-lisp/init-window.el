;;; init-window.el --- Window management with ace-window -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Ace-Window: 窗口快速跳转、关闭、交换与切分核心
;; ============================================================================
(use-package ace-window
  :straight t
  :custom
  ;; 设置窗口选择标签：优先使用键盘 Home Row（中排按键），击键最快
  ;; (aw-keys '(?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9))

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

;; Treemacs 的兼容层默认会把 `treemacs-mode' 加进
;; `aw-ignored-buffers'，导致侧栏不参与 ace-window 的候选选择。
;; 同时等待 Treemacs 和 ace-window 加载完成，既避免加载顺序造成变量未定义，
;; 也确保移除动作发生在 Treemacs 的兼容代码之后。
(with-eval-after-load 'treemacs
  (with-eval-after-load 'ace-window
    (setq aw-ignored-buffers
          (delq 'treemacs-mode aw-ignored-buffers))))

(defun my/window-shrink-horizontally ()
  "Shrink the selected window, using Treemacs' own width API when needed."
  (interactive)
  (if (and (derived-mode-p 'treemacs-mode)
           (fboundp 'treemacs-decrease-width))
      (treemacs-decrease-width)
    (shrink-window-horizontally 1)))

(defun my/window-enlarge-horizontally ()
  "Enlarge the selected window, using Treemacs' own width API when needed."
  (interactive)
  (if (and (derived-mode-p 'treemacs-mode)
           (fboundp 'treemacs-increase-width))
      (treemacs-increase-width)
    (enlarge-window-horizontally 1)))

(use-package hydra
  :straight t
  ;; 全局开启了 `use-package-always-defer'；这里必须立即加载，
  ;; 否则 `defhydra' 不会执行，按键只会指向一个未定义的符号。
  :demand t
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
;;  _q_ / _<return>_: 退出 (Quit)
;;  "
    ("h" my/window-shrink-horizontally)
    ("l" my/window-enlarge-horizontally)
    ("j" enlarge-window)
    ("k" shrink-window)
    ("<left>" my/window-shrink-horizontally)
    ("<right>" my/window-enlarge-horizontally)
    ("<down>" enlarge-window)
    ("<up>" shrink-window)
    ("q" nil :exit t)
    ("<return>" nil :exit t)))

;; ============================================================================
;; 2. 将所有窗口操作集中到 C-w（C-c w 是兼容入口）
;; ============================================================================
(with-eval-after-load 'general
  (my-window-def
    ;; 窗口方向移动
    "h" '("向左切换窗口" . windmove-left)
    "j" '("向下切换窗口" . windmove-down)
    "k" '("向上切换窗口" . windmove-up)
    "l" '("向右切换窗口" . windmove-right)

    ;; Ace Window 选择与窗口交换。
    "C-w" '("Ace Window：选择窗口" . ace-window)
    "M" '("与目标窗口交换" . ace-swap-window)

    ;; 窗口切分
    "v" '("左右分割窗口" . split-window-right)
    "s" '("上下分割窗口" . split-window-below)
    ;; init-mykey.el 的方向分屏命令在创建后立即进入新窗口。
    "f" '("右侧分割并切换" . my-split-right-and-switch)
    "b" '("左侧分割并切换" . my-split-left-and-switch)
    "n" '("下方分割并切换" . my-split-below-and-switch)
    "p" '("上方分割并切换" . my-split-above-and-switch)

    ;; 窗口关闭与全屏
    "d" '("关闭当前窗口" . delete-window)
    "x" '("关闭目标窗口" . ace-delete-window)
    "m" '("最大化当前窗口" . delete-other-windows)
    "o" '("关闭其他窗口" . delete-other-windows)

    ;; 窗口尺寸
    "r" '("调整窗口大小" . hydra-window-resize/body)))

(use-package dimmer
  :straight t
  ;; 全局启用了 `use-package-always-defer'，必须主动加载，否则下面的
  ;; `dimmer-mode' 永远不会执行。
  :demand t
  :custom
  ;; 非活动窗口的背景向前景色靠近 35%，让当前窗口保持原色并明显突出。
  (dimmer-fraction 0.2)
  (dimmer-adjustment-mode :background)
  ;; 不要在 Emacs 失去系统焦点时把所有窗口一起变暗，否则当前窗口也会失去强调。
  (dimmer-watch-frame-focus-events nil)

  :config
  ;; 使用 Dimmer 提供的兼容配置，保留 minibuffer/echo-area 的默认排除项。
  (dimmer-configure-which-key)
  (dimmer-configure-hydra)
  (dimmer-configure-magit)
  (dimmer-mode 1))


(provide 'init-window)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 普通 Buffer 的窗口命令可用 `C-w ...' 或 `C-c w ...'，两者等价。
;; - `C-w C-w' 使用 Ace Window 选择窗口。
;; - `h/j/k/l' 移动窗口焦点；`M' 与目标窗口交换。
;; - `v/s' 左右/上下分屏但不移动；`f/b/n/p' 向右/左/下/上分屏并进入新窗口。
;; - `d' 关闭当前窗口，`x' 选择后关闭目标窗口。
;; - `m' 或 `o' 最大化当前窗口；`r' 进入尺寸调整，随后用 h/j/k/l 或方向键调整，q 退出。
;; - 调整尺寸只改变当前窗口，不做窗口均分；选中 Treemacs 时会调用其专用宽度接口。
;; - Ace Window 会把 Treemacs 也列为候选；Dimmer 自动变暗非活动窗口以突出当前窗口。
;;; init-window.el ends here
