;;; -*- lexical-binding: t -*-

;;; 中文导读：语言配置总入口。先配置通用 text-mode、conf-mode 与 syntax，再加载
;;; user-lisp/lang/ 中各语言模块，使所有语言共享一致的缩进、语法和编辑基线，同时
;;; 将语言特有设置保持隔离。
(require 'treesit)
(require 'lang-cc)
(require 'lang-elisp)
(require 'lang-javascript)
(require 'lang-web)
(require 'lang-shell)
(require 'lang-org)
(require 'lang-markdown)
(require 'lang-json)
(require 'lang-yaml)

(add-to-list 'find-sibling-rules '("/\\([^/]+\\)\\.\\(\\(s[ac]\\|le\\)ss\\|styl\\)\\'" "\\1\\.css\\'"))
(add-to-list 'find-sibling-rules '("/\\([^/]+\\)\\.css\\'" "\\1\\.\\(\\(s[ac]\\|le\\)ss\\|styl\\)\\'"))

(use-package syntax
  :ensure nil
  :config
  (setq syntax-wholeline-max 1000))

(use-package text-mode
  :ensure nil
  :mode "/.gitignore\\'" "/INSTALL\\'" "/LICENSE\\'"
  :custom (text-mode-ispell-word-completion nil))

(use-package conf-mode
  :ensure nil
  :mode "\\.env\\..*\\'" "\\.env\\'")

(provide 'init-lang)
