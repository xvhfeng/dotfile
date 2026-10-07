;;; -*- lexical-binding: t -*-

;;; 中文导读：YAML 配置。yaml-ts-mode 使用 Tree-sitter 解析 YAML，提供结构化
;;; 高亮和缩进，并负责常见 *.yaml/*.yml 文件。
(use-package yaml-ts-mode
  :ensure nil
  :if (treesit-language-available-p 'yaml)
  :mode "\\.clangd\\'" "\\.clang-format\\'" "\\.clang-tidy\\'" "\\.ya?ml\\'"
  :init
  (add-to-list 'treesit-language-source-alist
               '(yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))))

(provide 'lang-yaml)
