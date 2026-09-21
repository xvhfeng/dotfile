;;; -*- lexical-binding: t -*-

;;; 中文导读：自定义 mode-line 的组成、顺序和样式，显示缓冲区状态、文件名、位置、
;;; 主/次模式、编码、项目或版本控制信息。相关函数只生成状态栏文本和 face，不会
;;; 修改缓冲区内容。
;; 声明各种换行符（End-Of-Line）在 Mode-line 上的简写（Unix 为 LF，DOS 为 CRLF 等）
(setq eol-mnemonic-unix "LF"
      eol-mnemonic-dos "CRLF"
      eol-mnemonic-mac "CR"
      eol-mnemonic-undecided "?")

;; 全局禁用默认的 mode-line-format（防止未专门启用的 Buffer 显示冗余默认状态栏）
(setq-default mode-line-format nil)

;; 定义全局缓存变量（缓存所有已可用的 Major Mode 列表，避免频繁扫描卡顿）
(defvar nn-mode-line--prog-modes-cache nil)
;; 定义 Buffer 局部（Buffer-Local）缓存变量，避免每次重绘（Redraw）重复计算性能开销
(defvar-local nn-mode-line--vc-cache nil)        ; Git/VC 分组缓存
(defvar-local nn-mode-line--eglot-cache nil)     ; Eglot LSP 状态缓存
(defvar-local nn-mode-line--flymake-cache nil)   ; Flymake 诊断文本缓存
(defvar-local nn-mode-line--flymake-counts '(0 0 0)) ; 诊断计数：(错误 警告 提示)

;; 定义使用的 Nerd-Icons 图标常量
(defconst nn-mode-line-error   (nerd-icons-codicon   "nf-cod-error"))    ; 错误图标
(defconst nn-mode-line-warning (nerd-icons-codicon   "nf-cod-warning"))  ; 警告图标
(defconst nn-mode-line-info    (nerd-icons-codicon   "nf-cod-info"))     ; 信息/提示图标
(defconst nn-mode-line-git     (nerd-icons-powerline "nf-pl-branch"))    ; Git 分支图标

;; 工具函数：给 TEXT 附加悬停提示 HELP 和鼠标左键点击命令 CMD，生成可交互文本片段
(defun nn-mode-line--prop (text help cmd)
  (propertize
   text
   'mouse-face 'highlight                                              ; 鼠标悬停高亮 Face
   'help-echo help                                                     ; 悬停提示文本
   'local-map (let ((map (make-sparse-keymap)))                        ; 绑定鼠标左键点击事件
                (keymap-set map "<mode-line> <mouse-1>" cmd)
                map)))

