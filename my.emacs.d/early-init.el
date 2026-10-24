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
;; Transient 的历史和参数属于运行时状态；先设置路径，包加载时会保留它们。
(let ((transient-directory (my/runtime-file "transient/")))
  (make-directory transient-directory t)
  (setq transient-values-file (expand-file-name "values.el" transient-directory)
        transient-history-file (expand-file-name "history.el" transient-directory)))
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

;; ---------------------------------------------------------------------------
;; user-lisp 字节码缓存
;; ---------------------------------------------------------------------------
(require 'cl-lib)

(defconst my/user-lisp-bytecode-directory
  (file-name-as-directory (my/runtime-file "user-lisp/"))
  "Mirror directory containing compiled user-lisp bytecode.")

(defvar my/user-lisp-source-load-count 0
  "Number of user-lisp source files loaded during this Emacs session.")
(defvar my/user-lisp-bytecode-load-count 0
  "Number of cached user-lisp bytecode files loaded during this session.")
(defvar my/user-lisp-compile-count 0
  "Number of user-lisp files compiled during this Emacs session.")

(defun my/user-lisp--source-directories ()
  "Return directories below `user-lisp-directory' that contain Elisp files."
  (when (file-directory-p user-lisp-directory)
    (delete-dups
     (cons (file-name-as-directory user-lisp-directory)
           (mapcar #'file-name-directory
                   (directory-files-recursively
                    user-lisp-directory "\\.el\\'" nil t))))))

(defvar my/user-lisp-source-directories
  (my/user-lisp--source-directories)
  "Directories searched for user-lisp source features.")

(defun my/user-lisp-compiled-file (source)
  "Return the mirrored runtime .elc path for user-lisp SOURCE."
  (unless (file-in-directory-p source user-lisp-directory)
    (error "user-lisp 源文件不在配置目录中：%s" source))
  (expand-file-name
   (concat (file-name-sans-extension
            (file-relative-name source user-lisp-directory))
           ".elc")
   my/user-lisp-bytecode-directory))

(defun my/user-lisp-source-file (feature)
  "Return FEATURE's .el source file below `user-lisp-directory'."
  (catch 'found
    (dolist (directory my/user-lisp-source-directories)
      (let ((file (expand-file-name
                   (concat (symbol-name feature) ".el") directory)))
        (when (file-readable-p file)
          (throw 'found file))))))

(defun my/user-lisp-refresh-bytecode-load-path ()
  "Create and register runtime directories mirroring user-lisp sources."
  (dolist (source-directory my/user-lisp-source-directories)
    (let* ((relative (file-relative-name source-directory user-lisp-directory))
           (runtime-directory
            (file-name-as-directory
             (expand-file-name relative my/user-lisp-bytecode-directory))))
      (make-directory runtime-directory t)
      ;; Runtime directories stay ahead of source directories for ordinary
      ;; `require' calls; the managed loader below still chooses exact files.
      (add-to-list 'load-path runtime-directory))))

(my/user-lisp-refresh-bytecode-load-path)

;; 中文说明：工作台、Pinky、Smerge、rg 等模块的字节码均按 Straight 构建的
;; Transient 编译。只把 Transient 及其最小运行依赖预先加入 load-path，不提前
;; require；这样各配置模块首次加载时不会误用 Emacs 内置的旧 Transient，避免
;; 两套内部对象协议混用导致菜单初始化失败。
(dolist (package '(compat cond-let llama transient))
  (let ((directory (my/runtime-file (format "straight/build/%s/" package))))
    (when (file-directory-p directory)
      (add-to-list 'load-path directory))))

(defun my/straight-build-load-paths ()
  "Return load paths for every package already built by Straight.

This is deliberately used by the managed byte compiler rather than globally:
configuration that references a third-party macro in a deferred `use-package'
form must still be macro-expanded while compiling, but normal runtime loading
should continue to be controlled by Straight and `use-package'."
  (let ((build-directory (my/runtime-file "straight/build/")))
    (when (file-directory-p build-directory)
      (mapcar #'file-name-as-directory
              (seq-filter #'file-directory-p
                          (directory-files build-directory t
                                           directory-files-no-dot-files-regexp))))))

(defun my/byte-compile-user-lisp-file (source)
  "Atomically compile user-lisp SOURCE into its mirrored runtime directory."
  (require 'bytecomp)
  (let* ((destination (my/user-lisp-compiled-file source))
         (destination-directory (file-name-directory destination))
         temporary)
    (make-directory destination-directory t)
    (unwind-protect
        (condition-case err
            (progn
              (setq temporary
                    (make-temp-file
                     (expand-file-name ".byte-compile-" destination-directory)
                     nil ".elc"))
              (let ((byte-compile-dest-file-function
                     (lambda (_source) temporary))
                    ;; Packages may be deferred at runtime, while their macros
                    ;; still need to be present at compile time.  Register all
                    ;; installed build directories so this stays true for new
                    ;; plugins without per-module path patches.
                    (load-path (append (my/straight-build-load-paths) load-path)))
                (unless (eq (byte-compile-file source) t)
                  (error "字节编译未生成可用产物")))
              (rename-file temporary destination t)
              (setq temporary nil)
              (cl-incf my/user-lisp-compile-count)
              destination)
          (error
           (display-warning
            'user-lisp-bytecode
            (format "%s 编译失败，下次仍会加载源文件：%s"
                    source (error-message-string err))
            :warning)
           nil))
      (when (and temporary (file-exists-p temporary))
        (delete-file temporary)))))

(defun my/byte-compile-stale-user-lisp-files ()
  "Compile every missing or stale user-lisp source into the runtime mirror.
This function does not load inactive modules, so backup configurations such as
Ivy or Dirvish remain disabled until explicitly added to `my/init-modules'."
  (interactive)
  (dolist (source (directory-files-recursively
                   user-lisp-directory "\\.el\\'" nil t))
    (let ((compiled (my/user-lisp-compiled-file source)))
      (when (or (not (file-readable-p compiled))
                (file-newer-than-file-p source compiled))
        (my/byte-compile-user-lisp-file source)))))

(defun my/user-lisp--load-source-fallback (feature source)
  "Load FEATURE from SOURCE only when no usable compiled artifact exists.

正常路径始终加载镜像 `.elc'。此回退仅用于首次安装第三方依赖导致编译
失败、或新生成的字节码损坏的恢复场景；源码加载后下一次启动会再次尝试编译。"
  (load source nil 'nomessage t)
  (unless (featurep feature)
    (error "%s 未提供 feature %s" source feature))
  (cl-incf my/user-lisp-source-load-count)
  feature)

(defun my/user-lisp--compile-and-load (feature source)
  "Compile SOURCE first, then load its newest mirrored `.elc' for FEATURE.

该函数覆盖 `user-lisp/' 与其 `lang/' 等所有递归子目录。首次安装依赖时
编译可能暂时失败，此时才加载源码，使其安装依赖后留待下次启动重新编译。"
  (let ((compiled (my/byte-compile-user-lisp-file source)))
    (if (not compiled)
        (my/user-lisp--load-source-fallback feature source)
      (condition-case err
          (progn
            (load compiled nil 'nomessage t)
            (unless (featurep feature)
              (error "%s 未提供 feature %s" compiled feature))
            (cl-incf my/user-lisp-bytecode-load-count)
            feature)
        (error
         (display-warning
          'user-lisp-bytecode
          (format "%s 加载失败，回退到源文件：%s"
                  compiled (error-message-string err))
          :warning)
         (my/user-lisp--load-source-fallback feature source))))))

(defun my/require-user-lisp-feature (feature)
  "Load FEATURE from current source or its mirrored runtime bytecode.
When source is newer or bytecode is missing, compile source first and load the
new `.elc'.  Source loading is reserved for recovery when compilation cannot
complete (normally the first startup of a new third-party dependency)."
  (let* ((source (my/user-lisp-source-file feature))
         (compiled (and source (my/user-lisp-compiled-file source))))
    (unless source
      (error "user-lisp 中找不到 feature %s 的源文件" feature))
    (if (and (file-readable-p compiled)
             (not (file-newer-than-file-p source compiled)))
        (condition-case err
            (progn
              (unless (featurep feature)
                (load compiled nil 'nomessage t)
                (cl-incf my/user-lisp-bytecode-load-count))
              (unless (featurep feature)
                (error "%s 未提供 feature %s" compiled feature))
              feature)
          (error
           (display-warning
            'user-lisp-bytecode
            (format "%s 加载失败，回退到源文件：%s"
                    compiled (error-message-string err))
            :warning)
           (my/user-lisp--compile-and-load feature source)))
      (my/user-lisp--compile-and-load feature source))))


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
  
  ;; 顶层默认启用词法绑定；空闲较久时再回收，避免短暂停顿期间频繁 Full GC。
  (set-default-toplevel-value 'lexical-binding t)
  (defvar my/gc-idle-timer nil
    "空闲垃圾回收定时器；保存对象以避免重复加载配置时叠加定时器。")
  (when (timerp my/gc-idle-timer)
    (cancel-timer my/gc-idle-timer))
  (setq my/gc-idle-timer (run-with-idle-timer 30 t #'garbage-collect))

  ;; 启动结束后统一恢复日常编辑参数。128MB 配合较高的增长比例可减少
  ;; Consult、Vertico 与 LSP 高频分配时的 GC 停顿；空闲定时器仍会回收内存。
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq gc-cons-threshold (* 128 1024 1024)
                    gc-cons-percentage 0.2))
            100)

  ;; 关闭 JIT/延迟原生编译，避免使用配置时后台编译带来的 CPU 和磁盘抖动
  (setq native-comp-jit-compilation nil
        native-comp-deferred-compilation nil
        ;; 重定义内置函数（例如将 yes-or-no-p 映射为 y-or-n-p）会触发
        ;; trampoline 原生编译；本机 GUI Emacs 的编译器不可用，故关闭它。
        comp-enable-subr-trampolines nil
        ;; 输入繁忙时可暂缓语法着色；缓存 load-path 目录扫描结果
        redisplay-skip-fontification-on-input t
        load-path-filter-function #'load-path-filter-cache-directory-files



        menu-bar-mode -1
        tool-bar-mode -1
        scroll-bar-mode -1
        ;; 标题栏显示缓冲区名；文件有未保存修改时在前面显示实心圆点
        ;; frame-title-format
        ;; '(:eval (concat
        ;;         (if (and buffer-file-name (buffer-modified-p)) "● " "")
        ;;         (buffer-name)))
    )

;;====================* 调试信息 *=====================================
;;  正常情况，把这 2 行打开
;; 启动过程中暂停 echo 消息与屏幕刷新，窗口完成后由 hook 恢复
(when nil
(setq 
      inhibit-redisplay t
        inhibit-message t
))
;; 当启动出错的时候，需要打开以下的两行设置
;;  启动的时候需要显示完整的信息
;;  出错的时候，把上面 when 中的 t 改为 nil，下面 when 中的 nil 改为 t 即可
(when t
(unless init-file-debug
  (setq inhibit-message t
        inhibit-redisplay t))
;;  包括使用包的时候，也需要显示完整的信息
(when init-file-debug
  (setq debug-on-error t
        use-package-verbose t
        use-package-expand-minimally nil
        use-package-compute-statistics t))
)
;;=====================* end *======================================


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
  (gc-cons-percentage 0.1)
  (gc-cons-threshold (if noninteractive #x8000000 most-positive-fixnum))
  ;; user-lisp 由受管加载器在源码更新时重编译；第三方包由 straight 构建。
  ;; 优先使用字节码，避免每次 require 额外比较源码时间戳。
  (load-prefer-newer nil)
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


;; 在 early-init 中提前禁用 package.el 自动启动
(setq package-enable-at-startup nil)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本文件由 Emacs 在 init.el 之前自动加载，用于压低启动阶段的 UI 与 GC 开销。
;; - 缓存、历史和原生编译文件统一写入 ~/.emacs.d/.local/，不要手工提交该目录。
;; - GUI 菜单栏、工具栏和滚动条在这里提前关闭；帧外观需改本文件的 frame 参数。
;; - 包系统启动被延后到 init.el；这里不适合放依赖第三方包的日常配置。
;; - 本文件没有快捷键；修改后应完整重启 Emacs 验证启动阶段行为。
