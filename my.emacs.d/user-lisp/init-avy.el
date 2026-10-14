;;; init-avy.el --- Avy (EasyMotion) configuration -*- lexical-binding: t; -*-

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
          (?h . avy-action-helpmode)))   ; 按 h + 标签：查看目标函数的 Help 说明

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

;; ============================================================================
;; 4. 配合 General.el + Which-Key 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "jj"  '("char timer (2-3 chars)" . avy-goto-char-timer)
    "jc"  '("single char" . avy-goto-char)
    "jl"  '("line" . avy-goto-line)
    "jw"  '("word start" . avy-goto-word-1)
    "js"  '("symbol" . avy-goto-symbol-1)
    "jy"  '("remote copy region" . my/avy-copy-region)
    "jL"  '("select line" . my/avy-select-line)))

(provide 'init-avy)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-:' 或 `C-z j j' 输入字符后跳到屏幕目标；`C-z j c/l/w/s' 按字符/行/词/符号跳转。
;; - 兼容键 `M-g f/M-g w' 分别跳到可见行和可见单词。
;; - `C-z j y' 远程复制目标文本；`C-z j L' 跳转并选中目标行。
;; - 出现 Avy 标签时可先按 x/k/w/y/t/z，再选标签，执行剪切、删除、复制、粘贴、移动或删除区间。
;; - Avy 会在当前 Frame 的所有窗口中寻找目标，按 `?' 可查看可用的 Dispatch 动作。
;;; init-avy.el ends here
