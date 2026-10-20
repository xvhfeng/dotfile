;;; init-pinky.el --- Pinky 单键导航与被动 Transient 菜单 -*- lexical-binding: t; -*-

;; Pinky 把常用导航改为单键。此模块用 key-chord 的同时按键 `k+j' 进入，
;; 并复用 Transient 的排版能力显示完整键位表，但刻意不安装 Transient keymap，
;; 因而菜单显示时每个按键仍由 pinky-mode 直接处理。

(require 'transient)

(defconst my/pinky-transient-display-buffer-name " *Pinky 键位表*"
  "Pinky 被动 Transient 菜单使用的内部 buffer 名称。")

(defconst my/pinky-transient-display-buffer-action
  '((display-buffer-in-side-window)
    (side . bottom)
    (slot . -2)
    (window-height . 0.52)
    (preserve-size . (nil . t)))
  "Pinky 被动键位表的底部展示规则。")

(defvar my/pinky-transient-display-buffer nil)
(defvar my/pinky-transient-display-window nil)

(transient-define-prefix my/pinky-transient-menu ()
  "显示 Pinky 的全部原生单键命令。

该菜单由 `my/pinky-transient-show' 以被动方式渲染，不接管后续按键。"
  ;; 中文是双宽字符，启用像素级对齐并为五列保留一致的最小宽度，避免
  ;; Transient 按字符数量计算时让相邻列粘连。
  :variable-pitch t
  :column-widths '(22 22 22 22 22)
  [["  基础移动"
    :pad-keys t
    ("h" "左移" backward-char)
    ("j" "下移" next-line)
    ("k" "上移" previous-line)
    ("l" "右移" forward-char)
    ("w" "下一单词" forward-word)
    ("W" "下一 WORD" pinky-forward-WORD)
    ("b" "上一单词" backward-word)
    ("B" "上一 WORD" pinky-backward-WORD)
    ("e" "当前／下一词尾" pinky-forward-word-end)
    ("E" "当前／下一 WORD 尾" pinky-forward-WORD-end)
    ("0" "行首" move-beginning-of-line)
    ("^" "首个非空字符" back-to-indentation)
    ("$" "行尾" move-end-of-line)
    ("i" "退出模式（ESC 同效）" my/pinky-deactivate)]
   ["  精确定位与搜索"
    :pad-keys t
    ("f" "右找字符" pinky-find-char-forward)
    ("F" "左找字符" pinky-find-char-backward)
    ("t" "停在右侧字符前" pinky-till-char-forward)
    ("T" "停在左侧字符后" pinky-till-char-backward)
    (";" "重复字符定位" pinky-repeat-find)
    ("," "反向字符定位" pinky-repeat-find-reverse)
    ("/" "向前搜索" pinky-search-forward)
    ("?" "向后搜索" pinky-search-backward)
    ("n" "沿原方向重复" pinky-search-next)
    ("N" "沿反方向重复" pinky-search-previous)]
   ["   跨行与视区定位"
    :pad-keys t
    ("gg" "文件开头" beginning-of-buffer)
    ("G" "文件结尾" end-of-buffer)
    ("ge" "上一词尾" pinky-backward-word-end)
    ("gE" "上一 WORD 尾" pinky-backward-WORD-end)
    ("g_" "本行最后非空字符" pinky-last-nonblank)
    ("(" "上一句" backward-sentence)
    (")" "下一句" forward-sentence)
    ("{" "上一段落" backward-paragraph)
    ("}" "下一段落" forward-paragraph)
    ("H" "可视区域顶部" pinky-window-top)
    ("M" "可视区域中部" pinky-window-middle)
    ("L" "可视区域底部" pinky-window-bottom)]
   ["    滚动、居中与折叠"
    :pad-keys t
    ("C-f" "向下翻页" scroll-up-command)
    ("C-b" "向上翻页" scroll-down-command)
    ("C-d" "向下半页" pinky-scroll-half-page-down)
    ("C-u" "向上半页" pinky-scroll-half-page-up)
    ("C-e" "视口下移一行" scroll-up-line)
    ("C-y" "视口上移一行" scroll-down-line)
    ("zz" "当前行居中" pinky-recenter-middle)
    ("zt" "当前行置顶" pinky-recenter-top)
    ("zb" "当前行置底" pinky-recenter-bottom)
    ("za" "切换当前折叠" pinky-fold-toggle)
    ("zo" "展开当前折叠" pinky-fold-open)
    ("zc" "关闭当前折叠" pinky-fold-close)
    ("zR" "展开全部折叠" pinky-fold-open-all)
    ("zM" "关闭全部折叠" pinky-fold-close-all)
    ("zd" "清除当前折叠" pinky-fold-delete)]
   ["    编辑与重复"
    :pad-keys t
    ("dd" "删除当前行" pinky-delete-line)
    ("dw" "删除到下一词" pinky-delete-word)
    ("diw" "删除完整单词" pinky-delete-inner-word)
    ("daw" "删除单词及空白" pinky-delete-a-word)
    ("d$" "删除到行尾" pinky-delete-line-end)
    ("dG" "删除到文件尾" pinky-delete-buffer-end)
    ("cc" "修改当前行" pinky-change-line)
    ("cw" "修改当前词" pinky-change-word)
    ("ciw" "修改完整单词" pinky-change-inner-word)
    ("caw" "修改单词及空白" pinky-change-a-word)
    ("c$" "修改到行尾" pinky-change-line-end)
    ("cG" "修改到文件尾" pinky-change-buffer-end)
    ("s" "替换字符并输入" pinky-substitute-char)
    ("x" "删除字符" pinky-delete-char)
    ("r" "替换单个字符" pinky-replace-char)
    ("R" "连续替换模式" pinky-replace-mode-start)
    ("u" "撤销" undo-only)
    ("C-r" "重做" undo-redo)
    ("." "重复上次编辑" pinky-repeat-last-edit)]])

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
  ;; 不调用 `transient--setup-transient'；它会接管按键，导致 h/j/k/l 等不再
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
  "配置本地 Pinky 的退出键并清理旧数字窗口绑定。"
  ;; 插件通过原地重建 keymap 支持热重载；先恢复完整 Vim 键位，避免旧会话
  ;; 中残留的 defvar map 让 gg、W/B/E、z 系列等新键看似没有生效。
  (pinky-mode-setup-keymap)
  ;; 本地源码已经删除数字窗口绑定；这里也清理热重载前可能残留的旧绑定。
  (dolist (key (append (mapcar #'number-to-string (number-sequence 1 9))
                       (mapcar (lambda (number) (format "C-%d" number))
                               (number-sequence 0 9))))
    (define-key pinky-mode-map (kbd key) nil))
  (define-key pinky-mode-map (kbd "i") #'my/pinky-deactivate)
  (define-key pinky-mode-map (kbd "<escape>") #'my/pinky-deactivate))

(use-package key-chord
  :straight t
  :demand t
  :config
  (my/pinky-setup-key-chord))

(use-package pinky-mode
  ;; 使用仓库内已移除 window-number 依赖的源码，不再由 straight 下载上游包。
  :load-path "plugins/my-pinky-mode"
  :straight nil
  :commands (pinky-mode-activate pinky-mode-deactivate)
  :config
  (my/pinky-setup-keymap)
  (advice-remove 'pinky-mode-activate #'my/pinky--after-activate)
  (advice-remove 'pinky-mode-deactivate #'my/pinky--after-deactivate)
  (advice-add 'pinky-mode-activate :after #'my/pinky--after-activate)
  (advice-add 'pinky-mode-deactivate :after #'my/pinky--after-deactivate))

(provide 'init-pinky)
;;; init-pinky.el ends here
