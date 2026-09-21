;;; -*- lexical-binding: t -*-

;;; 中文导读：诊断与拼写检查。Flymake 显示编译器/LSP 问题，Flyspell/ispell 检查
;;; 自然语言拼写。F8 跳到下一条问题，S-F8 回到上一条，C-F8 打开当前缓冲区诊断
;;; 列表；Flyspell map 中清空 C-;/C-,/C-.，避免与全局快捷键冲突。
;; 配置 Emacs 内置的拼写检查基础前端 interface (ispell)
(use-package ispell
  :ensure nil                                                  ; 使用内置包，不从 ELPA 下载
  :custom
  (ispell-program-name "aspell")                               ; 指定拼写检查的可执行程序后端为 aspell
  (ispell-local-dictionary "en_US")                            ; 默认使用美式英语字典
  (ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together")) ; 给 aspell 传递参数：极速建议模式、美式英语、允许识别拼在一起的复合词
  (ispell-alternate-dictionary nil))                           ; 不使用备用字典文件

;; 配置 Emacs 内置的实时拼写检查前端 (flyspell)
(use-package flyspell
  :ensure nil                                                  ; 使用内置包
  :if (executable-find "aspell")                               ; 仅当系统环境变量中能找到 aspell 可执行文件时才加载
  :bind
  (:map flyspell-mode-map
   ("C-;" . nil)                                               ; 解绑 flyspell 默认占用的 C-; 快捷键，防止与自定义补全冲突
   ("C-," . nil)                                               ; 解绑 C-,
   ("C-." . nil))                                              ; 解绑 C-.
  :hook (org-mode markdown-ts-mode TeX-mode rst-mode message-mode git-commit-setup) ; 在这些文档/写作模式下自动开启实时拼写检查
  :custom
  (flyspell-issue-message-flag nil)                            ; 禁用纠错时在 echo area 输出提示消息，减少打扰
  (flyspell-issue-welcome-flag nil))                           ; 禁用开启 flyspell 时的欢迎/加载提示

;; 配置 Emacs 内置的代码语法检查与诊断框架 (flymake)
(use-package flymake
  :ensure nil                                                  ; 使用内置包
  :bind
  (:map flymake-mode-map
   ("<f8>"   . flymake-goto-next-error)                        ; F8: 跳转到下一个语法错误/警告
   ("<S-f8>" . flymake-goto-prev-error)                        ; Shift+F8: 跳转到上一个语法错误/警告
   ("<C-f8>" . flymake-show-buffer-diagnostics))               ; Ctrl+F8: 弹出当前 Buffer 的所有诊断信息面板
  :hook (flymake-mode .  (lambda () (setq-local next-error-function #'flymake-goto-next-error))) ; 覆盖标准 next-error 行为，统一使用 Flymake 的错误跳转
  :custom
  (flymake-no-changes-timeout nil)                             ; 禁用基于空闲时间的自动语法检查（仅在保存/主动触发时检查）
  (flymake-wrap-around nil)                                    ; 报错跳转到末尾时不自动折返回开头
  (flymake-fringe-indicator-position nil)                      ; 关闭左侧 fringe 边缘处的错误指示图标
  (flymake-margin-indicators-string                           ; 自定义窗口 margin 边缘处的错误指示文本（此处均设为空字符以保持干净）
   '((error "" compilation-error)
     (warning "" compilation-warning)
     (note "" compilation-info)))
  (flymake-show-diagnostics-at-end-of-line t)                  ; 在代码行的末尾直接内联显示诊断提示信息
  :config
  (setq-default next-error-find-buffer-function #'next-error-buffer-unnavigated-current) ; 设置 next-error 优先选择当前未导航过的 Buffer

  ;; 为 Elisp 的 Flymake 字节编译检查添加 advice
  (define-advice elisp-flymake-byte-compile (:before-while (&rest _) check-git-repo)
    "Only enable elisp flymake if inside a git repo."
    (locate-dominating-file default-directory ".git"))         ; 只有在当前文件处于 Git 仓库内部时，才允许执行 Elisp 语法编译检查

  ;; saveing check
  ;; 为 Eglot (LSP) 处理服务器推送通知的方法添加 :after 切面
  (cl-defmethod eglot-handle-notification :after
    (_server (_method (eql textDocument/publishDiagnostics)) &key uri
             &allow-other-keys)
    ;; 当收到 LSP 服务器推送的 publishDiagnostics (诊断通知) 时
    (when-let* ((buffer (find-buffer-visiting (eglot-uri-to-path uri))))
      (with-current-buffer buffer
        ;; 如果设置了不基于时间自动检查且当前 Buffer 没有未保存的修改，则强制刷新并启动 Flymake 渲染最新的诊断结果
        (if (and (eq nil flymake-no-changes-timeout)
                 (not (buffer-modified-p)))
            (flymake-start t))))))

(provide 'init-diagnostics)
