;; -*- lexical-binding: t -*-


;; 开启 Emacs 28+ 内置的快捷键重复模式
(repeat-mode 1)
;; 示例：
;; 撤销操作 (C-x u)：
;; 原生：你需要按 C-x u  C-x u  C-x u 来连续撤销。
;; 开启 repeat-mode 后：你只需要按 C-x u  u  u  u 即可连续撤销！



;; ============================================================================
;; 1. Which-Key: 自动弹出按键提示面板
;; ============================================================================
(defvar-keymap my-leader-map
  :doc "以 C-z 开始的全局 Leader 命令。")

(defvar-keymap my-window-map
  :doc "以 C-c w（或 C-t）开始的窗口操作。")

(use-package which-key
  :straight t
  :demand t
  :init
  (setq which-key-idle-delay 0.4          ; 停顿 0.4 秒后弹出提示
        which-key-popup-type 'side-window ; 在底部侧边窗口显示
        which-key-side-window-location 'bottom)
  :config
  (which-key-mode 1)
  ;; 所有说明都绑定到实际 keymap，避免 General 的全局正则说明污染
  ;; 其他前缀（例如 C-c t 的 vterm 或 web-mode 标签菜单）。
  (which-key-add-keymap-based-replacements
    global-map
    "C-z" "Leader"
    "C-t" "Windows"
    "C-c w" "Windows"
    "C-c p" "Project"
    "C-c !" "Diagnostics"
    "C-c f" "File Git actions"
    "C-S-c" "Multiple cursors"
    ;; 下面两个前缀由 init-mykey.el 定义；这里只补显示说明，不修改该文件。
    "C-c o" "Split and switch"
    "C-c s" "Surround")
  (which-key-add-keymap-based-replacements
    my-leader-map
    "f" "Files"
    "b" "Buffers"
    "s" "Search"
    "e" "Editing"
    "a" "Context actions"
    "g" "Git"
    "j" "Jump"
    "c" "Code"
    "c g" "Code navigation"
    "c d" "Diagnostics"
    "c D" "Debug"
    "c D s" "Debug session"
    "c D b" "Debug breakpoints"
    "c D x" "Debug execution"
    "c D i" "Debug inspect"
    "c D E" "Emacs Lisp debug"
    "d" "Directories"
    "n" "Notes / Org"
    "n s" "Org subtree"
    "o" "Code outline"
    "t" "Syntax trees"
    "x" "Tools / System"
    "x p" "System packages"))

(defun my/refresh-which-key-prefix-labels ()
  "Restore scoped Which-Key labels after all feature keymaps are installed."
  (when-let ((c-c-map (lookup-key global-map (kbd "C-c"))))
    (which-key-add-keymap-based-replacements
      c-c-map
      "w" "Windows"
      "p" "Project"
      "!" "Diagnostics"
      "f" "File Git actions"
      "o" "Split and switch"
      "s" "Surround")))

;; init-mykey.el 在本文件之后安装 C-c o/C-c s；启动末尾重新附加局部说明。
(add-hook 'after-init-hook #'my/refresh-which-key-prefix-labels)

;; ============================================================================
;; 2. General.el: 统筹全局，绑定 Leader 键并联动 Hydra 和 Which-Key
;; ============================================================================
(use-package general
  :straight t
  :demand t
  :config
  ;; 所有全局前缀与兼容快捷键都由 General 安装。
  (general-define-key
    "C-z" (cons "Leader" my-leader-map)
    "C-c w" (cons "Windows" my-window-map)
    "C-t" (cons "Windows" my-window-map)
    "C-x C-b" '("electric buffer list" . electric-buffer-list))

  ;; Leader 与窗口命令使用独立 keymap，避免 C-c w 混入非窗口操作。
  (general-create-definer my-leader-def
    :keymaps 'my-leader-map)

  (general-create-definer my-window-def
    :keymaps 'my-window-map)

  (my-leader-def
    ;; 子模块负责注册命令；前缀名称在上面按 keymap 集中维护。
    "f f" '("find file" . find-file)
    "f r" '("recent files" . recentf-open-files)
    "b b" '("switch buffer" . switch-to-buffer)
    "b k" '("kill current buffer" . kill-current-buffer)
    "b l" '("electric buffer list" . electric-buffer-list)
    "d d" '("Dired current directory" . dired-jump)))


;; 使用general参数代替bind的示例
;; (use-package magit
;;  :straight t
;;  :general
;;  (my-leader-def
;;    "g g" 'magit-status)) ; 依然用的是你全局定义好的 my-leader-def

(message "my keybindings  loaded!")
(provide 'init-keybindings)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 全局 Leader 为 `C-z'；停顿约 0.4 秒后 Which-Key 显示按功能分组的后续按键。
;; - 窗口前缀为 `C-t'，兼容入口为 `C-c w'；两者指向同一个窗口 keymap。
;; - `C-z f f/r' 打开文件/最近文件；`C-z b b/k/l' 切换/关闭/列出 Buffer。
;; - `C-z d d' 打开当前目录的原生 Dired；各功能模块继续向 Leader 子菜单注册命令。
;; - `C-x C-b' 使用 electric buffer list；repeat-mode 允许可重复命令只重按末键。
;; - 新增多层快捷键时，应同时在这里为对应前缀添加 Which-Key 分类名称。
