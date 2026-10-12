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
  ("M-i" '(change-inner :which-key "change inner"))
  ("M-o" '(change-outer :which-key "change outer")))

;; ============================================================================
;; 2. Embrace: 实现类似 Vim 的 ys / cs / ds (Surround 围栏符号增删改)
;; ============================================================================
(use-package embrace
  :straight t
  ;; 绑定快捷键唤出 embrace 菜单 (a: 增加, c: 修改, d: 删除)
  :general
  ("C-c e" '(embrace-commander :which-key "surround menu"))
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
  ("C-=" '(er/expand-region :which-key "expand selection"))
  ("C--" '(er/contract-region :which-key "contract selection")))

;; ============================================================================
;; 4. Multiple-Cursors: 多光标并发编辑
;; ============================================================================
(use-package multiple-cursors
  :straight t
  :general
  ("C-S-c C-S-c" '(mc/edit-lines :which-key "multiple cursors on lines"))
  ("C->" '(mc/mark-next-like-this :which-key "mark next occurrence"))
  ("C-<" '(mc/mark-previous-like-this :which-key "mark previous occurrence"))
  ("C-c C-<" '(mc/mark-all-like-this :which-key "mark all occurrences")))


;; 另一个多光标的编辑软件，非常轻量
(use-package iedit
  :straight t
  :defer t
  :init
  ;; 禁用包自带的 C-; 绑定，统一交由 General.el 管理。
  (setq iedit-toggle-key-default nil))

;; --- 挂载到 General.el / C-z e 编辑前缀 ---
(with-eval-after-load 'general
  ;; 全局快捷键：快速编辑光标下的所有匹配项。
  (general-define-key
    "C-;" '(iedit-mode :which-key "iedit occurrences"))

  (my-leader-def
    "e i" '(change-inner :which-key "change inner")
    "e o" '(change-outer :which-key "change outer")
    "e s" '(embrace-commander :which-key "surround menu")
    "e +" '(er/expand-region :which-key "expand selection")
    "e -" '(er/contract-region :which-key "contract selection")
    "e l" '(mc/edit-lines :which-key "multiple cursors on lines")
    "e n" '(mc/mark-next-like-this :which-key "mark next occurrence")
    "e p" '(mc/mark-previous-like-this :which-key "mark previous occurrence")
    "e a" '(mc/mark-all-like-this :which-key "mark all occurrences")
    "e e" '(iedit-mode :which-key "iedit occurrences")
    "e f" '(iedit-mode-toggle-on-function :which-key "iedit current function")))

(provide 'init-edit)
;;; init-editing.el ends here
