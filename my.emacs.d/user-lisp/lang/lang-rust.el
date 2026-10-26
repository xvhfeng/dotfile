;;; lang-rust.el --- Rust 开发语言配置 -*- lexical-binding: t; -*-

;;; 中文说明：Rust 优先使用 Emacs 内置 `rust-ts-mode' 获得 Tree-sitter 高亮；
;;; `rust-mode' 是 grammar 暂不可用时的稳定回退，固定提交保证换环境后可复现。
(use-package rust-mode
  :straight (:host github
             :repo "rust-lang/rust-mode"
             :commit "265e243732761b925e03ebb61930a3aeea034d0e")
  :mode ("\\.rs\\'" . rust-mode)
  :hook ((rust-mode rust-ts-mode) . my/rust-development-setup)
  :custom
  ;; 中文说明：Rust 官方风格使用 4 空格缩进；Tree-sitter 模式沿用其内置规则。
  (rust-indent-offset 4))

(defun my/rust-development-setup ()
  "为传统和 Tree-sitter Rust 模式启用统一开发能力。"
  ;; 中文说明：显式启用 Outline，LSP 的 Document Symbol 会自动成为 Imenu/侧栏大纲。
  (outline-minor-mode 1)
  ;; 中文说明：仅在本地 rust-analyzer 已就绪时连接 Eglot，缺失时仍可编辑。
  (my/lsp-maybe-ensure))

(provide 'lang-rust)
;;; lang-rust.el ends here
