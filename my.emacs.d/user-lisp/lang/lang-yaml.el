;;; -*- lexical-binding: t -*-

;;; 中文导读：YAML 配置。yaml-ts-mode 使用 Tree-sitter 解析 YAML，提供结构化
;;; 高亮和缩进，并负责常见 *.yaml/*.yml 文件。
(use-package yaml-ts-mode
  :ensure nil
  :if (treesit-language-available-p 'yaml)
  :mode "\\.clangd\\'" "\\.clang-format\\'" "\\.clang-tidy\\'" "\\.ya?ml\\'"
  ;; 中文说明：仅在本地 YAML 服务器存在时启动，缺失时不影响 YAML 编辑。
  :hook (yaml-ts-mode . my/lsp-maybe-ensure)
  :init
  (add-to-list 'treesit-language-source-alist
               '(yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))))

(provide 'lang-yaml)
