;;; -*- lexical-binding: t -*-

;;; 中文导读：JSON 配置。json-ts-mode 通过 Tree-sitter 提供语法高亮、缩进和
;;; 结构分析，并为常见 JSON 扩展名设置自动模式关联。
(use-package json-ts-mode
  :ensure nil
  :if (treesit-language-available-p 'json)
  :mode "\\.json\\'"
  ;; :hook (json-ts-mode . eglot-ensure)
  :init (add-to-list 'treesit-language-source-alist
                     '(json . ("https://github.com/tree-sitter/tree-sitter-json"))))

(provide 'lang-json)
