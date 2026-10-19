;;; -*- lexical-binding: t -*-

;;; 中文导读：JavaScript/TypeScript 配置。js-mode 兼容传统 JavaScript，
;;; js-ts-mode/typescript-ts-mode/tsx-ts-mode 使用 Tree-sitter，分别处理 JS、TS
;;; 和 TSX；同时设置缩进、文件关联和语言服务器启动条件。
;; 在 TypeScript Tree-sitter 模式中注册 JSDoc 字体锁规则和编辑支持。
(defun my-add-jsdoc-in-typescript-ts-mode ()
  "Add jsdoc treesitter rules to typescript as a host language.
As seen on: https://www.reddit.com/r/emacs/comments/1kfblch/need_help_with_adding_jsdoc_highlighting_to"
  ;; I copied this code from js.el (js-ts-mode), with minimal modifications.
  (when (treesit-ready-p 'typescript)
    (when (treesit-ready-p 'jsdoc t)
      (setq-local treesit-range-settings
                  (treesit-range-rules
                   :embed 'jsdoc
                   :host 'typescript
                   :local t
                   `(((comment) @capture (:match ,(rx bos "/**") @capture)))))
      (setq c-ts-common--comment-regexp (rx (or "comment" "line_comment" "block_comment" "description")))

      (defvar my/treesit-font-lock-settings-jsdoc
        (treesit-font-lock-rules
         :language 'jsdoc
         :override t
         :feature 'document
         '((document) @font-lock-doc-face)

         :language 'jsdoc
         :override t
         :feature 'keyword
         '((tag_name) @font-lock-constant-face)

         :language 'jsdoc
         :override t
         :feature 'bracket
         '((["{" "}"]) @font-lock-bracket-face)

         :language 'jsdoc
         :override t
         :feature 'property
         '((type) @font-lock-type-face)

         :language 'jsdoc
         :override t
         :feature 'definition
         '((identifier) @font-lock-variable-face)))
      (setq-local treesit-font-lock-settings
                  (append treesit-font-lock-settings my/treesit-font-lock-settings-jsdoc)))))

(use-package js
  :straight nil
  :mode ("\\.[mc]?js\\'" . js-mode)
  :custom
  (js-chain-indent t)
  (js-indent-level nn-indent-offset))

(use-package js-ts-mode
  :straight nil
  ;; 中文说明：只有 JavaScript 语法可用时才切换 Tree-sitter 模式，缺失时回退 js-mode。
  :if (treesit-language-available-p 'javascript)
  ;; 中文说明：服务器存在时再启动 LSP，避免未安装 TypeScript 工具链时报错。
  :hook (js-ts-mode . my/lsp-maybe-ensure))

(use-package typescript-mode
  :straight t
  :mode ("\\.ts\\'" . typescript-mode)
  :hook (typescript-mode . my/lsp-maybe-ensure)
  :custom (typescript-indent-level nn-indent-offset))

(defun my/typescript-tsx-mode ()
  "Use `tsx-ts-mode' when its grammar exists, otherwise use `typescript-mode'."
  (interactive)
  (if (and (fboundp 'tsx-ts-mode) (treesit-ready-p 'tsx t))
      (tsx-ts-mode)
    (typescript-mode)))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . my/typescript-tsx-mode))

(use-package typescript-ts-mode
  :straight nil
  :if (or (treesit-language-available-p 'typescript)
          (treesit-language-available-p 'tsx))
  :hook
  (tsx-ts-mode . my/lsp-maybe-ensure)
  (tsx-ts-mode . my-add-jsdoc-in-typescript-ts-mode)
  (typescript-ts-mode . my/lsp-maybe-ensure)
  (typescript-ts-mode . my-add-jsdoc-in-typescript-ts-mode)
  :custom (typescript-indent-level nn-indent-offset))

(provide 'lang-javascript)
