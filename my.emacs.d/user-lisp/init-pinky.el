;;; init-pinky.el --- Pinky 单键导航与被动 Transient 菜单 -*- lexical-binding: t; -*-

;; Pinky 把常用导航改为单键。此模块用 key-chord 的同时按键 `k+j' 进入，
;; 并复用 Transient 的排版能力显示完整键位表，但刻意不安装 Transient keymap，
;; 因而菜单显示时每个按键仍由 pinky-mode 直接处理。

(require 'transient)
(require 'thingatpt)

(defconst my/pinky-transient-display-buffer-name " *Pinky 键位表*"
  "Pinky 被动 Transient 菜单使用的内部 buffer 名称。")

(defconst my/pinky-transient-display-buffer-action
  '((display-buffer-in-side-window)
    (side . bottom)
    (slot . -2)
    (window-height . 0.30)
    (preserve-size . (nil . t)))
  "Pinky 被动键位表的底部展示规则。")

(defvar my/pinky-transient-display-buffer nil)
(defvar my/pinky-transient-display-window nil)

(transient-define-prefix my/pinky-transient-menu ()
  "显示 Pinky 的全部原生单键命令。

该菜单由 `my/pinky-transient-show' 以被动方式渲染，不接管后续按键。"
  [["   光标与位置"
    ("n" "下一行" next-line)
    ("p" "上一行" previous-line)
    ("f" "向前一个字符" forward-char)
    ("b" "向后一个字符" backward-char)
    ("a" "行首" move-beginning-of-line)
    ("e" "行尾" move-end-of-line)
    ("," "文件开头" beginning-of-buffer)
    ("." "文件结尾" end-of-buffer)
    ("g" "跳转到行" goto-line)]
   ["   单词移动"
    ("h" "向前一个单词" backward-word)
    ("l" "向后一个单词" forward-word)
    ("t" "当前单词首" my/pinky-beginning-of-word)
    ("z" "当前单词尾后" my/pinky-end-of-word)
    ("q" "删除完整当前单词" my/pinky-kill-word-at-point)]
   ["   编辑与搜索"
    ("SPC" "设置标记" set-mark-command)
    ("d" "删除字符" delete-char)
    ("k" "剪切到行尾" kill-line)
    ("w" "复制选区" kill-ring-save)
    ("y" "粘贴" yank)
    ("o" "插入空行" open-line)
    ("u" "撤销" undo)
    ("x" "交换光标与标记" exchange-point-and-mark)
    ("c" "切换 Buffer" switch-to-buffer)
    ("s" "向前搜索" isearch-forward)
    ("r" "向后搜索" isearch-backward)]
   ["   滚动、窗口与退出"
    ("v" "向前翻页" scroll-up-command)
    ("m" "向后翻页" scroll-down-command)
    ("1" "选择窗口 1" pinky-window-1)
    ("2" "选择窗口 2" pinky-window-2)
    ("3" "选择窗口 3" pinky-window-3)
    ("4" "选择窗口 4" pinky-window-4)
    ("5" "选择窗口 5" pinky-window-5)
    ("6" "选择窗口 6" pinky-window-6)
    ("7" "选择窗口 7" pinky-window-7)
    ("8" "选择窗口 8" pinky-window-8)
    ("9" "选择窗口 9" pinky-window-9)
    ("0" "选择窗口 10" my/pinky-window-0)
    ("i / ESC" "退出 Pinky 模式" my/pinky-deactivate)]])

(defun my/pinky-transient-hide ()
  "关闭 Pinky 被动键位表，不改变当前输入状态。"
  (when (window-live-p my/pinky-transient-display-window)
    (quit-window nil my/pinky-transient-display-window))
  (when (buffer-live-p my/pinky-transient-display-buffer)
    (kill-buffer my/pinky-transient-display-buffer))
  (setq my/pinky-transient-display-window nil
        my/pinky-transient-display-buffer nil))

