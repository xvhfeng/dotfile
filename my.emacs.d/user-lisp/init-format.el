;;; init-format.el --- Apheleia 手动格式化与全文件选择 -*- lexical-binding: t; -*-

(require 'cl-lib)

;; Apheleia 只在显式调用时格式化；不启用保存时自动格式化，保留现有
;; `C-c c f' 的全 Buffer indent-region 行为，也避免与 Eglot 重复处理。
(use-package apheleia
  :straight (:host github :repo "radian-software/apheleia")
  :demand t
  :config
  ;; Org 与 PowerShell 没有本配置可由 Mason 安装的专用格式化器，仍通过
  ;; Apheleia 的 Lisp formatter 接口执行各自 major mode 的全文件缩进。
  (setf (alist-get 'my/indent-buffer apheleia-formatters)
        #'my/apheleia-indent-buffer)
  ;; .jsonc 含注释，不能交给默认的 JSON parser。
  (setf (alist-get 'prettier-jsonc apheleia-formatters)
        '("apheleia-npx" "prettier" "--stdin-filepath" filepath
          "--parser=jsonc"))
  ;; 上游已覆盖大多数传统/Tree-sitter 模式；这里只补齐或调整当前配置。
  (dolist (entry '((go-mode . gofumpt)
                   (go-ts-mode . gofumpt)
                   (sh-mode . shfmt)
                   (bash-ts-mode . shfmt)
                   (gfm-mode . prettier-markdown)
                   (markdown-mode . prettier-markdown)
                   (markdown-ts-mode . prettier-markdown)
                   (mhtml-mode . prettier-html)
                   (mhtml-ts-mode . prettier-html)
                   (org-mode . my/indent-buffer)
                   (powershell-mode . my/indent-buffer)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry)))
  ;; web-mode 也打开多种模板，Prettier 没有相应 parser；这些文件只缩进，
  ;; HTML/Vue 仍沿用 Apheleia 的 Prettier 配置。
  (dolist (entry '(("\\.jsonc\\'" . prettier-jsonc)
                   ("\\.\\(php\\|erb\\|[lh]eex\\|jsp\\|tpl\\|as[cp]x\\|ejs\\|hbs\\|mustache\\|svelte\\|twig\\|jinja2?\\|eco\\)\\'"
                    . my/indent-buffer)
                   ("\\.zsh\\'" . my/indent-buffer)))
    (push entry apheleia-mode-alist)))

(cl-defun my/apheleia-indent-buffer (&key buffer scratch callback &allow-other-keys)
  "让 Apheleia 在 SCRATCH 中按 BUFFER 的主模式缩进全部文本。"
  (with-current-buffer scratch
    ;; 避免在临时 Buffer 运行项目/LSP 等语言 hook；仅复制缩进所需设置。
    (delay-mode-hooks (funcall (buffer-local-value 'major-mode buffer)))
    (setq-local indent-line-function
                (buffer-local-value 'indent-line-function buffer))
    (setq-local indent-tabs-mode
                (buffer-local-value 'indent-tabs-mode buffer))
    (let ((inhibit-message t))
      (indent-region (point-min) (point-max)))
    (funcall callback)))

(defun my/apheleia-ensure-rustfmt ()
  "启动时检查 Rust 格式化器；有 rustup 时异步补装 rustfmt。"
  (unless (or noninteractive (executable-find "rustfmt"))
    (if-let* ((rustup (executable-find "rustup")))
        ;; rustfmt 是 Rust toolchain 组件，不在 Mason 注册表中；仅在缺失时
        ;; 调用现有 rustup，安装失败时保留可见日志和明确消息。
        (make-process
         :name "rustfmt-install"
         :buffer (get-buffer-create "*rustfmt-install*")
         :command (list rustup "component" "add" "rustfmt")
         :sentinel (lambda (process _event)
                     (when (memq (process-status process) '(exit signal))
                       (if (zerop (process-exit-status process))
                           (message "rustfmt 已由 rustup 安装")
                         (message "rustfmt 安装失败，详情见 *rustfmt-install*")))))
      (message "缺少 rustfmt 与 rustup；Rust 格式化需先安装 Rust toolchain"))))

(add-hook 'emacs-startup-hook #'my/apheleia-ensure-rustfmt)

(defun my/apheleia-format-code ()
  "用 Apheleia 为当前语言格式化整个 Buffer，缺少工具时明确提示。"
  (interactive)
  (require 'apheleia)
  (let ((formatters (apheleia--get-formatters)))
    (unless formatters
      (user-error "当前模式 %s 没有配置 Apheleia 格式化器" major-mode))
    (dolist (formatter formatters)
      (let ((command (alist-get formatter apheleia-formatters)))
        (unless command
          (user-error "Apheleia 格式化器 %s 未定义" formatter))
        ;; apheleia-npx 会优先寻找项目本地依赖，再回退 Mason 的 PATH；
        ;; 其他外部命令先检查，避免 Apheleia 静默跳过未安装的工具。
        (when (and (consp command)
                   (not (equal (car command) "apheleia-npx"))
                   (not (executable-find (car command))))
          (user-error "缺少 %s：等待 Mason 安装或运行 M-x my/mason-install-missing-packages"
                      (car command)))))
    ;; Apheleia 异步运行，临时的 save-restriction 会在完成前恢复缩窄；
    ;; 全文件入口需先解除缩窄，确保格式化器读取并写回完整 Buffer。
    (widen)
    (apheleia-format-buffer formatters)))

(defun my/format--indent-bounds (bounds)
  "按当前主模式的规则缩进 BOUNDS 指定的局部区域。"
  (unless (and (consp bounds)
               (integer-or-marker-p (car bounds))
               (integer-or-marker-p (cdr bounds))
               (< (car bounds) (cdr bounds)))
    (user-error "当前光标位置没有可格式化的代码区域"))
  ;; 外部格式化器通常要求完整语法单元；局部操作复用语言模式的缩进规则，
  ;; 只修改目标范围，也不与 Apheleia 的异步全文件格式化冲突。
  (save-excursion
    (indent-region (car bounds) (cdr bounds))))

(defun my/format-selected-region ()
  "仅格式化当前选中区域；没有选区时给出明确提示。"
  (interactive)
  (unless (use-region-p)
    (user-error "请先选中需要格式化的区域"))
  (my/format--indent-bounds (cons (region-beginning) (region-end))))

(defun my/format-current-indent-region ()
  "格式化光标所在缩进层级的区域，不改变其它块。"
  (interactive)
  ;; 与工作台的“选择当前缩进块”共用边界算法；不留下新选区。
  (unless (fboundp 'my/mark-indent-block)
    (require 'init-treesitter))
  (let ((bounds (save-mark-and-excursion
                  (my/mark-indent-block)
                  (cons (region-beginning) (region-end)))))
    (my/format--indent-bounds bounds)))

(defun my/format-current-function ()
  "格式化光标所在函数，包括函数签名和函数体。"
  (interactive)
  ;; Elisp 尚未缩进的函数体可能被通用 defun 检测当作顶层表达式；
  ;; 优先沿语法括号向外寻找真正的函数定义，其他语言沿用各主模式的边界。
  (my/format--indent-bounds
   (or (and (derived-mode-p 'emacs-lisp-mode 'lisp-mode)
            (my/format--elisp-function-bounds))
       (bounds-of-thing-at-point 'defun))))

(defun my/format--elisp-function-bounds ()
  "返回光标所在 Elisp 函数定义的边界，允许函数体尚未缩进。"
  (save-excursion
    (let ((opening (nth 1 (syntax-ppss))))
      (catch 'bounds
        (while opening
          (goto-char opening)
          (when (looking-at-p
                 "(\\(?:cl-\\)?\\(?:defun\\|defmacro\\|defsubst\\)\\_>")
            (when-let ((ending (ignore-errors (scan-sexps opening 1))))
              (throw 'bounds (cons opening ending))))
          (setq opening (nth 1 (syntax-ppss opening))))))))

(defun my/select-whole-buffer ()
  "解除缩窄并选择当前文件的全部内容。"
  (interactive)
  (widen)
  (mark-whole-buffer))

(with-eval-after-load 'general
  (my-leader-def
    "c F" '("格式化整个文件" . my/apheleia-format-code)
    "c R" '("格式化选中区域" . my/format-selected-region)
    "c i" '("格式化当前缩进区域" . my/format-current-indent-region)
    "c p" '("格式化当前函数" . my/format-current-function)
    "e b" '("选择整个文件" . my/select-whole-buffer)))

(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
   my-leader-map "c F" "格式化整个文件"
   "c R" "格式化选中区域"
   "c i" "格式化当前缩进区域"
   "c p" "格式化当前函数"
   "e b" "选择整个文件"))

(provide 'init-format)
;;; init-format.el ends here
