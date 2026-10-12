;;; -*- lexical-binding: t -*-

;;; 中文导读：语言配置总入口。先配置通用 text-mode、conf-mode 与 syntax，再加载
;;; user-lisp/lang/ 中各语言模块，使所有语言共享一致的缩进、语法和编辑基线，同时
;;; 将语言特有设置保持隔离。
(defvar nn-directory (my/runtime-file "lang/")
  "语言模块保存持久化数据的运行目录。")
(defvar nn-indent-offset 2
  "语言模块默认使用的缩进宽度。")
(defvar nn-fold-string " … "
  "折叠内容在缓冲区中显示的占位文本。")

(require 'treesit)

(defun my/require-language-module (feature)
  "加载语言模块 FEATURE；单个可选依赖失败时继续加载其余语言配置。"
  (condition-case err
      (require feature)
    (error
     (message "语言模块 %s 未加载：%s" feature (error-message-string err)))))

(mapc #'my/require-language-module
      '(lang-cc lang-elisp lang-java lang-javascript lang-lua lang-python
        lang-web lang-shell lang-org lang-markdown lang-json lang-yaml))

(add-to-list 'find-sibling-rules '("/\\([^/]+\\)\\.\\(\\(s[ac]\\|le\\)ss\\|styl\\)\\'" "\\1\\.css\\'"))
(add-to-list 'find-sibling-rules '("/\\([^/]+\\)\\.css\\'" "\\1\\.\\(\\(s[ac]\\|le\\)ss\\|styl\\)\\'"))

(use-package syntax
  :straight nil
  :config
  (setq syntax-wholeline-max 1000))

(use-package text-mode
  :straight nil
  :mode "/.gitignore\\'" "/INSTALL\\'" "/LICENSE\\'"
  :custom (text-mode-ispell-word-completion nil))

(use-package conf-mode
  :straight nil
  :mode "\\.env\\..*\\'" "\\.env\\'")

(provide 'init-lang)
