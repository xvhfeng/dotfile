;;; -*- lexical-binding: t -*-

;;; 中文导读：C/C++ 语言配置。使用 Emacs 内置 cc-mode 作为无 Tree-sitter 时的
;;; 稳定回退，Tree-sitter 可用时由全局 treesit-auto 自动切换，并接入 Eglot/Flymake。
(require 'cl-lib)
(require 'imenu)

(defun my/c-imenu-list--contains-name-p (index name)
  "Return non-nil if INDEX contains a leaf named NAME."
  (cl-some (lambda (entry)
             (if (imenu--subalist-p entry)
                 (my/c-imenu-list--contains-name-p (cdr entry) name)
               (equal (car entry) name)))
           index))

(defun my/c-imenu-list--macros ()
  "Return `#define' entries from the current C buffer."
  (let (entries)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              "^[[:blank:]]*#[[:blank:]]*define[[:blank:]]+\\([[:alpha:]_][[:alnum:]_]*\\)"
              nil t)
        (let ((start (match-beginning 1))
              (name (match-string-no-properties 1)))
          (unless (nth 4 (syntax-ppss start))
            (push (cons name (copy-marker start)) entries)))))
    (nreverse entries)))

(defun my/c-imenu-list--rescan (original &rest args)
  "Add missing C functions and macros after ORIGINAL Imenu List rescan."
  (apply original args)
  (when (derived-mode-p 'c-mode 'c-ts-mode)
    (let* ((native-index (if (derived-mode-p 'c-ts-mode)
                             (cdr (assoc "Function" (treesit-simple-imenu)))
                           (imenu-default-create-index-function)))
           (functions (cl-remove-if
                       (lambda (entry)
                         (my/c-imenu-list--contains-name-p
                          imenu--index-alist (car entry)))
                       native-index))
           (macros (cl-remove-if
                    (lambda (entry)
                      (my/c-imenu-list--contains-name-p
                       imenu--index-alist (car entry)))
                    (my/c-imenu-list--macros))))
      (when functions
        (setq imenu--index-alist
              (append imenu--index-alist (list (cons "本地函数" functions)))))
      (when macros
        (setq imenu--index-alist
              (append imenu--index-alist (list (cons "宏定义" macros)))))))
  imenu--index-alist)

(with-eval-after-load 'imenu-list
  (advice-add 'imenu-list-rescan-imenu :around #'my/c-imenu-list--rescan))

(defconst my/clangd-executable
  (or (and (eq system-type 'darwin)
           (file-executable-p "/opt/homebrew/opt/llvm/bin/clangd")
           "/opt/homebrew/opt/llvm/bin/clangd")
      (executable-find "clangd")
      "clangd")
  "稳定的 clangd 可执行文件，macOS 优先使用 Homebrew LLVM 版本。")

(defvar my-clangd--query-driver
  (mapconcat #'identity (delq nil (list (executable-find "gcc")
                                        (executable-find "g++"))) ",")
  "clangd 用于查询系统编译器头文件的可执行文件列表。")

;; 返回启动 clangd 使用的命令行参数列表，供 Eglot 创建 C/C++ 语言服务器进程。
(defun my-clangd-args (_interactive)
  (let ((proj (project-current)))
    `(,my/clangd-executable
      "--clang-tidy"
      "--limit-results=15"
      "--header-insertion=never"
      "--background-index"
      "--pch-storage=memory"
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
