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
  (which-key-add-key-based-replacements
    "C-z" "Leader"
    "C-c w" "Windows"
    "C-t" "Windows"))

;; ============================================================================
;; 2. General.el: 统筹全局，绑定 Leader 键并联动 Hydra 和 Which-Key
;; ============================================================================
(use-package general
  :straight t
  :demand t
  :config
  ;; 所有全局前缀与兼容快捷键都由 General 安装。
  (general-define-key
    "C-z" my-leader-map
    "C-c w" my-window-map
    "C-t" my-window-map
    "C-x C-b" '(electric-buffer-list :which-key "electric buffer list"))

  ;; Leader 与窗口命令使用独立 keymap，避免 C-c w 混入非窗口操作。
  (general-create-definer my-leader-def
    :keymaps 'my-leader-map)

  (general-create-definer my-window-def
    :keymaps 'my-window-map)

  (my-leader-def
    ;; 顶层菜单按命令语义统一命名，子模块只负责注册具体命令。
    "f" '(:ignore t :which-key "Files")
    "b" '(:ignore t :which-key "Buffers")
    "s" '(:ignore t :which-key "Search")
    "e" '(:ignore t :which-key "Edit/Refactor")
    "g" '(:ignore t :which-key "Git")
    "j" '(:ignore t :which-key "Jump/History")
    "c" '(:ignore t :which-key "Code/LSP")
    "d" '(:ignore t :which-key "Directory")
    "n" '(:ignore t :which-key "Notes/Org")
    "o" '(:ignore t :which-key "Outline/Views")
    "t" '(:ignore t :which-key "Syntax/Treesitter")
    "x" '(:ignore t :which-key "Tools/System")

    "f f" '(find-file :which-key "find file")
    "f r" '(recentf-open-files :which-key "recent files")
    "b b" '(switch-to-buffer :which-key "switch buffer")
    "b k" '(kill-current-buffer :which-key "kill current buffer")
    "b l" '(electric-buffer-list :which-key "electric buffer list")
    "d d" '(dired-jump :which-key "Dired current directory")))


;; 使用general参数代替bind的示例
;; (use-package magit
;;  :straight t
;;  :general
;;  (my-leader-def
;;    "g g" 'magit-status)) ; 依然用的是你全局定义好的 my-leader-def

(message "my keybindings  loaded!")
(provide 'init-keybindings)
