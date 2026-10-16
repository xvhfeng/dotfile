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
    ("b p" . "Temporary buffers")
    ("s" . "Search")
    ("e" . "Editing")
    ("a" . "Context actions")
    ("g" . "Git")
    ("j" . "Jump")
    ;; C-c h 是遗忘快捷键时的统一自助入口，避免必须记住插件各自的帮助键。
    ("h" . "Help / discover")
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
    ("v" . "CSV / tabular data")
    ("m" . "Mail"))
  "Single source of truth for semantic Which-Key labels below C-c.")

(defconst my/c-c-required-prefixes
  '("w" "p" "!" "f" "b" "s" "e" "a" "g" "j" "h" "c" "d" "n" "o" "t" "x" "k" "l" "i" "v" "m")
  "C-c keys that must remain prefix maps after all modules load.")

(defun my/register-c-c-which-key-labels ()
  "Register every semantic C-c label against the real C-c keymap."
  (apply #'which-key-add-keymap-based-replacements
         my-leader-map
         (mapcan (lambda (entry) (list (car entry) (cdr entry)))
                 my/c-c-prefix-labels)))

(defun my/which-key--max-display-width (bindings index &optional minimum)
  "Return maximum display width of element INDEX in BINDINGS.
Use MINIMUM as the lower bound.  Unlike `length', `string-width' counts a
Chinese character as two terminal columns, which is required for alignment."
  (cl-reduce (lambda (width binding)
               (max width (string-width (nth index binding))))
             bindings
             :initial-value (or minimum 0)))

(defun my/which-key-pad-column (bindings available-width)
  "Pad one Which-Key column in BINDINGS within AVAILABLE-WIDTH.

This is a CJK-aware replacement for `which-key--pad-column'.  Upstream uses
display width while calculating the column, but character count while adding
trailing spaces.  Mixed Chinese and English descriptions therefore shift the
start of every following column."
  (let* ((key-width (+ which-key-add-column-padding
                       (my/which-key--max-display-width bindings 0)))
         (separator-width (my/which-key--max-display-width bindings 1))
         (description-space (- available-width key-width separator-width))
         (description-width
          (min description-space
               (my/which-key--max-display-width
                bindings 2 which-key-min-column-description-width)))
         (column-width (+ key-width separator-width description-width))
         (key-format (concat "%" (number-to-string key-width) "s%s%s")))
    (cons column-width
          (mapcar
           (pcase-lambda (`(,key ,separator ,description ,_docstring))
             (concat (format key-format key separator description)
                     (make-string
                      (max 0 (- description-width
                                (string-width description)))
                      ?\s)))
           bindings))))

(defun my/which-key-buffer-setup ()
  "Give the Which-Key menu consistent spacing and a quiet presentation."
  (setq-local line-spacing 0.12
              truncate-lines t
              cursor-type nil))

(defun my/which-key-style-faces (&rest _)
  "Apply theme-adaptive visual hierarchy to Which-Key faces."
  (set-face-attribute 'which-key-key-face nil
                      :inherit 'font-lock-constant-face
                      :weight 'bold)
  (set-face-attribute 'which-key-separator-face nil
                      :inherit 'shadow
                      :weight 'normal)
  (set-face-attribute 'which-key-command-description-face nil
                      :inherit 'default
                      :weight 'normal)
  (set-face-attribute 'which-key-local-map-description-face nil
                      :inherit 'which-key-command-description-face
                      :weight 'semi-bold)
  (set-face-attribute 'which-key-group-description-face nil
                      :inherit 'font-lock-keyword-face
                      :weight 'bold))

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
  (setq which-key-idle-delay 0.4
        which-key-idle-secondary-delay 0.05
        which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        ;; 三列比默认的无限列更容易从上到下扫描，也能给中英文说明留足空间。
        which-key-max-display-columns 3
        which-key-min-display-lines 4
        which-key-side-window-max-height 0.38
        which-key-max-description-length 30
        which-key-min-column-description-width 26
        which-key-add-column-padding 2
        which-key-unicode-correction 4
        which-key-dont-use-unicode nil
        which-key-separator "  → "
        which-key-ellipsis "…"
        which-key-prefix-prefix "▸ "
        which-key-show-prefix 'top
        which-key-show-remaining-keys t
        which-key-sort-order #'which-key-key-order
        which-key-sort-uppercase-first nil
        which-key-preserve-window-configuration t
        ;; 保留 SPC/TAB/RET 全名；特殊键模式会把它们截成单个字母，反而难认。
        which-key-special-keys nil
        which-key-init-buffer-hook '(my/which-key-buffer-setup))
  :config
  ;; 修正当前 Which-Key 版本对中文显示宽度计算不一致导致的跨列错位。
  (unless (advice-member-p #'my/which-key-pad-column
                           'which-key--pad-column)
    (advice-add 'which-key--pad-column :override #'my/which-key-pad-column))
  (my/which-key-style-faces)
  ;; 主题在 Which-Key 之后加载或切换时，重新应用层级而不写死具体颜色。
  (add-hook 'enable-theme-functions #'my/which-key-style-faces)
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
    ;; Ibuffer 是可持续操作的真正 Buffer，适合由 Popper 隐藏、召回和轮换；
    ;; 原来的 Electric Buffer List 保留在 C-c b e，功能没有被删除。
    "C-x C-b" '("Ibuffer popup" . my/workbench-ibuffer))

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
    "b l" '("Ibuffer popup" . my/workbench-ibuffer)
    "b e" '("electric buffer list" . electric-buffer-list)
    "d d" '("Dired current directory" . dired-jump)

    ;; 中文说明：这些是通用发现命令，所有 major mode 下均可使用；Which-Key 会在
    ;; 按下 C-c h 后显示完整清单，用户不必记忆某个插件专属的帮助快捷键。
    "h k" '("查询按键" . describe-key)
    "h f" '("查询命令" . describe-function)
    "h v" '("查询变量" . describe-variable)
    "h m" '("当前模式帮助" . describe-mode)
    "h b" '("当前有效按键表" . describe-bindings)))


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
;; - Which-Key 固定最多三列，按 26 字符说明宽度对齐；中文按实际双宽字符计算，
;;   不会再把同一行后续菜单推歪。当前前缀显示在菜单顶部。
;; - 粗体 `▸' 项是可继续进入的功能分组；普通字重项是立即执行的命令。
;; - 窗口前缀为 `C-t'，兼容入口为 `C-c w'；两者指向同一个窗口 keymap。
;; - `C-c C-w' 是高优先级的 Ace Window 选择键；`C-w' 保留 Emacs 原生 kill-region。
;; - `C-c f f/r' 打开文件/最近文件；`C-c b b/k/l' 切换/关闭/列出 Buffer。
;;   `C-x C-b' 与 `C-c b l' 打开可由 Popper 召回的 Ibuffer；`C-c b e' 保留原有
;;   Electric Buffer List，适合只进行一次快速选择。
;; - `C-c d d' 打开当前目录的原生 Dired；各功能模块继续向对应的 C-c 子菜单注册命令。
;; - `C-c h k/f/v/m/b' 分别查询按键、命令、变量、当前模式与当前有效按键表。
;; - `C-c k/l/i/v' 分别进入 Markdown、LaTeX、Texinfo、CSV/表格数据操作菜单。
;; - `C-x C-b' 使用 Ibuffer 弹窗；repeat-mode 允许可重复命令只重按末键。
;; - 新增多层快捷键时，应同时在这里为对应前缀添加 Which-Key 分类名称。
