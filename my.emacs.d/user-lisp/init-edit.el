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

;;  取消 ： 选中使用 tba 进行选着，移动到不需要l修改的单词上，M-； 
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
