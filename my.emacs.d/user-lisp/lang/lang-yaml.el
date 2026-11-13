;;; -*- lexical-binding: t -*-

;;; 中文导读：YAML 配置。yaml-ts-mode 使用 Tree-sitter 解析 YAML，提供结构化
;;; 高亮和缩进，并负责常见 *.yaml/*.yml 文件。
(require 'cl-lib)
(require 'subr-x)

(defun my/yaml-imenu--entries (node)
  "Return nested Imenu entries for YAML mapping pairs below NODE."
  (when node
    (if (equal (treesit-node-type node) "block_mapping_pair")
        (let* ((key (treesit-node-child-by-field-name node "key"))
               (value (treesit-node-child-by-field-name node "value"))
               (children (my/yaml-imenu--entries value))
               (name (and key (treesit-node-text key t)))
               (position (and key (copy-marker (treesit-node-start key)))))
          (when name
            (list (if children
                      (cons name (cons (cons " " position) children))
                    (cons name position)))))
      (cl-mapcan #'my/yaml-imenu--entries (treesit-node-children node)))))

(defun my/yaml-imenu-create-index ()
  "Build a YAML key outline without requiring a language server."
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'yaml))
      (progn
        (treesit-parser-create 'yaml)
        (my/yaml-imenu--entries (treesit-buffer-root-node 'yaml)))
    (let (entries)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward
                "^[[:blank:]]*\\(?:-[[:blank:]]+\\)?\\([^:#\n]+?\\):[[:blank:]]*"
                nil t)
          (push (cons (string-trim (match-string-no-properties 1))
                      (copy-marker (match-beginning 1)))
                entries)))
      (nreverse entries))))

(defun my/yaml-imenu-setup ()
  "Use YAML keys as the local Imenu outline."
  (setq-local imenu-create-index-function #'my/yaml-imenu-create-index))

(add-hook 'yaml-mode-hook #'my/yaml-imenu-setup)
(add-hook 'yaml-ts-mode-hook #'my/yaml-imenu-setup)

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