;; 格式化并返回 Git/VC 分组信息（带有缓存）
(defun nn-mode-line-vc-format ()
  (or nn-mode-line--vc-cache                                           ; 若有缓存直接返回
      (setq nn-mode-line--vc-cache
            (concat
             nn-mode-line-git " "                                      ; 拼接 Git 图标
             (if-let* ((root (vc-root-dir))                           ; 查找 Git 根目录
                       (backend (vc-responsible-backend root)))       ; 确认 VC 后端 (如 Git)
                 (let ((b (string-trim-left                            ; 正则裁剪后端名前缀，提取纯分支名
                           (substring-no-properties
                            (vc-call-backend backend 'mode-line-string root))
                           "[A-Za-z]+[-:] ?")))
                   (if (string-empty-p b) "?" b))
               "!")))))                                                ; 非 VC 项目或出错显示 !

;; 格式化并汇总 Flymake 诊断数量（带有缓存，点击弹窗查看诊断明细列表）
(defun nn-mode-line-flymake-format ()
  (or nn-mode-line--flymake-cache
      (setq nn-mode-line--flymake-cache
            (nn-mode-line--prop
             (format "%s %d %s %d %s %d"                               ; 拼接错误、警告、提示图标与具体数量
                     nn-mode-line-error (nth 0 nn-mode-line--flymake-counts)
                     nn-mode-line-warning (nth 1 nn-mode-line--flymake-counts)
                     nn-mode-line-info (nth 2 nn-mode-line--flymake-counts))
             "mouse-1: diagnostics" #'flymake-show-buffer-diagnostics)))) ; 点击打开诊断面板

;; 格式化并返回 Eglot LSP 服务器状态（带有缓存，点击可直接打开 LSP 错误日志 Buffer）
(defun nn-mode-line-eglot-format ()
  (or nn-mode-line--eglot-cache
      (when (bound-and-true-p eglot--managed-mode)                     ; 确认当前启用了 eglot
        (setq nn-mode-line--eglot-cache
              (nn-mode-line--prop
               (pcase (alist-get major-mode eglot-server-programs)      ; 提取当前语言对应的 LSP 名称
                 ((and (pred stringp) name) name)
                 (`(,name . ,_) name)
                 (_ "lsp"))
               "mouse-1: LSP log"
               (lambda () (interactive)                                ; 点击事件：切换并查看 LSP 日志
                 (if-let* ((s (eglot-current-server))
                           (buf (eglot--stderr-buffer s)))
                     (switch-to-buffer-other-window buf)
                   (message "No LSP server"))))))))

;; 格式化行号列号信息（L行 C列），点击弹窗可输入跳转点位（如 42:10 调至 42 行 10 列）
(defun nn-mode-line-position-format ()
  (when display-line-numbers-mode                                      ; 开启行号模式时才展示
    (nn-mode-line--prop
     (format "L%s C%s"
             (format-mode-line "%l")                                   ; 动态获取当前行号
             (format-mode-line "%c"))                                  ; 动态获取当前列号
     "mouse-1: goto line:col"
     (lambda () (interactive)                                          ; 点击弹窗提示跳转
       (let ((input (read-string "Goto line:col (e.g. 42:10): ")))
         (when (string-match "^\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?$" input)
           (goto-line (string-to-number (match-string 1 input)))
           (when (match-string 2 input)
             (move-to-column (string-to-number (match-string 2 input))))))))))

;; 格式化编码格式（如 utf-8-unix），点击可快捷选择保存编码或按新编码重新加载（Reopen）
(defun nn-mode-line-encoding-format ()
  (nn-mode-line--prop
   (symbol-name buffer-file-coding-system)                             ; 获取当前 Buffer 的编码符号
   "mouse-1: encoding"
   (lambda () (interactive)
     (let* ((coding (read-coding-system "Coding system: "))            ; 读取目标编码
            (action (completing-read "Action: " '("Save" "Reopen") nil t))) ; 选择保存还是重新读取
       (if (string= action "Save")
           (progn (set-buffer-file-coding-system coding)
                  (message "Save as %s" coding))
         (revert-buffer-with-coding-system coding)
         (save-buffer))))))

;; 从 auto-mode-alist 中扫一遍提取并缓存系统中可用的编程语言列表，提供提示和补全
(defun nn-mode-line--prog-modes ()
  (or nn-mode-line--prog-modes-cache
      (setq nn-mode-line--prog-modes-cache
            (let ((modes '()))
              (dolist (entry auto-mode-alist)
                (let ((mode (cdr entry)))
                  (when (and (symbolp mode)
                             (not (memq mode modes))
                             (not (memq mode '(fundamental-mode special-mode))))
                    (push mode modes))))
              (sort (mapcar (lambda (m) (string-trim-right (symbol-name m) "-mode$")) modes)
                    #'string<)))))

;; 格式化 Major Mode 模式名称（去掉了多余的 -mode 后缀），点击可一键切换主模式
(defun nn-mode-line-mode-format ()
  (nn-mode-line--prop
   (string-trim-right (symbol-name major-mode) "-mode$")
   "mouse-1: switch major mode"
   (lambda () (interactive)
     (let* ((name (completing-read "Language: " (nn-mode-line--prog-modes) nil t)) ; 补全可用的语言
            (mode (intern (concat name "-mode"))))
       (when (commandp mode)
         (funcall mode))))))                                           ; 执行切换命令

;; Viper 快捷模式指示符（显示 Vim 风格的 NORMAL / INSERT / VISUAL / REPLACE 状态）
(defun nn-viper-mode-format ()
  (when (bound-and-true-p viper-mode)
    (if mark-active "VISUAL"                                           ; 选中区域时显示 VISUAL
      (pcase viper-current-state
        ('vi-state      "NORMAL")
        ('insert-state  "INSERT")
        ('replace-state "REPLACE")
        ('emacs-state   "EMACS")))))

;; Advice 1：当 Git/VC 状态刷新时，清空 VC 缓存以重新生成分支名
(define-advice vc-refresh-state (:after (&rest _) reset-nn-vc-cache)
  (setq nn-mode-line--vc-cache nil))

;; Advice 2：当 Flymake 诊断完成时，更新诊断数量并清空 Flymake 缓存
(define-advice flymake--handle-report (:after (&rest _) reset-nn-flymake-cache)
  (setq nn-mode-line--flymake-cache nil
        nn-mode-line--flymake-counts
        `(,(string-to-number (format-mode-line flymake-mode-line-error-counter))
          ,(string-to-number (format-mode-line flymake-mode-line-warning-counter))
          ,(string-to-number (format-mode-line flymake-mode-line-note-counter)))))

;; Advice 3：当 Eglot 开启或关闭时，清空 Eglot 缓存
(define-advice eglot--managed-mode (:after (&rest _) reset-nn-eglot-cache)
  (setq nn-mode-line--eglot-cache nil))

;; 定义最终组装的全局 Mode-line 结构
(defconst nn-mode-line-format
  '("%e"                                                               ; 内存不足提示
    "  " (:eval (nn-viper-mode-format))                               ; 左侧：Vim 状态
    "  " (:eval (nn-mode-line-vc-format))                              ; 左侧：Git 分支
    "  " "%b"                                                          ; 左侧：文件名/Buffer 名
    "  " (:eval (nn-mode-line-flymake-format))                        ; 左侧：Flymake 诊断
    "  " (:eval (nn-mode-line-eglot-format))                          ; 左侧：LSP 状态
    "  " mode-line-misc-info                                           ; 左侧：其他杂项（如 timer 等）
    mode-line-format-right-align                                       ; 核心：使之后的项目强行靠右对齐 (Emacs 30+)
    "  " (:eval (nn-mode-line-position-format))                       ; 右侧：行号/列号 (L42 C10)
    "  " (:eval (nn-mode-line-encoding-format))                       ; 右侧：文件编码 (utf-8-unix)
    "  " (:eval (if current-input-method "C" "A"))                     ; 右侧：输入法指示 (Chinese / ASCII)
    "  " (:eval (nn-mode-line-mode-format))                           ; 右侧：Major Mode 名称
    "  "))

;; 挂载 Hook：在代码、文本、配置、Dired 缓冲区中开启并应用该自定义 Mode-line，并初始化缓存
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook dired-mode-hook))
  (add-hook hook
            (lambda ()
              (setq nn-mode-line--vc-cache nil
                    nn-mode-line--eglot-cache nil
                    nn-mode-line--flymake-cache nil)
              (setq-local mode-line-format nn-mode-line-format))))
(provide 'init-mode-line)