(defun my/pinky-transient-show ()
  "以被动 Transient 面板显示 Pinky 键位，保留 Pinky 的原始单键输入。"
  (my/pinky-transient-hide)
  ;; 不调用 `transient--setup-transient'；它会接管按键，导致 n/p 等不再
  ;; 传递给 pinky-mode。这里仅使用 Transient 的布局与渲染实现。
  (let ((transient--buffer-name my/pinky-transient-display-buffer-name)
        (transient--buffer nil)
        (transient--window nil)
        (transient--prefix nil)
        (transient--layout nil)
        (transient--suffixes nil)
        (transient--showp nil)
        (transient-display-buffer-action my/pinky-transient-display-buffer-action))
    (transient--init-transient 'my/pinky-transient-menu nil nil)
    (transient--show)
    (setq my/pinky-transient-display-buffer transient--buffer
          my/pinky-transient-display-window transient--window)
    (redisplay t)))

(defun my/pinky-activate ()
  "启用 Pinky 单键导航并显示被动键位表。"
  (interactive)
  (require 'pinky-mode)
  (pinky-mode-activate)
  (my/pinky-transient-show))

(defun my/pinky-deactivate ()
  "退出 Pinky 单键导航；仅在退出后关闭被动键位表。"
  (interactive)
  (when (fboundp 'pinky-mode-deactivate)
    (pinky-mode-deactivate))
  (my/pinky-transient-hide))

(defun my/pinky-window-0 ()
  "选择第 10 个窗口，补齐 Pinky 文档中 0–9 的窗口编号约定。"
  (interactive)
  (require 'window-number)
  (window-number-select 10))

(defun my/pinky-beginning-of-word ()
  "移动到光标所在单词的开头；不在单词内时向前移动一个单词。"
  (interactive)
  (if-let ((bounds (bounds-of-thing-at-point 'word)))
      (goto-char (car bounds))
    (backward-word 1)))

(defun my/pinky-end-of-word ()
  "移动到光标所在单词最后一个字符之后；不在单词内时向后移动一个单词。"
  (interactive)
  (if-let ((bounds (bounds-of-thing-at-point 'word)))
      (goto-char (cdr bounds))
    (forward-word 1)))

(defun my/pinky-kill-word-at-point ()
  "删除光标所在的完整单词；没有单词时沿用 `kill-word' 的前向行为。"
  (interactive)
  (if-let ((bounds (bounds-of-thing-at-point 'word)))
      (kill-region (car bounds) (cdr bounds))
    (kill-word 1)))

(defun my/pinky--after-activate (&rest _)
  "处理 Pinky 从 minibuffer 返回时的菜单恢复。"
  (when (bound-and-true-p pinky-mode)
    (my/pinky-transient-show)))

(defun my/pinky--after-deactivate (&rest _)
  "处理 Pinky 因 minibuffer 或原生命令退出时的菜单关闭。"
  (unless (bound-and-true-p pinky-mode)
    (my/pinky-transient-hide)))

(defun my/pinky-setup-key-chord ()
  "启用 Pinky 的 k+j 同时按键入口。"
  ;; key-chord 是真正的同时按键，而非顺序键位；按下 k+j 不会影响普通输入。
  (key-chord-mode 1)
  (key-chord-define-global "kj" #'my/pinky-activate))

(defun my/pinky-setup-keymap ()
  "配置 Pinky 的退出、窗口和小写单词操作键。"
  ;; 热重载时也清除上一版的大写/方括号绑定，避免旧字节码残留行为。
  (dolist (key '("B" "W" "D" "[" "]"))
    (define-key pinky-mode-map (kbd key) nil))
  (define-key pinky-mode-map (kbd "i") #'my/pinky-deactivate)
  (define-key pinky-mode-map (kbd "<escape>") #'my/pinky-deactivate)
  (define-key pinky-mode-map (kbd "0") #'my/pinky-window-0)
  (define-key pinky-mode-map (kbd "h") #'backward-word)
  (define-key pinky-mode-map (kbd "l") #'forward-word)
  (define-key pinky-mode-map (kbd "t") #'my/pinky-beginning-of-word)
  (define-key pinky-mode-map (kbd "z") #'my/pinky-end-of-word)
  (define-key pinky-mode-map (kbd "q") #'my/pinky-kill-word-at-point))

(use-package key-chord
  :straight t
  :demand t
  :config
  (my/pinky-setup-key-chord))

;; pinky-mode 的原始实现依赖这个旧的窗口编号包；显式声明使新机器可自动
;; 安装依赖，而非在首次按 k+j 时才报找不到 `window-number'。
(use-package window-number
  :straight t
  :defer t)

(use-package pinky-mode
  :straight (:host github :repo "jayconrod/pinky-mode")
  :commands (pinky-mode-activate pinky-mode-deactivate)
  :config
  ;; 原生 i 和用户指定的 ESC 都必须走包装退出函数，保证只有退出 Pinky
  ;; 后才关闭底部键位表。
  (my/pinky-setup-keymap)
  (advice-remove 'pinky-mode-activate #'my/pinky--after-activate)
  (advice-remove 'pinky-mode-deactivate #'my/pinky--after-deactivate)
  (advice-add 'pinky-mode-activate :after #'my/pinky--after-activate)
  (advice-add 'pinky-mode-deactivate :after #'my/pinky--after-deactivate))

(provide 'init-pinky)
;;; init-pinky.el ends here
