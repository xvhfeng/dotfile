;;; init-window.el --- Window management with ace-window -*- lexical-binding: t; -*-

(require 'windmove)
(require 'transient)

;; 中文说明：Zoom Window 将当前窗口临时最大化，再次调用会精确恢复调用前的
;; 完整窗口布局，适合需要专注查看 Consult 打开结果后快速回到原布局的场景。
;; 上游没有发布 tag，固定到已验证提交，确保新环境由 Straight 获取同一实现。
(use-package zoom-window
  :straight (:host github
             :repo "emacsorphanage/zoom-window"
             :commit "6b3aa468c0523c6b30a658f63537a2ecfeece1de")
  :commands zoom-window-zoom)

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
  "缩小当前窗口宽度；Treemacs 使用其专用接口。"
  (interactive)
  (if (and (derived-mode-p 'treemacs-mode)
           (fboundp 'treemacs-decrease-width))
      (treemacs-decrease-width)
    (shrink-window-horizontally 1)))

(defun my/window-enlarge-horizontally ()
  "增加当前窗口宽度；Treemacs 使用其专用接口。"
  (interactive)
  (if (and (derived-mode-p 'treemacs-mode)
           (fboundp 'treemacs-increase-width))
      (treemacs-increase-width)
    (enlarge-window-horizontally 1)))

(defun my/balance-editor-windows ()
  "均分当前 Frame 的主编辑区窗口，保留 Treemacs 等侧边窗口的尺寸。"
  (interactive)
  ;; Treemacs 在当前配置中使用 side window。只均分主窗口树，避免把
  ;; 侧栏计入普通编辑窗口的份额，也不会改变侧栏的现有宽度。
  (balance-windows (window-main-window)))

(defun my/window-select-wrap (direction)
  "沿 DIRECTION 选择窗口；到 Frame 边缘时从另一端继续。"
  ;; 只让窗口菜单循环，不改变其他模式调用 windmove 时的行为。
  (let* ((windmove-wrap-around t)
         (target (windmove-find-other-window direction)))
    ;; 单窗口时没有可选目标；向下搜索也可能返回未激活的 minibuffer。
    (when (and target (not (window-minibuffer-p target)))
      (select-window target))))

(defun my/window-select-left ()
  "向左循环选择窗口。"
  (interactive)
  (my/window-select-wrap 'left))

(defun my/window-select-down ()
  "向下循环选择窗口。"
  (interactive)
  (my/window-select-wrap 'down))

(defun my/window-select-up ()
  "向上循环选择窗口。"
  (interactive)
  (my/window-select-wrap 'up))

(defun my/window-select-right ()
  "向右循环选择窗口。"
  (interactive)
  (my/window-select-wrap 'right))

(defun my/window--select-buffer-in-new-window (new-window origin-window)
  "在 NEW-WINDOW 选择 Buffer，完成或取消后回到 ORIGIN-WINDOW。"
  (select-window new-window)
  (unwind-protect
      (if (fboundp 'consult-buffer)
          ;; 中文说明：优先复用 Consult 的已打开 Buffer 选择体验；确认后内容
          ;; 留在新窗口，不会替换来源窗口。
          (call-interactively #'consult-buffer)
        ;; Consult 不可用时安全回退到 Emacs 原生已打开 Buffer 选择。
        (switch-to-buffer (read-buffer "新窗口显示 Buffer: " nil t)))
    (when (window-live-p origin-window)
      (select-window origin-window))))

(defun my/window--split-and-select-buffer (side)
  "向 SIDE 分割后在新窗口选择 Buffer，并把光标保持在原窗口。"
  (let* ((origin-window (selected-window))
         (new-window (split-window origin-window nil side)))
    (my/window--select-buffer-in-new-window new-window origin-window)))

(defun my/window-split-left ()
  "向左分割并选择新窗口 Buffer，光标最后留在原窗口。"
  (interactive)
  (my/window--split-and-select-buffer 'left))

(defun my/window-split-right ()
  "向右分割并选择新窗口 Buffer，光标最后留在原窗口。"
  (interactive)
  (my/window--split-and-select-buffer 'right))

(defun my/window-split-up ()
  "向上分割并选择新窗口 Buffer，光标最后留在原窗口。"
  (interactive)
  (my/window--split-and-select-buffer 'above))

(defun my/window-split-down ()
  "向下分割并选择新窗口 Buffer，光标最后留在原窗口。"
  (interactive)
  (my/window--split-and-select-buffer 'below))

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
;; 2. C-w 三列 Transient，与 C-c w General/Which-Key 入口
;; ============================================================================
(transient-define-prefix my/window-menu ()
  "打开按三列排列的窗口操作菜单。"
  :column-widths '(26 32 30)
  [["   选择与移动"
    ("h" "向左循环切换窗口" my/window-select-left)
    ("j" "向下循环切换窗口" my/window-select-down)
    ("k" "向上循环切换窗口" my/window-select-up)
    ("l" "向右循环切换窗口" my/window-select-right)
    ("C-w" "Ace Window：选择窗口" ace-window)]
   ["   空间分割"
    ("a" "左侧分割，留在原窗口" my/window-split-left)
    ("d" "右侧分割，留在原窗口" my/window-split-right)
    ("w" "上方分割，留在原窗口" my/window-split-up)
    ("s" "下方分割，留在原窗口" my/window-split-down)
    ("f" "左侧分割并切换" my-split-left-and-switch)
    ("c" "右侧分割并切换" my-split-right-and-switch)
    ("v" "上方分割并切换" my-split-above-and-switch)
    ("b" "下方分割并切换" my-split-below-and-switch)]
   ["   布局与尺寸"
    ("m" "与目标窗口交换" ace-swap-window)
    ("q" "关闭当前窗口" delete-window)
    ("x" "关闭目标窗口" ace-delete-window)
    ("o" "最大化当前窗口" delete-other-windows)
    ("z" "Zoom 当前窗口/恢复布局" zoom-window-zoom)
    ("=" "均分编辑窗口" my/balance-editor-windows)
    ("r" "调整窗口尺寸" hydra-window-resize/body)]])

;; 中文说明：C-w 只负责打开上方 Transient，不经过 General；C-c w 的同一批
;; 命令仍由 `my-window-map' 提供 Which-Key 可发现的直接键位。
(keymap-global-set "C-w" #'my/window-menu)

(with-eval-after-load 'general
  (my-window-def
    ;; 窗口方向移动
    "h" '("向左循环切换窗口" . my/window-select-left)
    "j" '("向下循环切换窗口" . my/window-select-down)
    "k" '("向上循环切换窗口" . my/window-select-up)
    "l" '("向右循环切换窗口" . my/window-select-right)

    ;; 第一列：方向移动与 C-w C-w 窗口选择。
    "C-w" '("Ace Window：选择窗口" . ace-window)

    ;; 第二列：小写分割后选 Buffer 并回到原窗口；fcvb 分割后直接切换。
    "a" '("左侧分割，选择 Buffer 后返回" . my/window-split-left)
    "d" '("右侧分割，选择 Buffer 后返回" . my/window-split-right)
    "w" '("上方分割，选择 Buffer 后返回" . my/window-split-up)
    "s" '("下方分割，选择 Buffer 后返回" . my/window-split-down)
    "f" '("左侧分割并切换" . my-split-left-and-switch)
    "c" '("右侧分割并切换" . my-split-right-and-switch)
    "v" '("上方分割并切换" . my-split-above-and-switch)
    "b" '("下方分割并切换" . my-split-below-and-switch)

    ;; 第三列：交换、关闭、布局与尺寸调整。
    "m" '("与目标窗口交换" . ace-swap-window)
    "q" '("关闭当前窗口" . delete-window)
    "x" '("关闭目标窗口" . ace-delete-window)
    "o" '("最大化当前窗口" . delete-other-windows)
    ;; 中文说明：再次执行同一命令会恢复 Zoom 前保存的完整窗口布局。
    "z" '("Zoom 当前窗口/恢复布局" . zoom-window-zoom)

    ;; 窗口尺寸
    "=" '("均分编辑窗口（不含 Treemacs）" . my/balance-editor-windows)
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
;; - `C-w' 打开严格三列的 Transient：第一列选择/移动，第二列空间分割，第三列
;;   交换、关闭、布局和尺寸；按 ESC 或 C-g 退出。
;; - `C-c w' 使用 General/Which-Key 的直接窗口命令，按键与 C-w Transient 对应。
;; - 小写 `a/d/w/s' 分割后会在新窗口用 Consult 选择已打开 Buffer，并自动回到来源窗口；
;;   `f/c/v/b' 分割后直接切换到新窗口。
;; - `r' 进入尺寸调整，随后用 h/j/k/l 或方向键调整，q 退出；选中 Treemacs 时使用专用宽度接口。
;; - 工作台按 W、窗口菜单按 C-w z 切换 Zoom 当前窗口与恢复原布局。
;; - Ace Window 会把 Treemacs 也列为候选；Dimmer 自动变暗非活动窗口以突出当前窗口。
;;; init-window.el ends here
