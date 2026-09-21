;;; -*- lexical-binding: t -*-

;;; 中文导读：全局定义与路径模块。这里集中声明其他配置共享的目录、平台判断、
;;; 常量和基础辅助函数；把这些定义提前加载，可避免后续模块各自硬编码缓存、数据
;;; 或外部程序路径。此文件本身不负责界面功能，而是其余 init-* 模块的依赖层。
;; 定义名为 nn 的自定义配置组（用户个性化定制组）
(defgroup nn nil
  "Personal customization group."
  :prefix "nn-")

;; 定义自定义变量：nn 的基础数据/配置文件存放目录（默认 ~/.emacs.d/.nn/）
(defcustom nn-directory (expand-file-name "~/.emacs.d/.nn/")
  "Base directory for nn."
  :type 'directory
  :group 'nn)

;; 定义自定义变量：是否在所有 Buffer 中默认开启拼写检查 (Flyspell)
(defcustom nn-flyspell-everywhere t
  "Non-nil to enable flyspell in all buffers."
  :type 'boolean
  :group 'nn)

;; 定义自定义变量：是否启用 Vim 输入法/模式
(defcustom nn-vim-mode nil
  "Enbale vim input method."
  :type 'boolean
  :group 'nn)

;; 定义自定义变量：代码折叠或截断时显示的字符串符号（默认 "…"）
(defcustom nn-fold-string "…"
  "String used for folding/truncating display."
  :type 'string
  :group 'nn)

;; 定义自定义变量：默认代码缩进偏移量（默认 2 个空格）
(defcustom nn-indent-offset 2
  "Default code indent ossfet."
  :type 'number
  :group 'nn)

;; 定义自定义变量：VPN 代理端口（默认 7897）
(defcustom nn-proxy-port 7897
  "VPN Proxy port."
  :type 'number
  :group 'nn)

;; 定义自定义变量：补全框架选择（可选 corfu 或 completion-preview）
(defcustom nn-completion-style 'corfu
  "Completion framework to use."
  :type '(choice
          (const :tag "Corfu" corfu)
          (const :tag "Completion-preview" completion-preview))
  :group 'nn)

;; 定义自定义变量：允许在特定特殊上下文中保留的 Buffer 名称列表
(defcustom nn-buffer-allow-names
  '("*compilation*" "*eshell*" "*ghostel*")
  "List of buffer names allowed in special contexts."
  :type '(repeat string)
  :group 'nn)

;; 定义自定义变量：用户进行首次键盘/鼠标输入前运行的一次性 Hook 句柄
(defcustom nn-first-input-hook ()
  "Transient hooks run before the first user input."
  :type 'hook
  :group 'nn)

;; 定义自定义变量：用户首次交互式打开文件前运行的一次性 Hook 句柄
(defcustom nn-first-file-hook ()
  "Transient hooks run before the first interactively opened file."
  :type 'hook
  :group 'nn)

;; 当 TRIGGER-HOOKS 任一触发且 PREDICATE 成立时运行 HOOK-VAR，统一派发自定义 hook。
(defun nn-run-hook-on (hook-var trigger-hooks &optional predicate)
  "Configure HOOK-VAR to be invoked exactly once when any of the TRIGGER-HOOKS
are invoked *after* Emacs has initialized (to reduce false positives). Once
HOOK-VAR is triggered, it is reset to nil.

HOOK-VAR is a quoted hook.
TRIGGER-HOOK is a list of quoted hooks and/or sharp-quoted functions."
  ;; 遍历传入的触发 Hook 列表
  (dolist (hook trigger-hooks)
    (let ((fn (make-symbol (format "chain-%s-to-%s-h" hook-var hook)))
          running?)
      ;; 动态生成闭包函数：在满足条件时运行目标 Hook，运行后清空自身以保证只运行一次
      (fset
       fn (lambda (&rest _)
            ;; Only trigger this after Emacs has initialized.
            (when (and (not running?)
                       after-init-time
                       (or (daemonp)
                           ;; In some cases, hooks may be lexically unset to
                           ;; inhibit them during expensive batch operations on
                           ;; buffers (such as when processing buffers
                           ;; internally). In that case assume this hook was
                           ;; invoked non-interactively.
                           (and (boundp hook)
                                (symbol-value hook)))
                       (or (null predicate)
                           (funcall predicate)))
              (setq running? t)  ; prevent infinite recursion
              (run-hooks hook-var)
              (set hook-var nil))))
      ;; 若在 Daemon 模式下，直接在新建 Client Frame 时触发
      (when (daemonp)
        ;; In a daemon session we don't need all these lazy loading shenanigans.
        ;; Just load everything immediately.
        (add-hook 'server-after-make-frame-hook fn 'append))
      ;; 对 find-file-hook 特殊处理（通过 advice 挂载到 after-find-file 之前），其余挂载到常规 hook
      (if (eq hook 'find-file-hook)
          ;; Advise `after-find-file' instead of using `find-file-hook' because
          ;; the latter is triggered too late (after the file has opened and
          ;; modes are all set up).
          (advice-add 'after-find-file :before fn '((depth . -101)))
        (add-hook hook fn -101))
      fn)))

;; 检测当前缓冲区变化，并运行本配置定义的“切换缓冲区”hook。
(defun nn-run-switch-buffer-hooks-h (&optional _)
  "Trigger `doom-switch-buffer-hook' when selecting a new buffer."
  (let ((gc-cons-threshold most-positive-fixnum))
    (run-hooks 'doom-switch-buffer-hook)))

;; 检测选中窗口变化，并运行本配置定义的“切换窗口”hook。
(defun nn-run-switch-window-hooks-h (&optional _)
  "Trigger `doom-switch-window-hook' when selecting a window in the same frame."
  (unless (or (minibufferp)
              (not (equal (old-selected-frame) (selected-frame)))
              (equal (old-selected-window) (minibuffer-window)))
    (let ((gc-cons-threshold most-positive-fixnum))
      (run-hooks 'doom-switch-window-hook))))

;; 判断当前图形环境是否支持并适合显示 child frame/posframe。
(defun nn-childframe-workable-p ()
  (and (not noninteractive)
       (not emacs-basic-display)
       (or (display-graphic-p)
           (featurep 'tty-child-frames))
       (eq (frame-parameter (selected-frame) 'minibuffer) 't)))

;; 根据鼠标 EVENT 拖动无标题栏的 Emacs frame。
(defun nn-drag-frame (event)
  (interactive "e")
  (let* ((frame (window-frame (posn-window (event-start event))))
         (start (mouse-absolute-pixel-position))
         (pos (frame-position frame)))
    (track-mouse
      (while (eq (car-safe (setq event (read-event))) 'mouse-movement)
        (let ((cur (mouse-absolute-pixel-position)))
          (set-frame-position
           frame
           (+ (car pos) (car cur) (- (car start)))
           (+ (cdr pos) (cdr cur) (- (cdr start)))))))))

;; 把预设代理地址写入 Emacs URL/网络变量，令后续网络请求通过代理。
(defun nn-proxy-enable ()
  "Enable proxy for all network connections in Emacs."
  (interactive)
  (setq-local url-proxy-services
              '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
                ("http" . (format "localhost:%d" nn-proxy-port))
                ("https" .(format "localhost:%d" nn-proxy-port))))
  (message "Proxy enabled"))

;; 清除本配置设置的代理变量，使后续网络请求恢复直连。
(defun nn-proxy-disable ()
  "Disable proxy in Emacs."
  (interactive)
  (setq url-proxy-services nil)
  (setq socks-server nil)
  (message "Proxy disabled"))

;; 设置延迟加载机制：将打开文件事件绑定到 nn-first-file-hook 派发器
(nn-run-hook-on 'nn-first-file-hook '(find-file-hook dired-initial-position-hook))
;; 设置延迟加载机制：将首次输入按键事件绑定到 nn-first-input-hook 派发器
(nn-run-hook-on 'nn-first-input-hook '(pre-command-hook))
;; 注册窗口选中变化时的 Hook 回调
(add-hook 'window-selection-change-functions #'nn-run-switch-window-hooks-h)
;; 注册窗口 Buffer 变更时的 Hook 回调
(add-hook 'window-buffer-change-functions #'nn-run-switch-buffer-hooks-h)
;; `window-buffer-change-functions' doesn't trigger for files visited via the server.
;; 注册使用 emacsclient 打开文件时的 Buffer 变更 Hook 回调
(add-hook 'server-switch-hook #'nn-run-switch-buffer-hooks-h)

(provide 'init-def)
