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
  "从源文件或运行时字节码加载语言模块 FEATURE。"
  (condition-case err
      (my/require-user-lisp-feature feature)
    (error
     (message "语言模块 %s 未加载：%s" feature (error-message-string err)))))

(mapc #'my/require-language-module
      '(lang-cc lang-elisp lang-java lang-javascript lang-lua lang-python
        lang-web lang-shell lang-json lang-yaml))

(defun my/language-common-setup ()
  "Enable the common highlighting, completion and outline baseline."
  (font-lock-mode 1)
  (outline-minor-mode 1)
  ;; 一些 major mode 会把 CAPF 改成 buffer-local，因此在语言 Hook 中
  ;; 重新补上通用的文件名和缓冲区词汇补全。
  (dolist (capf '(cape-file cape-dabbrev))
    (when (fboundp capf)
      (add-hook 'completion-at-point-functions capf 90 t))))

(add-hook 'prog-mode-hook #'my/language-common-setup)
(add-hook 'markdown-mode-hook #'my/language-common-setup)
(add-hook 'markdown-ts-mode-hook #'my/language-common-setup)

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

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 这是语言配置总入口，按顺序加载 `user-lisp/lang/' 下 C/C++、Elisp、Java、JS/TS、Lua、
;;   Python、Web、Shell、JSON 和 YAML 模块；单个语言失败不会阻断其余语言。
;; - Markdown 与 LaTeX 的编辑/预览分别由 init-markdown 和 init-latex 独立管理。
;; - 编程语言统一启用语法高亮、Outline 和文件名/Buffer 词汇补全，默认缩进宽度为 2。
;; - LSP/补全/诊断分别由 init-lsp、init-completion 和 init-flymake 提供。
;; - 语言模块的 .elc 保存在 `runtimes/user-lisp/lang/'；源文件更新后会自动重编译。
;; - 新增语言时创建 `lang-名称.el'、写入 `(provide 'lang-名称)'，再加入上方模块列表。
;; - 打开文件后可用 `M-: major-mode' 确认模式，用 `M-x eglot' 手动检查服务器连接。
