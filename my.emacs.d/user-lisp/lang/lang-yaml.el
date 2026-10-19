;;; -*- lexical-binding: t -*-

;;; 中文导读：YAML 配置。yaml-ts-mode 使用 Tree-sitter 解析 YAML，提供结构化
;;; 高亮和缩进，并负责常见 *.yaml/*.yml 文件。
(use-package yaml-mode
  :straight t
  :mode ("\\.clangd\\'" "\\.clang-format\\'" "\\.clang-tidy\\'" "\\.ya?ml\\'")
  :hook ((yaml-mode yaml-ts-mode) . my/lsp-maybe-ensure)
  ;; grammar 安装后会切换到 yaml-ts-mode，两种模式必须拥有相同的编辑服务。
  :hook ((yaml-mode yaml-ts-mode) . my/language-common-setup))

(use-package yaml-ts-mode
  :straight nil
  :if (treesit-language-available-p 'yaml)
  ;; 中文说明：仅在本地 YAML 服务器存在时启动，缺失时不影响 YAML 编辑。
  :hook (yaml-ts-mode . my/lsp-maybe-ensure))

(provide 'lang-yaml)
