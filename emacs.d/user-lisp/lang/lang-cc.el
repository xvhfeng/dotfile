;;; -*- lexical-binding: t -*-

;;; 中文导读：C/C++ 语言配置。simpc-mode 是轻量的 C/C++ major mode，负责文件
;;; 关联、语法高亮、缩进与结构导航，并接入通用的 Eglot/Flymake 编辑链。
(defvar my-clangd--query-driver
  (concat (executable-find "gcc") "," (executable-find "g++")))

;; 返回启动 clangd 使用的命令行参数列表，供 Eglot 创建 C/C++ 语言服务器进程。
(defun my-clangd-args (_interactive)
  (let ((proj (project-current)))
    `("clangd"
      "--clang-tidy"
      "--limit-results=15"
      "--header-insertion=never"
      "--background-index"
      "--pch-storage=memory"
      "--experimental-modules-support"
      ,(concat "--query-driver=" my-clangd--query-driver)
      ,(concat "--compile-commands-dir="
               (expand-file-name (if proj (project-root proj) default-directory))))))

(use-package simpc-mode
  :ensure nil
  :mode "\\.\\(c\\|h\\|cpp\\|hpp\\|cppm\\|ixx\\)\\'"
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '(simpc-mode . my-clangd-args))))

(provide 'lang-cc)
