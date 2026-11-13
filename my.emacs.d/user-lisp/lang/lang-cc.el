;;; -*- lexical-binding: t -*-

;;; 中文导读：C/C++ 语言配置。使用 Emacs 内置 cc-mode 作为无 Tree-sitter 时的
;;; 稳定回退，Tree-sitter 可用时由全局 treesit-auto 自动切换，并接入 Eglot/Flymake。
(require 'cl-lib)
(require 'imenu)
(require 'subr-x)

(defun my/c-imenu-list--contains-entry-p (index candidate)
  "Return non-nil if INDEX contains CANDIDATE at the same line."
  (cl-some (lambda (entry)
             (if (imenu--subalist-p entry)
                 (my/c-imenu-list--contains-entry-p (cdr entry) candidate)
               (and (equal (car entry) (car candidate))
                    (number-or-marker-p (cdr entry))
                    (= (line-number-at-pos (cdr entry))
                       (line-number-at-pos (cdr candidate))))))
           index))

(defun my/c-imenu-list--function-declaration-p (node)
  "Return non-nil for a C function declaration NODE."
  (let ((declarator (treesit-node-child-by-field-name node "declarator")))
    (and declarator
         (equal (treesit-node-type declarator) "function_declarator")
         (not (treesit-node-top-level node "function_definition")))))

(defun my/c-imenu-list--named-type-p (node)
  "Return non-nil for a named, top-level C type NODE."
  (and (treesit-node-child-by-field-name node "name")
       (c-ts-mode--defun-valid-p node)))

(defun my/c-imenu-list--declarator-name (node)
  "Return the identifier nested inside declarator NODE."
  (if (member (treesit-node-type node) '("identifier" "type_identifier"))
      (treesit-node-text node t)
    (cl-loop for child in (treesit-node-children node)
             thereis (my/c-imenu-list--declarator-name child))))

(defun my/c-imenu-list--typedef-name (node)
  "Return the declared name of C typedef NODE."
  (when-let ((declarator (treesit-node-child-by-field-name node "declarator")))
    (my/c-imenu-list--declarator-name declarator)))

(defun my/c-imenu-list--tree-index ()
  "Return C symbols from Tree-sitter, including declarations and types."
  (when (and (fboundp 'treesit-language-available-p)
             (treesit-language-available-p 'c))
    (require 'c-ts-mode)
    (treesit-parser-create 'c)
    (let ((treesit-simple-imenu-settings
           '(("函数定义" "\\`function_definition\\'"
              c-ts-mode--defun-valid-p c-ts-mode--defun-name)
             ("函数声明" "\\`declaration\\'"
              my/c-imenu-list--function-declaration-p c-ts-mode--defun-name)
             ("结构体" "\\`struct_specifier\\'"
              my/c-imenu-list--named-type-p c-ts-mode--defun-name)
             ("枚举" "\\`enum_specifier\\'"
              my/c-imenu-list--named-type-p c-ts-mode--defun-name)
             ("联合体" "\\`union_specifier\\'"
              my/c-imenu-list--named-type-p c-ts-mode--defun-name)
             ("类型定义" "\\`type_definition\\'"
              nil my/c-imenu-list--typedef-name))))
      (treesit-simple-imenu))))

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
  "Add missing C symbols after ORIGINAL Imenu List rescan."
  (apply original args)
  (when (derived-mode-p 'c-mode 'c-ts-mode)
    (dolist (group (append (my/c-imenu-list--tree-index)
                           (list (cons "宏定义" (my/c-imenu-list--macros)))))
      (let ((missing (cl-remove-if
                      (lambda (entry)
                        (my/c-imenu-list--contains-entry-p
                         imenu--index-alist entry))
                      (cdr group))))
        (when missing
          (setq imenu--index-alist
                (append imenu--index-alist
                        (list (cons (car group) missing))))))))
    ;; Without a C grammar, keep cc-mode's function index as a fallback.
    (unless (and (fboundp 'treesit-language-available-p)
                 (treesit-language-available-p 'c))
      (let ((missing (cl-remove-if
                      (lambda (entry)
                        (my/c-imenu-list--contains-entry-p
                         imenu--index-alist entry))
                      (imenu-default-create-index-function))))
        (when missing
          (setq imenu--index-alist
                (append imenu--index-alist (list (cons "本地函数" missing)))))))
  imenu--index-alist)

(with-eval-after-load 'imenu-list
  (advice-add 'imenu-list-rescan-imenu :around #'my/c-imenu-list--rescan))

(defun my/c-ts-outline-predicate (node)
  "Include C functions, declarations, macros and types in Outline."
  (or (c-ts-mode--outline-predicate node)
      (member (treesit-node-type node)
              '("preproc_def" "preproc_function_def"
                "struct_specifier" "union_specifier" "enum_specifier"
                "type_definition"))
      (and (equal (treesit-node-type node) "function_declarator")
           (equal (treesit-node-type (treesit-node-parent node))
                  "declaration"))))

(defun my/c-ts-outline-setup ()
  "Use the expanded Outline heading rules in C Tree-sitter buffers."
  (setq-local treesit-outline-predicate #'my/c-ts-outline-predicate))

(add-hook 'c-ts-mode-hook #'my/c-ts-outline-setup)

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
