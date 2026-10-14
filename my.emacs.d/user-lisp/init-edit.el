;;; init-editing.el --- Advanced Non-Evil Editing Suite -*- lexical-binding: t; -*-

;;; Commentary:
;; 本文件包含非-Evil（Emacs 原生快捷键模式）下的高效文本编辑与围栏符号增强方案。
;; 提供了类似于 Vim 的 ci/ca/ys/cs/ds 快捷体验以及多光标、语义选区扩充。

;;; Code:

;; ============================================================================
;; 1. Change-Inner: 实现类似 Vim 的 ci" / ca" / ci( / ca( 操作
;; ============================================================================
(use-package change-inner
  :straight t
  :general
  ("M-i" '("change inner" . change-inner))
  ("M-o" '("change outer" . change-outer)))

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
  ;; 中文说明：M-' 保留 Iedit 原本的“排除当前匹配项”能力，避免与 M-; 注释冲突。
  (define-key iedit-mode-keymap (kbd "M-;") #'my/iedit-comment-line)
  (define-key iedit-mode-keymap (kbd "M-'") #'iedit-toggle-selection))

;; --- 挂载到 General.el / C-c e 编辑前缀 ---
(with-eval-after-load 'general
  ;; 全局快捷键：快速编辑光标下的所有匹配项。
  (general-define-key
    "C-;" '("iedit occurrences" . iedit-mode))

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
    "e f" '("iedit current function" . iedit-mode-toggle-on-function)))

(provide 'init-edit)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `M-i/M-o' 或 `C-c e i/o' 修改当前包围结构的内部/整体内容。
;; - `C-c e s' 打开 Embrace 菜单；`C-c e r/R/w' 替换包围符、替换成对包围符或包围单词。
;; - `C-=/C--' 或 `C-c e +/-' 按语法结构扩展/收缩选区。
;; - `C->/C-<' 标记下/上一个相同文本，`C-c C-<' 标记全部，`C-S-c C-S-c' 按行多光标。
;; - `C-;' 或 `C-c e e' 切换 Iedit；`C-c e f' 只编辑当前函数内的匹配项。
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
