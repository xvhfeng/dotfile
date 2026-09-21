;;; -*- lexical-binding: t -*-

;;; 中文导读：终端与 REPL。shell/comint 运行系统 shell，Eshell 是 Emacs Lisp
;;; 实现的 shell，IELM 是 Emacs Lisp REPL，Ghostel 提供终端界面，tty-tip 显示
;;; 命令提示。C-: 执行单条 shell 命令，C-c C-` 打开 shell，C-c ` 打开 Eshell，
;;; C-` 打开 Ghostel；Ghostel 中 C-k 发送终端控制键并清理状态，前缀 map 的 m/M
;;; 打开项目终端或项目终端缓冲区列表。
;; 只有在非图形界面 (TTY/Terminal) 下才执行：关闭自动组字（防止某些复杂字符影响终端渲染性能）
(unless (display-graphic-p)
  (setq-default auto-composition-mode nil))

;; 终端 Child Frame 提示框配置
(use-package tty-tip
  :ensure nil
  :if (featurep 'tty-child-frames)             ; 仅当 Emacs 支持 tty-child-frames 特性时加载
  :hook (tty-setup . tty-tip-mode))            ; TTY 初始化完成后启动 tty-tip-mode

;; Emacs 内置 Shell 增强配置
(use-package shell
  :ensure nil                                  ; 内置包，无需下载
  :bind
  ("C-:" . shell-command)                      ; C-: 快速执行单条 Shell 命令
  ("C-c C-`" . shell)                          ; C-c C-` 打开/切换 Shell 缓冲区
  :hook
  (shell-mode . my-shell-mode-hook)            ; 进入 shell-mode 时调用的钩子
  (comint-output-filter-functions . comint-strip-ctrl-m) ; 过滤输出中的 ^M 换行符（修复 Windows/DOS 换行问题）
  :custom (system-uses-terminfo nil)           ; 不强制要求系统使用 terminfo 数据库
  :config
  ;; 自定义 Shell 发送指令的逻辑：拦截特定命令并用 Emacs 原生方式处理
  (defun my-shell-simple-send (proc command)
    "Various PROC COMMANDs pre-processing before sending to shell."
    (cond
     ;; 1. 输入 clear 时：不清空终端历史，而是清空当前 Emacs 缓冲区
     ((string-match "^[ \t]*clear[ \t]*$" command)
      (comint-send-string proc "\n")
      (erase-buffer))
     ;; 2. 输入 man <cmd> 时：拦截并调用 Emacs 内置的 man 函数打开格式化文档
     ((string-match "^[ \t]*man[ \t]*" command)
      (comint-send-string proc "\n")
      (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command))
      (setq command (replace-regexp-in-string "[ \t]+$" "" command))
      (funcall 'man command))
     ;; 3. 其他常规命令：使用 comint 默认发送方式
     (t (comint-simple-send proc command))))

  ;; Shell 模式 Hook：挂载按键与设置
  (defun my-shell-mode-hook ()
    "Shell mode customization."
    (local-set-key '[up] 'comint-previous-input)  ; 方向键 [上]：上一条历史命令
    (local-set-key '[down] 'comint-next-input)     ; 方向键 [下]：下一条历史命令
    (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input) ; Shift-Tab 匹配当前已输入内容的历史
    (ansi-color-for-comint-mode-on)                ; 开启 ANSI 转义彩色支持
    (setq comint-input-sender 'my-shell-simple-send))) ; 替换输入的发送处理函数

;; Eshell (Emacs Pure Lisp 实现的 Shell) 配置
(use-package eshell
  :ensure nil
  :bind ("C-c `" . eshell)                        ; C-c ` 打开 Eshell
  ;; 将 recenter-top-bottom (通常是 C-l) 重映射为 eshell/clear 清屏命令
  :hook (eshell-mode . (lambda () (local-set-key [remap recenter-top-bottom] 'eshell/clear)))
  :custom
  (eshell-history-size 100000)                    ; 历史记录条数限制为 10 万条
  (eshell-hist-ignoredups t)                      ; 忽略连续重复的历史命令
  :config
  ;; 设置 eshell/ebc 命令不对数值参数做类型转换
  (put 'eshell/ebc 'eshell-no-numeric-conversions t)

  ;; 为常用 Lisp 命令设置 Eshell 别名
  (defalias 'eshell/e #'eshell/emacs)
  (defalias 'eshell/ec #'eshell/emacs)
  (defalias 'eshell/more #'eshell/less)

  ;; 定义 eshell/clear：清空 Buffer 并重新输出一个 Prompt
  (defun eshell/clear ()
    "Clear the eshell buffer."
    (interactive)
    (let ((inhibit-read-only t))                  ; 忽略只读标记以允许清空
      (erase-buffer)
      (eshell-send-input)))                       ; 重新发送空输入以绘制 Prompt

  ;; 定义 eshell/emacs：在 Eshell 中直接用 find-file 打开传入的文件参数
  (defun eshell/emacs (&rest args)
    "Open a file (ARGS) in Emacs.  Some habits die hard."
    (if (null args)
        (bury-buffer)                             ; 无参数时隐藏当前 eshell 窗口
      (mapc #'find-file (mapcar #'expand-file-name (flatten-tree (reverse args))))))

  ;; 定义 eshell/ebc：在后台拉起 compile 编译进程
  (defun eshell/ebc (&rest args)
    "Compile a file (ARGS) in Emacs. Use `compile' to do background make."
    (if (eshell-interactive-output-p)
        (let ((compilation-process-setup-function
               (list 'lambda nil
                     (list 'setq 'process-environment
                           (list 'quote (eshell-copy-environment))))))
          (compile (eshell-flatten-and-stringify args))
          (pop-to-buffer compilation-last-buffer))
      (throw 'eshell-replace-command
             (let ((l (eshell-stringify-list (flatten-tree args))))
               (eshell-parse-command (car l) (cdr l))))))

  ;; 内部辅助函数：使用 view-mode 打开指定文件，退出时自动关闭 Buffer 并还原窗口
  (defun my-eshell-view-file (file)
    "View FILE.  A version of `view-file' which properly rets the eshell prompt."
    (interactive "fView file: ")
    (unless (file-exists-p file) (error "%s does not exist" file))
    (let ((buffer (find-file-noselect file)))
      (if (eq (get (buffer-local-value 'major-mode buffer) 'mode-class)
              'special)
          (progn
            (switch-to-buffer buffer)
            (message "Not using View mode because the major mode is special"))
        (let ((undo-window (list (window-buffer) (window-start)
                                 (+ (window-point)
                                    (length (funcall eshell-prompt-function))))))
          (switch-to-buffer buffer)
          (view-mode-enter (cons (selected-window) (cons nil undo-window))
                           'kill-buffer)))))

  ;; 定义 eshell/less：模拟 Unix 的 less 命令，支持 `less +42 filename` 直接跳转到指定行
  (defun eshell/less (&rest args)
    "Invoke `view-file' on a file (ARGS).
\"less +42 foo\" will go to line 42 in the buffer for foo."
    (while args
      (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
          (let* ((line (string-to-number (match-string 1 (pop args))))
                 (file (pop args)))
            (eshell-view-file file)
            (forward-line line))
        (my-eshell-view-file (pop args)))))  )

;; IELM (Inferior Emacs Lisp Mode) 配置
(use-package ielm
  :ensure nil
  :custom (ielm-history-file-name (concat nn-directory "ielm-history.eld")) ; 设置历史记录保存路径
  :config
  ;; 扩展 ielm-font-lock-keywords：为 IELM REPL 添加真正的 Elisp 语法高亮
  (setq ielm-font-lock-keywords
        (append
         '(("\\(^\\*\\*\\*[^*]+\\*\\*\\*\\)\\(.*$\\)" ; 高亮 *** 警告/系统信息
            (1 font-lock-comment-face)
            (2 font-lock-constant-face)))
         ;; 动态注入 lisp-el 及 lisp-cl 的语法高亮规则
         (cl-loop for (matcher . match-highlights)
                  in (append lisp-el-font-lock-keywords-2
                             lisp-cl-font-lock-keywords-2)
                  collect
                  `((lambda (limit)
                      (when ,(if (symbolp matcher)
                                 `(,matcher limit)
                               `(re-search-forward ,matcher limit t))
                        ;; 仅高亮 Prompt（提示符）之后的用户输入部分
                        (> (match-beginning 0) (car comint-last-prompt))
                        ;; 确保当前匹配不在注释或字符串内部
                        (let ((state (syntax-ppss)))
                          (not (or (nth 3 state)
                                   (nth 4 state))))))
                    ,@match-highlights)))))

;; Ghostel (现代化 Terminal Emulator 扩展) 配置
(use-package ghostel
  :commands ghostel
  :bind
  (("C-`" . ghostel)                           ; C-` 快速唤出 Ghostel 终端
   :map ghostel-semi-char-mode-map
   ("C-k" . my-ghostel-send-C-k-and-kill)      ; C-k: 发送 C-k 到终端并同步复制行到剪切板
   ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl"))) ; M-p 转发为 Ctrl-p (上一条历史)
   ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl"))) ; M-n 转发为 Ctrl-n (下一条历史)
   :map project-prefix-map
   ("m" . ghostel-project)                     ; Project 菜单下按 m：在项目根目录拉起终端
   ("M" . ghostel-project-list-buffers))       ; Project 菜单下按 M：列出当前项目的终端 Buffer
  :custom (ghostel-term "xterm-256color")      ; 设置默认终端类型为 256 色 xterm
  :config
  ;; 自定义处理 C-k：既向远端终端进程发送 Ctrl-k，又将当前光标到行尾的内容保存到 Emacs Kill-ring (剪贴板)
  (defun my-ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  ;; 将 Ghostel 接入 Emacs 内置 project.el 的 `project-switch-project` 菜单选项中
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  
  ;; 注册可在 Ghostel 内部安全求值的指令（如 magit 相关操作）
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer))
  
  ;; 弹窗规则配置：所有名字为 *ghostel* 的缓冲区，默认在当前选中窗口下方弹出，高度占 35%
  (add-to-list 'display-buffer-alist
               '("\\*ghostel\\*"
                 (display-buffer-below-selected)
                 (window-height . 0.35))))

(provide 'init-terminal)
