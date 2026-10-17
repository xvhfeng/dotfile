;;; init-avy.el --- Avy (EasyMotion) configuration -*- lexical-binding: t; -*-

(require 'transient)

;; Transient 在显示菜单时需要后缀命令可解析；Avy 本身仍按需加载。
(dolist (command '(avy-goto-char-timer avy-goto-char avy-goto-line
                  avy-goto-word-1 avy-goto-symbol-1))
  (autoload command "avy" nil t))

(defconst my/avy-dispatch-display-buffer-name " *Avy Dispatch*"
  "Buffer name for the passive Avy dispatch Transient display.")

(defconst my/avy-dispatch-display-buffer-action
  '((display-buffer-in-side-window)
    (side . bottom)
    ;; 使用独立的底部槽位和固定高度。`fit-window-to-buffer' 在刚关闭
    ;; 上一个 Transient 后可能沿用其很小的窗口高度，导致菜单实际创建了
    ;; 却看不见。
    (slot . -1)
    (window-height . 0.24)
    (preserve-size . (nil . t)))
  "Display action used by the passive Avy dispatch Transient.")

(defvar my/avy-dispatch-display-buffer nil)
(defvar my/avy-dispatch-display-window nil)
(defvar my/avy-dispatch-menu-requested nil)
(defvar my/avy-dispatch-menu-active nil)

;; ============================================================================
;; 1. 快速的定位单词，easymon
;; ============================================================================
(use-package avy
  :straight t
  :defer t
  :general
  ("C-:" '("jump by chars" . avy-goto-char-timer))
  ("M-g f" '("jump to visible line" . avy-goto-line))
  ("M-g w" '("jump to visible word" . avy-goto-word-1))
  :config
  ;; ============================================================================
  ;; 1. 核心体验与键位设置
  ;; ============================================================================

  ;; 设置跳转标签字符：优先使用主键盘中排（Home Row），击键速度最快
  (setq avy-keys '(?a ?s ?d ?f ?g ?h ?j ?u ?l ?o))

  ;; 标签生成风格：
  ;; 'at-full   - 替换整个匹配文本（最清晰醒目，类似 Vim-EasyMotion）
  ;; 'pre       - 在匹配文本前插入标签
  ;; 'post      - 在匹配文本后插入标签
  (setq avy-style 'at-full)

  ;; 背景暗化：触发 avy 时，将页面其他文字置灰，凸显高亮标签
  (setq avy-background t)

  ;; 快捷键输入超时时间（秒）：使用 avy-goto-char-timer 时，停顿该时间即开始生成标签
  (setq avy-timeout-seconds 0.35)

  ;; 搜索范围：默认仅当前 Window。可选 'all-frames (所有窗口和分屏)
  (setq avy-all-windows t)

  ;; ============================================================================
  ;; 2. Avy Dispatch Actions（跳转前/后的高阶动作扩展）
  ;;    原理：在按出标签前，先按功能键（如 'k' 代表 kill），即可在跳转的同时直接剪切/复制/选中！
  ;; ============================================================================

  ;; 自定义快捷动作（按 ? 查看可用动作菜单）
  (setq avy-dispatch-alist
        '((?x . avy-action-kill-move)    ; 按 x + 标签：剪切该处文本并把光标移过去
          (?k . avy-action-kill-stay)    ; 按 k + 标签：直接远程删除/剪切该处文本（光标留在原地！）
          (?w . avy-action-copy)         ; 按 w + 标签：远程复制该处的单词
          (?y . avy-action-yank)         ; 按 y + 标签：复制该处文本并粘贴到当前光标处
          (?t . avy-action-teleport)     ; 按 t + 标签：将该处文本移动（Teleport）到当前光标位置
          (?z . avy-action-zap-to-char)  ; 按 z + 标签：删除当前光标到目标位置之间的所有内容
          (?I . avy-action-ispell)       ; 按 I + 标签：拼写检查目标单词
          ;; h 是当前 Avy 标签键；使用 H 才不会被当成标签路径的一部分。
          (?H . avy-action-helpmode)))   ; 按 H + 标签：查看目标函数的 Help 说明

  ;; ============================================================================
  ;; 3. 自定义实用 Avy 拓展函数
  ;; ============================================================================

  ;; 扩展 1：快速复制当前屏幕上的任意文本段（远程复制）
  (defun my/avy-copy-region ()
    "Use avy to copy a region without moving point."
    (interactive)
    (call-interactively 'avy-goto-char-timer)
    (call-interactively 'avy-action-copy))

  ;; 扩展 2：直接跳转并选中该行
  (defun my/avy-select-line ()
    "Jump to a line with avy and mark it."
    (interactive)
    (avy-goto-line)
    (mark-defun)))

(transient-define-prefix my/avy-transient-menu ()
  "显示 Avy 的跳转与扩展操作。"
  [["   跳转"
    ("j" "输入字符跳转（含 Dispatch）" my/avy-goto-char-timer-with-dispatch-menu)
    ("c" "跳转到单个字符（含 Dispatch）" my/avy-goto-char-with-dispatch-menu)
    ("l" "跳转到行（含 Dispatch）" my/avy-goto-line-with-dispatch-menu)
    ("w" "跳转到单词开头（含 Dispatch）" my/avy-goto-word-1-with-dispatch-menu)
    ("s" "跳转到符号（含 Dispatch）" my/avy-goto-symbol-1-with-dispatch-menu)]
   ["   扩展操作"
    ("y" "远程复制区域（含 Dispatch）" my/avy-copy-region-with-dispatch-menu)
    ("L" "跳转并选择行（含 Dispatch）" my/avy-select-line-with-dispatch-menu)]])

(defun my/avy-menu ()
  "按需加载 Avy 后打开其 Transient 菜单。"
  (interactive)
  (require 'avy)
  (my/avy-transient-menu))

(defun my/avy-dispatch-action-description (action)
  "Return a concise Chinese description for Avy dispatch ACTION."
  (or (alist-get action
                 '((avy-action-kill-move . "剪切并跳转")
                   (avy-action-kill-stay . "原地剪切")
                   (avy-action-copy . "远程复制")
                   (avy-action-yank . "复制到当前位置")
                   (avy-action-teleport . "移动目标文本")
                   (avy-action-zap-to-char . "删除至目标")
                   (avy-action-ispell . "拼写检查")
                   (avy-action-helpmode . "查看帮助")))
      (replace-regexp-in-string
       "\\`avy-action-" "" (symbol-name action))))

(defun my/avy-dispatch-transient-children (_children)
  "Create passive Transient suffixes directly from `avy-dispatch-alist'."
  (transient-parse-suffixes
   'my/avy-dispatch-menu
   (mapcar (lambda (entry)
             (list (char-to-string (car entry))
                   (my/avy-dispatch-action-description (cdr entry))
                   #'ignore))
           avy-dispatch-alist)))

(transient-define-prefix my/avy-dispatch-menu ()
  "Render currently configured Avy dispatch actions."
  [["   Dispatch：先按动作键，再按 Avy 标签；直接按标签则正常跳转"
    :class transient-column
    :setup-children my/avy-dispatch-transient-children]])

(defun my/avy-dispatch-menu-hide ()
  "Remove the passive Avy dispatch display without affecting input focus."
  (when (window-live-p my/avy-dispatch-display-window)
    (quit-window nil my/avy-dispatch-display-window))
  (when (buffer-live-p my/avy-dispatch-display-buffer)
    (kill-buffer my/avy-dispatch-display-buffer))
  (setq my/avy-dispatch-display-window nil
        my/avy-dispatch-display-buffer nil))

(defun my/avy-dispatch-menu-show ()
  "Display Avy dispatch actions using Transient rendering without its keymap."
  (my/avy-dispatch-menu-hide)
  ;; Only Transient's layout/rendering internals are used here.  In particular,
  ;; do not call `transient--setup-transient': Avy must keep reading raw keys.
  (let ((transient--buffer-name my/avy-dispatch-display-buffer-name)
        (transient--buffer nil)
        (transient--window nil)
        (transient--prefix nil)
        (transient--layout nil)
        (transient--suffixes nil)
        (transient--showp nil)
        (transient-display-buffer-action my/avy-dispatch-display-buffer-action))
    (transient--init-transient 'my/avy-dispatch-menu nil nil)
    (transient--show)
    (setq my/avy-dispatch-display-buffer transient--buffer
          my/avy-dispatch-display-window transient--window)
    ;; Avy 紧接着进入自己的 `read-event' 循环。强制刷新可保证在首次
    ;; 输入跳转字符或标签前，底部菜单已在图形界面中绘制出来。
    (redisplay t)))

(defun my/avy--around-process-with-dispatch-menu (original &rest args)
  "Show the passive dispatch menu around one requested Avy jump."
  (if (or (not my/avy-dispatch-menu-requested)
          my/avy-dispatch-menu-active)
      (apply original args)
    (let ((my/avy-dispatch-menu-active t))
      (unwind-protect
          (progn
            (my/avy-dispatch-menu-show)
            (apply original args))
        (my/avy-dispatch-menu-hide)))))

(defun my/avy-call-with-dispatch-menu (command)
  "Interactively run Avy COMMAND with the passive Dispatch Transient display."
  (interactive)
  (require 'avy)
  (let ((my/avy-dispatch-menu-requested t))
    (call-interactively command)))

(defun my/avy-goto-char-timer-with-dispatch-menu ()
  "Run timed-character Avy jump with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'avy-goto-char-timer))

(defun my/avy-goto-char-with-dispatch-menu ()
  "Run single-character Avy jump with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'avy-goto-char))

(defun my/avy-goto-line-with-dispatch-menu ()
  "Run line Avy jump with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'avy-goto-line))

(defun my/avy-goto-word-1-with-dispatch-menu ()
  "Run word Avy jump with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'avy-goto-word-1))

(defun my/avy-goto-symbol-1-with-dispatch-menu ()
  "Run symbol Avy jump with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'avy-goto-symbol-1))

(defun my/avy-copy-region-with-dispatch-menu ()
  "Run remote-copy Avy command with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'my/avy-copy-region))

(defun my/avy-select-line-with-dispatch-menu ()
  "Run line selection with the passive Dispatch Transient display."
  (interactive)
  (my/avy-call-with-dispatch-menu #'my/avy-select-line))

(with-eval-after-load 'avy
  (advice-remove 'avy-process #'my/avy--around-process-with-dispatch-menu)
  (advice-add 'avy-process :around #'my/avy--around-process-with-dispatch-menu))

;; ============================================================================
;; 4. 配合 General.el + Which-Key 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "jj"  '("输入字符跳转" . avy-goto-char-timer)
    "jc"  '("跳转到单个字符" . avy-goto-char)
    "jl"  '("跳转到行" . avy-goto-line)
    "jw"  '("跳转到单词开头" . avy-goto-word-1)
    "js"  '("跳转到符号" . avy-goto-symbol-1)
    "jy"  '("远程复制区域" . my/avy-copy-region)
    "jL"  '("选择行" . my/avy-select-line)))

(provide 'init-avy)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-z' → `j' 菜单中的每个项目都会显示 Dispatch Transient；直接按标签跳转，或先按 x/k/w/y/t/z/I/H 再按标签执行动作。
;; - `C-:' 或 `C-c j j' 输入字符后跳到屏幕目标；`C-c j c/l/w/s' 按字符/行/词/符号跳转。
;; - 兼容键 `M-g f/M-g w' 分别跳到可见行和可见单词。
;; - `C-c j y' 远程复制目标文本；`C-c j L' 跳转并选中目标行。
;; - `M-x my/avy-menu' 打开对应的 Transient 菜单；个人工作台的“Avy 跳转”也会进入此菜单。
;; - 出现 Avy 标签时可先按 x/k/w/y/t/z，再选标签，执行剪切、删除、复制、粘贴、移动或删除区间。
;; - Avy 会在当前 Frame 的所有窗口中寻找目标，按 `?' 可查看可用的 Dispatch 动作。
;;; init-avy.el ends here
