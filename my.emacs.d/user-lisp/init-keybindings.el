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
(defvar my-leader-map mode-specific-map
  "以 C-c 开始的全局用户命令 keymap。")

(defvar-keymap my-window-map
  :doc "以 C-c w（或 C-t）开始的窗口操作。")

(defconst my/c-c-prefix-labels
  '(("w" . "Windows")
    ("p" . "Project")
    ("!" . "Diagnostics")
    ("f" . "Files")
    ("b" . "Buffers")
    ("s" . "Search")
    ("e" . "Editing")
    ("a" . "Context actions")
    ("g" . "Git")
    ("j" . "Jump")
    ("c" . "Code")
    ("c g" . "Code navigation")
    ("c d" . "Diagnostics")
    ("c D" . "Debug")
    ("c D s" . "Debug session")
    ("c D b" . "Debug breakpoints")
    ("c D x" . "Debug execution")
    ("c D i" . "Debug inspect")
    ("c D E" . "Emacs Lisp debug")
    ("d" . "Directories")
    ("n" . "Notes / Org")
    ("n s" . "Org subtree")
    ("o" . "Code outline")
    ("o f" . "Manual folds")
    ("t" . "Code structure")
    ("x" . "Tools / System")
    ("x p" . "System packages")
    ("k" . "Markdown")
    ("l" . "LaTeX")
    ("i" . "Texinfo")
    ("m" . "Mail"))
  "Single source of truth for semantic Which-Key labels below C-c.")

(defconst my/c-c-required-prefixes
  '("w" "p" "!" "f" "b" "s" "e" "a" "g" "j" "c" "d" "n" "o" "t" "x" "k" "l" "i" "m")
  "C-c keys that must remain prefix maps after all modules load.")

(defun my/register-c-c-which-key-labels ()
  "Register every semantic C-c label against the real C-c keymap."
  (apply #'which-key-add-keymap-based-replacements
         my-leader-map
         (mapcan (lambda (entry) (list (car entry) (cdr entry)))
                 my/c-c-prefix-labels)))

(defun my/validate-c-c-prefix-layout ()
  "Warn when a module replaces a semantic C-c prefix with a command."
  (dolist (suffix my/c-c-required-prefixes)
    (let* ((keys (concat "C-c " suffix))
           (binding (key-binding (kbd keys))))
      (unless (keymapp binding)
        (display-warning
         'keybindings
         (format "%s 应为功能前缀，但当前被绑定为 %S" keys binding)
         :error)))))

(use-package which-key
  :straight t
  :demand t
  :init
  (setq which-key-idle-delay 0.4          ; 停顿 0.4 秒后弹出提示
        which-key-popup-type 'side-window ; 在底部侧边窗口显示
        which-key-side-window-location 'bottom)
  :config
  (which-key-mode 1)
  ;; 全局键只保留不属于 C-c keymap 的入口。
  (which-key-add-keymap-based-replacements
    global-map
    "C-t" "Windows"
    "C-S-c" "Multiple cursors")
  ;; C-c 下所有层级只从 `my/c-c-prefix-labels' 注册，避免两份说明漂移。
  (my/register-c-c-which-key-labels))

(defun my/refresh-which-key-prefix-labels ()
  "Restore scoped Which-Key labels after all feature keymaps are installed."
  (my/register-c-c-which-key-labels)
  (my/validate-c-c-prefix-layout))

;; init-mykey.el 在本文件之后加载；启动末尾重新附加局部说明。
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
    "C-c w" (cons "Windows" my-window-map)
    "C-t" (cons "Windows" my-window-map)
    "C-x C-b" '("electric buffer list" . electric-buffer-list))

  ;; C-c C-w 由 Ace Window 独占。General 的 override keymap 高于
  ;; major/minor mode keymap，防止 Dirvish、web-mode 等模式重新抢占。
  (general-define-key
    :keymaps 'override
    "C-c C-w" '("Ace Window: select" . ace-window))

  ;; Leader 直接写入 Emacs 原生 C-c 用户 keymap；窗口命令使用独立子 keymap。
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
;; - 全局 Leader 直接使用 `C-c'；停顿约 0.4 秒后 Which-Key 显示按功能分组的一级入口。
;; - 窗口前缀为 `C-t'，兼容入口为 `C-c w'；两者指向同一个窗口 keymap。
;; - `C-c C-w' 是高优先级的 Ace Window 选择键；`C-w' 保留 Emacs 原生 kill-region。
;; - `C-c f f/r' 打开文件/最近文件；`C-c b b/k/l' 切换/关闭/列出 Buffer。
;; - `C-c d d' 打开当前目录的原生 Dired；各功能模块继续向对应的 C-c 子菜单注册命令。
;; - `C-c k/l/i' 分别进入 Markdown、LaTeX、Texinfo 文档操作菜单。
;; - `C-x C-b' 使用 electric buffer list；repeat-mode 允许可重复命令只重按末键。
;; - 新增多层快捷键时，应同时在这里为对应前缀添加 Which-Key 分类名称。
