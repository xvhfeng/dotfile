;;; -*- lexical-binding: t -*-
;;; 这个文件在 Emacs 启动时最先加载，甚至在 init.el 之前。它主要用于设置一些关键的启动参数和优化启动性能。
;;; xvhfeng@2026-0925 


;; 1. 设置默认字体与字号
;; 说明："JetBrains Mono" 替换为你系统里已安装的字体名称
;;      :height 140 表示 14 pt (单位是 1/10 pt，120 = 12pt, 140 = 14pt, 160 = 16pt)
(add-to-list 'default-frame-alist
             '(font . "JetBrainsMonoNL Nerd Font-14"))

;; 初始 GUI Frame 与后续由 emacsclient 等方式创建的 Frame 都默认最大化。
;; 逐项加入而不是整体覆盖，避免丢失字体或其他已有的 Frame 参数。
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(dolist (parameter '((fullscreen . maximized)
                     (menu-bar-lines . 0)
                     (tool-bar-lines . 0)
                     (horizontal-scroll-bars . nil)
                     (vertical-scroll-bars . nil)
                     (border-width . 0)))
  (add-to-list 'default-frame-alist parameter))

;; 2. 如果需要针对中英文字体分别设置（实现中英文等高/对齐），可以使用 set-face-attribute
;; 注意：如果仅使用 set-face-attribute，请用 set-fontset-font 设置中文字体
(set-face-attribute 'default nil
                    :font "JetBrainsMonoNL Nerd Font"
                    :height 140
                    :weight 'normal)



(setq frame-title-format
      `((buffer-file-name "%f" "%b")
        ,(format " - GNU Emacs %s" emacs-version))) ;; 自定义标题栏内容

;; 设置emacs运行时创建的文件全部保存到～/.emacs.d/runtimes文件夹
(defconst my/runtime-directory
  (file-name-as-directory
   (expand-file-name "runtimes/" user-emacs-directory))
  "Directory used for Emacs-generated state.")

(defun my/runtime-file (name)
  "Return the absolute runtime path for NAME."
  (expand-file-name name my/runtime-directory))

(make-directory my/runtime-directory t)
;; `native-comp-eln-load-path' only exists in Emacs builds with native
;; compilation support.  Some official/portable builds omit native-comp even
;; on recent Emacs versions, so checking `emacs-version' is not sufficient.
(when (boundp 'native-comp-eln-load-path)
  (let ((eln-directory (file-name-as-directory
                        (my/runtime-file "eln-cache/"))))
    (make-directory eln-directory t)
    (setq native-comp-eln-load-path
          (cons eln-directory
                (delete (expand-file-name "eln-cache/" user-emacs-directory)
                        native-comp-eln-load-path)))))


;;; Emacs 31 引入内置的变量 user-lisp-directory（默认指向 ~/.emacs.d/user-lisp/），用来统一存放用户自定义的 .el 插件或代码。
;;; Emacs 30 及更早的版本并没有这个变量。所以手动将目录添加到 Emacs 的 load-path（加载路径）中。
;;; 目的是向上兼容旧版本 Emacs，确保你的配置在不同版本的 Emacs 上都能无缝运行（即跨版本兼容性/Portability）。
(unless (boundp 'user-lisp-directory)
  (defvar user-lisp-directory
    (expand-file-name "user-lisp/" user-emacs-directory)))
(when (file-directory-p user-lisp-directory)
  (add-to-list 'load-path user-lisp-directory)
  (let ((default-directory user-lisp-directory))
    (normal-top-level-add-subdirs-to-load-path)))


;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=81506
;; (setq w32-ime-preedit t)

;; 配置 Emacs 核心内置变量与启动行为
(use-package emacs
  :ensure nil
  ;; 首个窗口完成布局后重新允许显示和消息，结束启动期的“静默绘制”
  :hook (window-setup . (lambda () (setq inhibit-redisplay nil inhibit-message nil)))
  :init
  ;; 清除 Emacs 对旧 if-let/when-let 形式的字节编译弃用提示（消除 Warning）
  (put 'if-let 'byte-obsolete-info nil)
  (put 'when-let 'byte-obsolete-info nil)
  
  ;; 顶层默认启用词法绑定；空闲时每 5 秒主动执行一次垃圾回收
  (set-default-toplevel-value 'lexical-binding t)
  (run-with-idle-timer 5 t #'garbage-collect)

  ;; 关闭 JIT/延迟原生编译，避免使用配置时后台编译带来的 CPU 和磁盘抖动
  (setq native-comp-jit-compilation nil
        native-comp-deferred-compilation nil
        ;; 每次最多读取 64 KiB 子进程输出，并关闭自适应缓冲（提升 LSP/子进程吞吐）
        read-process-output-max (* 64 1024)
        process-adaptive-read-buffering nil
        ;; 输入繁忙时可暂缓语法着色；缓存 load-path 目录扫描结果
        redisplay-skip-fontification-on-input t
        load-path-filter-function #'load-path-filter-cache-directory-files
        ;; 启动过程中暂停 echo 消息与屏幕刷新，窗口完成后由 hook 恢复
        inhibit-message t
        inhibit-redisplay t
        menu-bar-mode -1
        tool-bar-mode -1
        scroll-bar-mode -1
        ;; 标题栏显示缓冲区名；文件有未保存修改时在前面显示实心圆点
        ;; frame-title-format
        ;; '(:eval (concat
        ;;         (if (and buffer-file-name (buffer-modified-p)) "● " "")
        ;;         (buffer-name)))
    )

  ;; 保存文件名 handler 和加载后缀；启动期只查 Elisp 与当前平台的原生模块。
  ;; 启动完成后恢复原值，以缩减目录扫描开销且不阻断 vterm 等模块。
  (let ((default-file-name-handler-alist file-name-handler-alist)
        (default-load-file-rep-suffixes load-file-rep-suffixes))
    (setq file-name-handler-alist nil
          load-suffixes (append '(".elc" ".el")
                                (when module-file-suffix
                                  (list module-file-suffix)))
          load-file-rep-suffixes '(""))
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq file-name-handler-alist default-file-name-handler-alist
                      load-file-rep-suffixes default-load-file-rep-suffixes))
              101))

  ;; Windows 下减少昂贵的真实文件属性查询，并缩短管道读延迟、扩大缓冲区
  (when (boundp 'w32-get-true-file-attributes)
    (setq w32-get-true-file-attributes nil
          w32-pipe-read-delay 0
          w32-pipe-buffer-size (* 64 1024)))
  :custom
  ;; 不自动扫描 user-lisp；启动期把 GC 阈值提到极大，降低加载时暂停次数
  (user-lisp-auto-scrape nil)
  (gc-cons-percentage (if noninteractive #x8000000 most-positive-fixnum))
  (gc-cons-threshold (if noninteractive #x8000000 most-positive-fixnum))
  ;; 源文件比字节码新时优先载入源文件，避免运行陈旧 .elc
  (load-prefer-newer t)
  (idle-update-delay 1.0)
  ;; 只向外部系统导出真正激活的选区；滚动时采用快速但略低精度的重绘
  (select-active-regions 'only)
  (fast-but-imprecise-scrolling t)
  ;; 完全关闭响铃，确认问题使用 y/n 短回答，并禁用图形对话框/文件选择器
  (ring-bell-function #'ignore)
  (use-short-answers t) ; 指示 Emacs 在 Minibuffer 提示需要 "yes or no" 回答时，
                        ; 接受简短的回答，例如 y 或 n。 否则可能需要输入完整的 "yes" 或 "no"。
  (use-dialog-box nil)  ; 指示 Emacs 在需要用户交互（如通过鼠标操作）时，是否应该使用图形界面的对话框。 
                        ; 虽然注释提到这主要用于鼠标事件，但设置为 t 会启用图形对话框。
  (use-file-dialog t) ; 禁用图形界面的文件选择对话框。 
                        ; 当执行如 C-x C-f（find-file）这样的文件操作时，Emacs 将在 Minibuffer

  ;; 跳过启动页和欢迎消息，不压缩字体缓存以换取显示性能
  (inhibit-splash-screen t ) ;; 禁用 Emacs 启动时的欢迎（Splash）屏幕。 启动时会直接进入默认的初始缓冲区。
  (inhibit-startup-screen t) ;;禁用 Emacs 启动时的启动（Startup）屏幕（通常显示版本信息和帮助提示）。 
  (inhibit-startup-echo-area-message user-login-name) ;;控制启动时 Echo Area（Emacs 窗口底部的消息区域）显示的消息。 
                                                ; 将其设置为 user-login-name（即当前用户的登录名）会禁止显示标准的启动
                                          ; 信息（如 "For more information..."）。
  (inhibit-compacting-font-caches t)
  ( inhibit-x-resources t )              ; 禁用从 X 资源（X resources）文件中读取配置设置。 这确保 Emacs 只使用其
                                          ; 自身的配置文件（如 init.el），避免与系统或用户环境中的 X 配置冲突或被其覆盖。
      
 (inhibit-startup-buffer-menu t)      ; 禁止在启动时自动显示 *Buffer List* 缓冲区菜单。 Emacs 启动后会直接
                                          ; 显示初始缓冲区，而不是缓冲区列表。

  ;; Frame 可按像素而不是字符格调整尺寸，并避免字体变化触发隐式 resize
  (frame-resize-pixelwise t)
  (frame-inhibit-implied-resize t)) ;; 'force  强制阻止 Emacs 在某些操作下（如隐藏或显示窗口的菜单栏、工具栏等）自动调整窗口大小。
                                    ;; force 是一个比较强的设置，确保窗口大小保持不变。


;; 系统环境变量与子进程环境配置
(use-package env
  :ensure nil
  :init
  ;; 告诉终端程序支持 256 色
  (setenv "TERM" "xterm-256color")
  ;; Windows 下禁止 Git 在不可见终端中等待输入，并让输出直接写回 Emacs
  (when (eq system-type 'windows-nt)
    (setenv "GIT_TERMINAL_PROMPT" "0")
    (setenv "GIT_ASK_YESNO" "false")
    (setenv "GIT_PAGER" "cat")
    (setenv "GIT_ASKPASS" "git-gui--askpass")

    ;; 若 Windows 没有 HOME，则从 USERPROFILE 补齐，供 ~ 展开和 Unix 工具使用
    (unless (getenv-internal "HOME")
      (when-let* ((home (getenv "USERPROFILE")))
        (setenv "HOME" home)
        (setq abbreviated-home-dir nil)))

    ;; 找到 bash.exe 时将其设为默认 shell，并声明 MSYS2 UCRT64 环境
    (when-let* ((bash (executable-find "bash.exe")))
      (setq shell-file-name bash)
      (setenv "MSYSTEM" "UCRT64")
      (setenv "SHELL" bash))))


;; 设置字体
;; ;;(add-to-list 'default-frame-alist `(font . "Iosevka-20"))
;;(defun rc/get-default-font ()
;;  (cond
;;   ((eq system-type 'windows-nt) "Consolas-13")
;;   ((eq system-type 'gnu/linux) "Iosevka-20")))
;;
;;(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))


(setq gc-cons-threshold (* 50 1000 1000))

;; 在 early-init 中提前禁用 package.el 自动启动
(setq package-enable-at-startup nil)
