;;; init-treesitter.el --- Automatic Tree-sitter configuration -*- lexical-binding: t; -*-


;; ============================================================================
;; 1. 自定义语法包存放路径 (Custom Grammar Storage Directory)
;; ============================================================================
(use-package treesit
  :init
  ;; 建立自定义运行目录变量
  (defvar my/treesit-grammar-dir
    (expand-file-name "runtimes/tree-sitter" user-emacs-directory)
    "Directory to store and load compiled tree-sitter grammars.")

  ;; 自动创建该目录 (如果尚不存在)
  (unless (file-exists-p my/treesit-grammar-dir)
    (make-directory my/treesit-grammar-dir t))

  ;; 告诉 Emacs 优先从此路径加载编译好的语法动态库 (.so / .dylib)
  (add-to-list 'treesit-extra-load-path my/treesit-grammar-dir))

  ;; ============================================================================
;; 2. Treesit-auto: 自动下载并编译到指定目录
;; ============================================================================
(use-package treesit-auto
  :straight t
  :demand t
  :custom
  ;; 自动安装策略：'prompt 为弹窗提示后下载，t 为完全静默下载
  (treesit-auto-install 'prompt)

  :config
  ;; 关键：强行指定 treesit-auto 将源码编译安装到我们自定义的路径
  (setq treesit-auto-install-dir my/treesit-grammar-dir)

  ;; 设置 Treesit 高亮精细度等级 (1: 极简 -> 4: 最精细/最漂亮)
  (setq treesit-font-lock-level 4)

  ;; 自动将系统默认的 Major-mode 映射替换为对应的 -ts-mode
  (global-treesit-auto-mode))

;; ============================================================================
;; 3. Treesit-fold: 基于语法树的代码块折叠
;; ============================================================================
(use-package treesit-fold
  :straight (:host github :repo "emacs-tree-sitter/treesit-fold")
  :defer t
  :hook ((c-ts-mode
          c++-ts-mode
          python-ts-mode
          rust-ts-mode
          go-ts-mode
          js-ts-mode
          java-ts-mode
          sql-ts-mode
          elisp-ts-mode
          lua-ts-mode
          typescript-ts-mode) . treesit-fold-mode))

;; ============================================================================
;; 4. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "t"   '(:ignore t :which-key "Treesitter / Toggle")
    "t f" '(treesit-fold-toggle   :which-key "toggle code fold")
    "t F" '(treesit-fold-open-all :which-key "open all folds in buffer")
    "t i" '(treesit-inspect-mode  :which-key "inspect AST at point")
    "t a" '(treesit-auto-install-all :which-key "batch install all grammars")))

(provide 'init-treesitter)
;;; init-treesitter.el ends here