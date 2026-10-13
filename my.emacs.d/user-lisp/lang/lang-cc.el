;;; -*- lexical-binding: t -*-

;;; 中文导读：C/C++ 语言配置。使用 Emacs 内置 cc-mode 作为无 Tree-sitter 时的
;;; 稳定回退，Tree-sitter 可用时由全局 treesit-auto 自动切换，并接入 Eglot/Flymake。
(defvar my-clangd--query-driver
  (mapconcat #'identity (delq nil (list (executable-find "gcc")
                                        (executable-find "g++"))) ",")
  "clangd 用于查询系统编译器头文件的可执行文件列表。")

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
      ,@(when (not (string-empty-p my-clangd--query-driver))
          (list (concat "--query-driver=" my-clangd--query-driver)))
      ,(concat "--compile-commands-dir="
               (expand-file-name (if proj (project-root proj) default-directory))))))

(use-package cc-mode
  :straight nil
  ;; `cc-mode' 是库名，不是可调用的 major mode。扩展名必须明确映射到
  ;; `c-mode' / `c++-mode'，否则自动加载会寻找不存在的 `cc-mode' 函数。
  :mode (("\\.c\\'" . c-mode)
         ("\\.h\\'" . c-or-c++-mode)
         ("\\.\\(cc\\|cpp\\|cxx\\|hh\\|hpp\\|hxx\\|cppm\\|ixx\\)\\'" . c++-mode))
  :hook ((c-mode c++-mode c-ts-mode c++-ts-mode) . outline-minor-mode)
  :config
  (with-eval-after-load 'eglot
    ;; 为传统 C/C++ 模式和 Tree-sitter 模式复用同一份 clangd 参数。
    (dolist (mode '(c-mode c++-mode c-ts-mode c++-ts-mode))
      (add-to-list 'eglot-server-programs `(,mode . my-clangd-args)))))

(provide 'lang-cc)
