;;; -*- lexical-binding: t -*-

;;; 中文导读：early-init.el 在包系统和图形界面初始化前执行，适合放启动性能、
;;; 原生编译、包目录、初始 frame 与界面闪烁相关的设置。本文件还初始化
;;; use-package：`:ensure nil' 表示使用 Emacs 内置包，不从网络安装；`:defer t'
;;; 表示延迟加载，减少启动时间。这里的设置会先于主 init.el 生效。

;;; 作用：在 Emacs 启动的最早期阶段加载（早于图形界面初始化和包管理器初始化）。
;;; 从 Emacs 27 开始引入。
;;; 主要用途：
;;; 调整图形界面：在窗口创建前关闭不需要的 UI 元素（如工具栏、菜单栏、滚动条），避免启动时界面闪烁。
;;; 优化启动性能：修改底层垃圾回收阈值（gc-cons-threshold），或者配置包管理器行为（如设置 package-enable-at-startup nil 来推迟或禁用自动包初始化）。
;;; 原生编译配置：配置 Emacs 的本机代码编译参数（Native Compilation）。

;; Emacs 31 adds `user-lisp-directory' and automatically makes its
;; subdirectories available to `require'.  Emacs 30 does not, so provide the
;; same load-path setup explicitly to keep this configuration portable.
(unless (boundp 'user-lisp-directory)
  (defvar user-lisp-directory
    (expand-file-name "user-lisp/" user-emacs-directory)))
(add-to-list 'load-path user-lisp-directory)
(let ((default-directory user-lisp-directory))
  (normal-top-level-add-subdirs-to-load-path))

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
        frame-title-format
        '(:eval (concat
                 (if (and buffer-file-name (buffer-modified-p)) "● " "")
                 (buffer-name))))

  ;; 保存文件名 handler 和加载后缀，启动期只查 .elc/.el；启动完成后恢复原值（大幅缩减 startup 时间）
  (let ((default-file-name-handler-alist file-name-handler-alist)
        (default-load-file-rep-suffixes load-file-rep-suffixes))
    (setq file-name-handler-alist nil
          load-suffixes '(".elc" ".el")
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
  (use-short-answers t)
  (use-dialog-box nil)
  (use-file-dialog nil)
  ;; 跳过启动页和欢迎消息，不压缩字体缓存以换取显示性能
  (inhibit-startup-screen t)
  (inhibit-startup-echo-area-message user-login-name)
  (inhibit-compacting-font-caches t)
  ;; Frame 可按像素而不是字符格调整尺寸，并避免字体变化触发隐式 resize
  (frame-resize-pixelwise t)
  (frame-inhibit-implied-resize t)
  ;; 新 Frame 隐藏菜单/工具/滚动条并默认最大化
  (default-frame-alist
    '((menu-bar-lines . 0)
      (tool-bar-lines . 0)
      (horizontal-scroll-bars)
      (vertical-scroll-bars)
      (fullscreen . maximized))))

;; 内置包管理器 package.el 配置
(use-package package
  :ensure nil
  :custom
  ;; 使用预生成 quickstart 文件加快包加载，并允许启动时初始化已安装包
  (package-quickstart t)
  (package-quickstart-file (expand-file-name "package-quickstart.el" package-user-dir))
  (package-enable-at-startup t)
  ;; 不用 ELPA 版本覆盖内置包；关闭签名校验，并使用清华镜像源
  (package-install-upgrade-built-in nil)
  (package-check-signature nil)
  (package-archives
   '(("melpa-cn" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
     ("gnu-cn"   . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/"))))

;; 声明式宏 package: use-package 的全局默认选项
(use-package use-package
  :ensure nil
  :custom
  ;; use-package 声明默认安装缺失包、默认延迟加载，并生成较精简的展开代码
  (use-package-always-ensure t)
  (use-package-always-defer t)
  (use-package-expand-minimally t))

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
