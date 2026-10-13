;;; -*- lexical-binding: t -*-

;;; 中文导读：JSON 配置。json-ts-mode 通过 Tree-sitter 提供语法高亮、缩进和
;;; 结构分析，并为常见 JSON 扩展名设置自动模式关联。
(use-package js
  :straight nil
  :mode ("\\.jsonc?\\'" . js-json-mode)
  :hook (js-json-mode . my/lsp-maybe-ensure))

(use-package json-ts-mode
  :straight nil
  :if (treesit-language-available-p 'json)
  ;; 中文说明：仅在本地 JSON 服务器存在时提供 JSON Schema 诊断与补全。
  :hook (json-ts-mode . my/lsp-maybe-ensure)
  :init (add-to-list 'treesit-language-source-alist
                     '(json . ("https://github.com/tree-sitter/tree-sitter-json"))))

(provide 'lang-json)
