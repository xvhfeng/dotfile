;;; -*- lexical-binding: t -*-

;;; 中文导读：Shell 语言配置。sh-script 处理 sh/bash/zsh 等脚本，PowerShell 包
;;; 处理 *.ps1；这里设置解释器关联、缩进和通用语言工具接入。
(use-package sh-script
  :ensure nil
  :mode "\\.\$$?:bats\\|zunit\\|env\\\'" "/bspwmrc\\'"
  :hook
  ;; 1. Fontifies variables in double quotes
  ;; 2. Fontify command substitution in double quotes
  ;; 3. Fontify built-in/common commands (see `+sh-builtin-keywords')
  (sh-mode . my-sh-init-extra-fontification-h)
  :custom (sh-indent-after-continuation 'always)
  :config
  (add-to-list 'sh-imenu-generic-expression
               '(sh (nil "^\\s-*function\\s-+\\([[:alpha:]_-][[:alnum:]_-]*\\)\\s-*\\(?:()\\)?" 1)
                    (nil "^\\s-*\\([[:alpha:]_-][[:alnum:]_-]*\\)\\s-*()" 1)))

  (defconst my-sh-builtin-keywords
    '("cat" "cd" "chmod" "chown" "cp" "curl" "date" "echo" "find" "git" "grep"
      "kill" "less" "ln" "ls" "make" "mkdir" "mv" "pgrep" "pkill" "pwd" "rm"
      "sleep" "sudo" "touch")
    "A list of common shell commands to be fontified especially in `sh-mode'.")

  ;; 在 LIMIT 前匹配双引号字符串中的 $变量，供额外语法着色规则使用。
  (defun my-sh--match-variables-in-quotes (limit)
    "Search for variables in double-quoted strings bounded by LIMIT."
    (with-syntax-table sh-mode-syntax-table
      (let (res)
        (while
            (and (setq res
                       (re-search-forward
                        "[^\\]\\(\\$\\)\\({.+?}\\|\\<[a-zA-Z0-9_]+\\|[@*#!]\\)"
                        limit t))
                 (not (eq (nth 3 (syntax-ppss)) ?\"))))
        res)))

  ;; 在 LIMIT 前匹配双引号中的 $(命令替换)，以独立 face 突出显示。
  (defun my-sh--match-command-subst-in-quotes (limit)
    "Search for variables in double-quoted strings bounded by LIMIT."
    (with-syntax-table sh-mode-syntax-table
      (let (res)
        (while
            (and (setq res
                       (re-search-forward
                        "[^\\]\\(\\$(.+?)\\|`.+?`\\)"
                        limit t))
                 (not (eq (nth 3 (syntax-ppss)) ?\"))))
        res)))

  ;; 进入 Shell 模式时安装变量和命令替换的额外 font-lock 规则。
  (defun my-sh-init-extra-fontification-h ()
    (font-lock-add-keywords
     nil `((my-sh--match-variables-in-quotes
            (1 'font-lock-constant-face prepend)
            (2 'font-lock-variable-name-face prepend))
           (my-sh--match-command-subst-in-quotes
            (1 'sh-quoted-exec prepend))
           (,(regexp-opt my-sh-builtin-keywords 'symbols)
            (0 'font-lock-type-face append))))))

(use-package powershell
  :custom (powershell-indent-level nn-indent-offset))

(provide 'lang-shell)
