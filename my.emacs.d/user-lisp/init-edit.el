;;; init-editing.el --- Advanced Non-Evil Editing Suite -*- lexical-binding: t; -*-

;;; Commentary:
;; 本文件包含非-Evil（Emacs 原生快捷键模式）下的高效文本编辑与围栏符号增强方案。
;; 提供了类似于 Vim 的 ci/ca/ys/cs/ds 快捷体验以及多光标、语义选区扩充。

;;; Code:

(require 'cl-lib)
(require 'transient)

;; ============================================================================
;; 0.5. View Mode：当前 Buffer 的只读浏览开关
;; ============================================================================
(use-package view
  :straight nil
  :commands view-mode)

(defun my/view-mode-enable ()
  "在当前 Buffer 开启 View Mode，并关闭个人工作台菜单。"
  (interactive)
  (view-mode 1)
  ;; 中文说明：View Mode 开启后立即返回内容浏览，避免工作台 Transient 覆盖
  ;; 只读浏览界面或让用户误以为仍处于菜单选择状态。
  (when (transient-active-prefix)
    ;; `transient-quit-all' 只在下一次事件循环退出；View Mode 需要当前命令
    ;; 同步关闭工作台，因此调用 Transient 的即时清理流程。
    (transient--emergency-exit :view-mode)))

(defun my/view-mode-disable ()
  "在当前 Buffer 关闭 View Mode。"
  (interactive)
  (view-mode -1))

(defun my/view-mode-toggle ()
  "切换当前 Buffer 的 View Mode；开启时关闭工作台菜单。"
  (interactive)
  (if view-mode
      (my/view-mode-disable)
    (my/view-mode-enable)))

(transient-define-prefix my/view-mode-menu ()
  "打开当前 Buffer 的 View Mode 开关菜单。"
  [["   View Mode"
    ("v" "开启只读浏览并关闭工作台" my/view-mode-enable)
    ("q" "关闭只读浏览" my/view-mode-disable)
    ("t" "切换 View Mode" my/view-mode-toggle)]])

;; ============================================================================
;; 0. CUA Mode：矩形选区与矩形编辑
;; ============================================================================
;; 中文说明：CUA 是 Emacs 内置功能。关闭 CUA 剪切/复制/粘贴键位接管，仅启用
;; 矩形选区，避免覆盖本配置已有的 C-x/C-c/C-v 等编辑习惯。
(use-package cua-base
  :straight nil
  :demand t
  :init
  (setq cua-enable-cua-keys nil)
  :config
  ;; 中文说明：不全局启用 cua-mode；它的高优先级 emulation keymap 会与 C-d
  ;; 工作台冲突。矩形选区由下方按需调用的 cua-rectangle-mark-mode 独立提供。
  (cua-mode -1)
  (require 'cua-rect))

(defun my/cua-rectangle-cancel ()
  "取消当前 CUA 矩形选区并释放所有临时矩形状态。"
  (interactive)
  (setq-local my/cua-rectangle--persistent nil)
  (remove-hook 'post-command-hook #'my/cua-rectangle--keep-active t)
  (when (bound-and-true-p cua-rectangle-mark-mode)
    (cua-rectangle-mark-mode -1))
  (deactivate-mark))

(defvar-local my/cua-rectangle--persistent nil
  "非 nil 时除 ESC/C-g 外保持 CUA 矩形选区状态。")

(defun my/cua-rectangle--keep-active ()
  "在普通命令撤销 Region 后保持矩形选区激活。"
  (when my/cua-rectangle--persistent
    ;; 中文说明：CUA 的 deactivate-mark hook 可能已先关闭 minor mode；普通
    ;; 编辑键触发的这种关闭立即重新启用，而 ESC/C-g 会先清除持久标记。
    (unless (bound-and-true-p cua-rectangle-mark-mode)
      (my/cua-rectangle--enable-persistent))
    (unless mark-active
      (activate-mark)
      (setq deactivate-mark nil)
      (unless cua--rectangle
        (cua-set-rectangle-mark)))))

(defun my/cua-rectangle-remind-exit ()
  "在矩形选区中提示退出键，保持当前选区不变。"
  (interactive)
  (message "矩形选区中请按 ESC 或 C-g 退出"))

(defun my/cua-rectangle--remove-auto-cancel-hook (before-hooks)
  "移除 CUA 新增的自动取消钩子，与 BEFORE-HOOKS 对比。"
  (dolist (hook (cl-set-difference (default-value 'deactivate-mark-hook)
                                    before-hooks :test #'eq))
    ;; 中文说明：CUA 原钩子在任意 Region 失活时直接关闭矩形模式；此处替换为
    ;; 仅由 ESC/C-g 触发的显式取消。
    (remove-hook 'deactivate-mark-hook hook)))

(defun my/cua-rectangle--enable-persistent ()
  "启用 CUA 矩形选区，并移除其自动取消钩子。"
  (let ((before-hooks (copy-sequence (default-value 'deactivate-mark-hook))))
    (cua-rectangle-mark-mode 1)
    (my/cua-rectangle--remove-auto-cancel-hook before-hooks)
    (setq-local my/cua-rectangle--persistent t)
    ;; -100 让保持逻辑先于 CUA 自身矩形更新运行；`add-hook' 会自动去重。
    (add-hook 'post-command-hook #'my/cua-rectangle--keep-active -100 t)))

(defun my/cua-rectangle-toggle ()
  "启动持久 CUA 矩形选区；仅 ESC 或 C-g 可以退出。"
  (interactive)
  (if (bound-and-true-p cua-rectangle-mark-mode)
      (my/cua-rectangle-remind-exit)
    (my/cua-rectangle--enable-persistent)))

(with-eval-after-load 'cua-rect
  ;; 中文说明：矩形状态只允许 ESC/C-g 退出。BS/DEL 保持未绑定状态，不会因
  ;; 自动取消映射离开矩形选区。
  (define-key cua--rectangle-keymap [escape] #'my/cua-rectangle-cancel)
  (define-key cua--rectangle-keymap (kbd "C-g") #'my/cua-rectangle-cancel)
  (define-key cua--rectangle-keymap (kbd "BS") nil)
  (define-key cua--rectangle-keymap (kbd "DEL") nil))

;; ============================================================================
;; 1. Change-Inner: 实现类似 Vim 的 ci" / ca" / ci( / ca( 操作
;; ============================================================================
(use-package change-inner
  :straight t
  :general
  ("M-i" '("change inner" . change-inner))
  ("M-o" '("change outer" . change-outer)))

;; ============================================================================
;; 1.5. Easy Kill：按对象选择、复制或标记文本
;; ============================================================================
;; 中文说明：不采用上游常见的 M-w / C-w 全局绑定。M-w 已用于本配置的复制，
;; C-w 是窗口 Transient；Easy Kill 仅从 C-c e k 或工作台菜单启动。插件进入
;; 自己的临时选择状态后，C-w 只对当前候选执行剪切，不会改写全局窗口快捷键。
(use-package easy-kill
  :straight (:host github
             :repo "leoliu/easy-kill"
             :commit "98cbae5d8c378ad14d612d7c88a78484c49a80b8")
  :commands (easy-kill easy-mark easy-dup easy-dup-before easy-kill-help
                       easy-kill-abort))

(defun easy-kill-on-word (n)
  "选择单词；当前位置没有单词时选择一个字符，兼容空格和符号。

N 保持 Easy Kill 的对象选择接口。"
  (let ((character (char-after)))
    (if (and character (eq (char-syntax character) ?w))
      ;; 中文说明：正常单词仍完全交给 Easy Kill 原流程，保留数字前缀、扩展与
      ;; 收缩候选等行为；`t' 防止再次调用本兼容 handler。
      (easy-kill-thing 'word n t)
      (let* ((point (point))
             ;; 中文说明：当前字符不是 word 时，严格选择该字符；符号、空格和
             ;; 标点不会按语法表的 symbol 规则扩展成整行。位于 Buffer 末尾则退回前一字符。
             (bounds (cond
                      (character (cons point (1+ point)))
                      ((> point (point-min)) (cons (1- point) point)))))
        (if bounds
            (easy-kill-adjust-candidate 'word (car bounds) (cdr bounds))
          (easy-kill-echo "当前 Buffer 没有可选择的字符"))))))

(defun my/easy-kill-active-p ()
  "返回非 nil 表示当前 Buffer 正处于 Easy Kill 临时选择状态。"
  (and (boundp 'easy-kill-candidate)
       (overlayp easy-kill-candidate)
       (overlay-buffer easy-kill-candidate)))

(defconst my/easy-kill-transient-display-buffer-name " *Easy Kill 键位表*"
  "Easy Kill 被动 Transient 菜单使用的内部 Buffer 名称。")
(defvar my/easy-kill-transient-display-buffer nil)
(defvar my/easy-kill-transient-display-window nil)

(transient-define-prefix my/easy-kill-transient-menu ()
  "显示 Easy Kill 临时选择状态的键位，不接管输入。"
  :column-widths '(24 24 26)
  [["   选择对象"
    ("w/s/l/f/d" "词/表达式/列表/文件名/函数" easy-kill-thing)
    ("=/-" "扩展/收缩候选" easy-kill-expand)
    ("SPC" "循环选择对象类型" easy-kill-cycle)]
   ["   复制与标记"
    ("C-k" "剪切当前候选" easy-kill-region)
    ("m" "标记当前对象" easy-mark)
    ("@" "追加到上一复制项" easy-kill-append)]
   ["   退出与帮助"
    ("M-3" "取消 Easy Kill" easy-kill-abort)
    ("C-g" "取消 Easy Kill" easy-kill-abort)
    ("?" "显示完整键位帮助" easy-kill-help)]])

(defun my/easy-kill-transient-hide (&rest _)
  "关闭 Easy Kill 的被动 Transient 键位表。"
  (when (window-live-p my/easy-kill-transient-display-window)
    (quit-window nil my/easy-kill-transient-display-window))
  (when (buffer-live-p my/easy-kill-transient-display-buffer)
    (kill-buffer my/easy-kill-transient-display-buffer))
  (setq my/easy-kill-transient-display-buffer nil
        my/easy-kill-transient-display-window nil))

(defun my/easy-kill-transient-show ()
  "显示 Easy Kill 被动 Transient 键位表，保留原始临时选择键。"
  (my/easy-kill-transient-hide)
  ;; 中文说明：不调用常规 Transient 前缀命令，避免其覆盖 Easy Kill 的临时 map。
  (let ((transient--buffer-name my/easy-kill-transient-display-buffer-name)
        (transient--buffer nil)
        (transient--window nil)
        (transient--prefix nil)
        (transient--layout nil)
        (transient--suffixes nil)
        (transient--showp nil)
        (transient-display-buffer-action
         '((display-buffer-in-side-window)
           (side . bottom)
           (slot . -1)
           (window-height . 0.18)
           (preserve-size . (nil . t)))))
    (transient--init-transient 'my/easy-kill-transient-menu nil nil)
    (transient--show)
    (setq my/easy-kill-transient-display-buffer transient--buffer
          my/easy-kill-transient-display-window transient--window)
    (redisplay t)))

(defun my/easy-kill-toggle ()
  "用 M-3 启动 Easy Kill；在其临时选择状态中再次按 M-3 取消。"
  (interactive)
  (if (my/easy-kill-active-p)
      (progn
        (easy-kill-abort)
        (my/easy-kill-transient-hide))
    (easy-kill)
    (when (my/easy-kill-active-p)
      (my/easy-kill-transient-show))))

(defun my/easy-kill-remind-delete-key ()
  "提示 Easy Kill 的候选剪切键，避免 C-w 与窗口菜单冲突。"
  (interactive)
  (message "Easy Kill 中按 C-k 剪切当前候选；C-w 保留给窗口菜单"))

(with-eval-after-load 'easy-kill
  ;; 中文说明：C-w 已被全局窗口 Transient 使用。Easy Kill 临时状态中把候选
  ;; 剪切改为 C-k，C-w 仅提示，避免打开窗口菜单导致选择状态意外退出。
  (define-key easy-kill-base-map (kbd "C-k") #'easy-kill-region)
  (define-key easy-kill-base-map (kbd "C-w") #'my/easy-kill-remind-delete-key)
  ;; 中文说明：M-w 在 Easy Kill 临时 map 内确认复制候选并退出；全局 M-w
  ;; 仍保持 `my-copy-dwim'，两者不共享或互相覆盖。
  (define-key easy-kill-base-map (kbd "M-w") #'easy-kill-terminate)
  ;; 中文说明：与全局同一按键构成开关式体验，临时状态中只执行取消。
  (define-key easy-kill-base-map (kbd "M-3") #'easy-kill-abort)
  ;; Easy Kill 正常复制、剪切、取消或标记结束后都收起提示面板。
  (add-hook 'easy-kill-exit-hook #'my/easy-kill-transient-hide)
  (add-hook 'easy-mark-exit-hook #'my/easy-kill-transient-hide))

(transient-define-prefix my/easy-kill-menu ()
  "打开 Easy Kill 的对象选择、复制与标记菜单。"
  [["   Easy Kill"
    ("k" "选择并复制对象" my/easy-kill-toggle)
    ("m" "选择并标记对象" easy-mark)
    ("d" "在选区后复制对象" easy-dup)
    ("b" "在选区前复制对象" easy-dup-before)
    ("M-w" "复制当前候选并退出" easy-kill-terminate)
    ("?" "Easy Kill 键位帮助" easy-kill-help)
    ("C-k" "剪切当前候选" easy-kill-region)]])

;; ============================================================================
;; 2. Embrace: 实现类似 Vim 的 ys / cs / ds (Surround 围栏符号增删改)
;; ============================================================================
(use-package embrace
  :straight t
  :config
  ;; 为常见的 major-mode 启用官方内置的扩展配置 (例如 org-mode, elisp 等)
  (add-hook 'org-mode-hook #'embrace-org-mode-hook)
  (add-hook 'emacs-lisp-mode-hook #'embrace-emacs-lisp-mode-hook))

;; ============================================================================
;; 3. Expand-Region: 按语法结构/语义扩展/缩减选区
;; ============================================================================
(use-package expand-region
  :straight t
  :general
  ("C-=" '("expand selection" . er/expand-region))
  ("C--" '("contract selection" . er/contract-region)))

;; ============================================================================
;; 4. Multiple-Cursors: 多光标并发编辑
;; ============================================================================
(use-package multiple-cursors
  :straight t
  :general
  ("C-S-c C-S-c" '("multiple cursors on lines" . mc/edit-lines))
  ("C->" '("mark next occurrence" . mc/mark-next-like-this))
  ("C-<" '("mark previous occurrence" . mc/mark-previous-like-this))
  ("C-c C-<" '("mark all occurrences" . mc/mark-all-like-this)))


;; 另一个多光标的编辑软件，非常轻量
(defun my/iedit-style-faces (&rest _)
  "让 Iedit 的可编辑与只读匹配项保持清晰、易辨认。"
  (when (facep 'iedit-occurrence)
    (set-face-attribute 'iedit-occurrence nil
                        :inherit nil
                        :foreground "#1e2030"
                        :background "#ffc777"
                        :weight 'bold
                        :extend nil))
  (when (facep 'iedit-read-only-occurrence)
    (set-face-attribute 'iedit-read-only-occurrence nil
                        :inherit nil
                        :foreground "#1e2030"
                        :background "#82aaff"
                        :weight 'bold
                        :extend nil)))

(use-package iedit
  :straight t
  :defer t
  :init
  ;; 禁用包自带的 C-; 绑定，统一交由 General.el 管理。
  (setq iedit-toggle-key-default nil))

;; 中文说明：Iedit 的局部键图默认将 M-; 用于排除当前匹配项，会覆盖全局
;; `comment-line`。注释代码时不能把注释符同步写入每个匹配项，因此先退出
;; Iedit，再只注释光标所在行，确保注释行为与普通编辑状态一致。
(defun my/iedit-comment-line ()
  "安全退出 Iedit 后注释当前行或选区。"
  (interactive)
  (when (bound-and-true-p iedit-mode)
    (iedit-mode -1))
  (call-interactively #'comment-line))

(with-eval-after-load 'iedit
  (my/iedit-style-faces)
  ;; 切换主题可能重置包的 face；主题启用后重新应用 Iedit 高对比配色。
  (add-hook 'enable-theme-functions #'my/iedit-style-faces)
  ;; 中文说明：M-' 保留 Iedit 原本的“排除当前匹配项”能力，避免与 M-; 注释冲突。
  (define-key iedit-mode-keymap (kbd "M-;") #'my/iedit-comment-line)
  (define-key iedit-mode-keymap (kbd "C-s") #'iedit-toggle-selection))

;; --- 挂载到 General.el / C-c e 编辑前缀 ---
(with-eval-after-load 'general
  ;; 全局快捷键：快速编辑光标下的所有匹配项。
  (general-define-key
    "C-;" '("iedit occurrences" . iedit-mode)
    "M-3" '("Easy Kill 开关" . my/easy-kill-toggle))

  (my-leader-def
    "e i" '("change inner" . change-inner)
    "e o" '("change outer" . change-outer)
    "e s" '("surround menu" . embrace-commander)
    "e r" '("replace surrounding pair" . my-surround-replace)
    "e R" '("replace paired surroundings" . my-surround-replace-pair)
    "e w" '("surround word" . my-surround-word)
    "e +" '("expand selection" . er/expand-region)
    "e -" '("contract selection" . er/contract-region)
    "e l" '("multiple cursors on lines" . mc/edit-lines)
    "e n" '("mark next occurrence" . mc/mark-next-like-this)
    "e p" '("mark previous occurrence" . mc/mark-previous-like-this)
    "e a" '("mark all occurrences" . mc/mark-all-like-this)
    "e e" '("iedit occurrences" . iedit-mode)
    "e f" '("iedit current function" . iedit-mode-toggle-on-function)
    ;; 中文说明：C-c e u 只切换矩形选区，不触发 CUA 全局剪切/复制/粘贴键。
    "e u" '("CUA 矩形选区" . my/cua-rectangle-toggle)
    "e k" '("Easy Kill 菜单" . my/easy-kill-menu)))

(provide 'init-edit)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `M-i/M-o' 或 `C-c e i/o' 修改当前包围结构的内部/整体内容。
;; - `C-c e s' 打开 Embrace 菜单；`C-c e r/R/w' 替换包围符、替换成对包围符或包围单词。
;; - `C-=/C--' 或 `C-c e +/-' 按语法结构扩展/收缩选区。
;; - `C->/C-<' 标记下/上一个相同文本，`C-c C-<' 标记全部，`C-S-c C-S-c' 按行多光标。
;; - `C-;' 或 `C-c e e' 切换 Iedit；`C-c e f' 只编辑当前函数内的匹配项。
;; - `C-c e k' 打开 Easy Kill；进入后按字母选择对象，`M-w' 复制候选、`C-k' 剪切、`C-g' 取消。
;; - `M-3' 启动 Easy Kill；处于 Easy Kill 选择状态时再次按 `M-3' 取消。
;; - `C-c e u' 启动 CUA 矩形选区；仅 `ESC' 退出，`C-g' 仅提示，CUA 全局键位保持关闭。
;; - `C-c e l/n/p/a' 分别为按行多光标、下一个、上一个和全部匹配。
;;; init-editing.el ends here

;; -----------------------------------------------------------------------------
;; iedit 常用快捷键速查表 (Cheatsheet)
;; -----------------------------------------------------------------------------
;;
;; 1. 开启与退出 (Start & Exit)
;; -----------------------------------------------------------------------------
;;   C-;         - 进入 / 退出 iedit 模式（高亮所有匹配当前光标下单词的项）
;;   C-u C-;     - 仅在当前选区 (Region) 范围内开启 iedit
;;   ESC / C-g   - 强制取消并退出 iedit 模式
;;
;; 2. 筛选与排除 (Filtering & Selection)
;; -----------------------------------------------------------------------------
;;   M-;         - 安全退出 Iedit 后注释当前行或选区 (comment-line)
;;   M-'         - [核心] 反选/取消当前高亮项 (iedit-toggle-selection)
;;                 (按 TAB 移到不想改的词上，按 M-' 即可剔除该项)
;;   TAB / C-n   - 跳转到下一个匹配项
;;   S-TAB / C-p - 跳转到上一个匹配项
;;   M-h         - 限制匹配范围为当前函数/方法内部 (iedit-restrict-function)
;;   M-I         - 限制匹配范围为当前选中的行范围 (iedit-restrict-current-line)
;;
;; 3. 批量修改与编辑 (Editing Actions)
;; -----------------------------------------------------------------------------
;;   直接打字    - 实时同步修改所有选中的高亮项
;;   C-k         - 清空所有匹配项的文本（保留高亮位置，方便重新输入）
;;   M-D         - 删除所有匹配项及其所在的整个单词/行
;;   C-w / M-w   - 批量剪切 / 复制当前匹配项
;;   C-y         - 批量粘贴覆盖所有匹配项
;;   M-U         - 将所有匹配项转换为大写 (UPPERCASE)
;;   M-L         - 将所有匹配项转换为小写 (lowercase)
;;
;; -----------------------------------------------------------------------------
;; 标准高效工作流示例：
;; 1. 光标放在变量 old_var 上，按 C-; (全部高亮)
;; 2. 按 TAB 移动，对不需要修改的单词按 M-' (取消选中)
;; 3. 按 C-k (清空原文本) 并直接输入 new_var
;; 4. 按 C-; 或 ESC (保存并退出)
;; -----------------------------------------------------------------------------
