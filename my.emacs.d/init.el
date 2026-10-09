;;; -*- lexical-binding: t -*- ;; 开启词法作用域（Lexical Binding），提升执行效率并规范变量作用域
;;; ============================================================================ ;; 顶部分隔装饰线
;;; Emacs 核心主配置文件 (init.el) - 100% 完整无漏版 ;; 配置文件主标题
;;; ============================================================================ ;; 顶部分隔装饰线

;; 设置环境变量 (作用于 git, curl 等子进程,emacs启动进程不会代理)
(setenv "http_proxy" "http://127.0.0.1:1087")
(setenv "https_proxy" "http://127.0.0.1:1087")
(setenv "HTTP_PROXY" "http://127.0.0.1:1087")
(setenv "HTTPS_PROXY" "http://127.0.0.1:1087")

;; 设置 Emacs 内置 url 库 (作用于 package.el 或 eww 等)
(setq url-proxy-services
      '(("http" . "127.0.0.1:1087")
        ("https" . "127.0.0.1:1087")
        ("no_proxy" . "^\(localhost\|127\.0\.0\.1\)")))
;; 不让失效的本地代理影响 straight 和其他子进程。
;;(dolist (variable '("http_proxy" "https_proxy" "HTTP_PROXY" "HTTPS_PROXY"))
;;  (setenv variable nil))
;; (setq url-proxy-services nil)

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 1. 核心宏定义与基础辅助函数 ;; 核心宏定义模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(defmacro csetq (&rest syms) ;; 定义 csetq 宏，用于替代 setq 从而正确触发带有 :set 属性的 Customize 变量
  "针对带 :set 属性的变量使用 `customize-set-variable' 进行设置，行为类似 `setq'。" ;; 宏文档字符串
  (let (exprs) ;; 声明局部变量 exprs 用于存储生成的代码表达式列表
    (while syms ;; 循环遍历传入的变量名和值对
      (let ((sym (pop syms)) ;; 弹出当前的变量名
            (val (pop syms))) ;; 弹出当前变量对应的赋值表达式
        (push `(customize-set-variable ',sym ,val) exprs))) ;; 构建 customize-set-variable 表达式并推入列表
    `(progn ,@(nreverse exprs)))) ;; 翻转表达式顺序并包裹在 progn 中返回

(defun ora-advice-add (sym where fn) ;; 定义通用 advice 辅助函数，防止重复添加同名 advice
  "安全的 advice-add 封装，避免对同名函数重复绑定 advice。" ;; 函数文档字符串
  (advice-remove sym fn) ;; 先尝试移除已经存在的 advice
  (advice-add sym where fn)) ;; 重新将 advice 绑定到指定的函数上


(eval-when-compile
  (require 'cl-lib))

  
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 2. 编码与区域语言设置 (UTF-8 全局化) ;; 编码模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(set-default-coding-systems 'utf-8-unix) ;; 设置默认文件和进程的文本读写编码为 UTF-8 且换行符为 Unix 格式
(prefer-coding-system 'utf-8) ;; 设置全局首选字符编码策略为 UTF-8
(set-charset-priority 'unicode) ;; 编码探测出现歧义或多种可能时，优先按 Unicode 解释

;; 设置环境变量以保证外部进程/UI语言一致 ;; 环境变量设置注释
(setenv "LC_ALL" "en_US.UTF-8") ;; 强制设置所有 Locale 环境变量为美式英语 UTF-8
(setenv "LANG" "en_US.UTF-8") ;; 设置语言环境变量为美式英语 UTF-8
(set-locale-environment "en_US.UTF-8") ;; 设置 C 语言库底层区域环境，统一日期、排序与外部进程语言

;; 针对 Windows / 其他系统的剪贴板与子进程编码兼容 ;; 剪贴板与操作系统兼容性注释
(if (eq system-type 'windows-nt) ;; 判断当前运行系统是否为 Windows
    (progn ;; 若为 Windows 系统，顺序执行以下组合语句
      (set-clipboard-coding-system 'utf-16-le) ;; Windows 剪贴板统一采用 UTF-16LE 编码交换数据
      (setq default-process-coding-system `(utf-8-dos . ,locale-coding-system) ;; 设置默认子进程输入输出编码格式
            process-coding-system-alist ;; 针对特定的 Windows 进程映射专用编码规则
            '(("[pP][lL][iI][nN][kK]" utf-8-dos . gbk-dos) ;; 为 plink 远程进程单独配置 GBK 编码兼容
              ("[cC][mM][dD][pP][rR][oO][xX][yY]" utf-8-dos . gbk-dos)))) ;; 为 cmdproxy 命令行代理配置 GBK 兼容
  (set-clipboard-coding-system 'utf-8-unix) ;; 非 Windows 系统下剪贴板使用 UTF-8-UNIX 编码
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))) ;; 非 Windows 系统下子进程全局使用 UTF-8-UNIX 编码

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 3. 翻页、平滑滚屏与视口控制 (关键遗漏完全补齐) ;; 翻页滚屏模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(setq scroll-step 1 ;; 键盘光标移动到屏幕边缘时，每次垂直滚动 1 行（避免剧烈跳页）
      scroll-conservatively 10000 ;; 光标超出屏幕视口时保持平滑滚屏（防止自动跳转到屏幕正中间）
      scroll-margin 5 ;; 触发视口滚屏的边缘行数保留值（设为 0 表示到达顶部或底部第一行才滚动） 不管怎么样滚屏，都保留最上或者最下有 5 行空间
      scroll-preserve-screen-position t ;; 使用 C-v / M-v 翻页时，尽量保持光标在屏幕上的相对行位置不变
      next-screen-context-lines 5 ;; 使用 PgUp / PgDn 翻页时，新屏幕保留旧屏幕顶部/底部的 2 行重叠内容作为阅读参照
      fast-read-minibuffer-input t) ;; 优化 Minibuffer 快速输入的渲染响应速度

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 4. 基于 csetq 与 setq 的编辑器行为与微调 ;; 编辑器行为模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 使用 csetq 设置那些修改后需要触发内置回调/生效函数的变量 ;; csetq 变量配置段
(csetq cursor-type 'box ;; 设置文本编辑光标形状为实心方框
       visible-bell nil ;; 彻底关闭屏幕视觉闪烁警告提示
       adaptive-fill-regexp "[ \t]+|[ \t]*([0-9]+.|*+)[ \t]*" ;; 自动填充段落时识别缩进、数字序号与项目符号
       adaptive-fill-first-line-regexp "^* *$" ;; 自动填充时对首行的正则匹配规则
       sentence-end-double-space nil ;; 句号后只需单个空格即视为句子结尾
       delete-pair-push-mark t ;; 删除配对符号（如括号、引号）时把当前位置压入 Mark Ring
       confirm-kill-emacs 'y-or-n-p ;; 按 C-x C-c 退出 Emacs 时使用简单的 y/n 进行二次二次确认，防止误触退出
       history-length 1000 ;; 将输入历史记录（如 M-x、查找历史等）的最大保留长度扩展到 1000 条
       save-interprogram-paste-before-kill t ;; 在用新文本覆盖剪贴板前，先把剪贴板现存内容压入 Emacs 的 Kill-ring 中
       kill-ring-max 200 ;; 扩展 Kill-ring 剪切板历史记录的最大保留数量至 200 项
       mark-ring-max 100 ;; 扩展单个 Buffer 内 Mark 位置历史纪录的最大数量至 100 项
       global-mark-ring-max 100) ;; 扩展跨 Buffer 全局 Mark 位置历史纪录的最大数量至 100 项

;; 基础变量设置 ;; setq 变量配置段
(setq visible-cursor nil ;; 禁用旧式 visible-cursor 可见光标特性
      ;; 禁用双向文本排版，大幅提升超长代码文件渲染速度 ;; 文本渲染性能注释
      bidi-inhibit-bpa t ;; 彻底禁用双向括号算法（BPA）以提升文本解析性能
      bidi-display-reordering 'left-to-right ;; 强制单向（从左到右）渲染文本显示
      bidi-paragraph-direction 'left-to-right ;; 强制段落文本基准方向为从左到右
      ;; 超长行截断保护 ;; 长行保护注释
      long-line-threshold 1000 ;; 行长度超过 1000 字符时触发长行保护优化机制
      large-hscroll-threshold 1000 ;; 横向滚动超过 1000 字符时开启加速优化
      ;; 扩大 Undo 撤销缓冲区上限 ;; Undo 缓冲区上限注释
      undo-limit (* 13 160000) ;; 将基础 Undo 撤销历史内存上限提升至约 2MB
      undo-strong-limit (* 13 240000) ;; 将强边界 Undo 撤销内存上限提升至约 3MB
      undo-outer-limit (* 13 24000000)) ;; 将最外层 Undo 撤销内存上限提升至约 300MB

;; Tab 缩进与折行策略 ;; 缩进与折行注释
(setq-default tab-width 2 ;; 设置所有 Buffer 默认的 Tab 制表符显示宽度为 2 列
              tab-always-indent 'complete ;; 按 TAB 键先尝试缩进，若已正确缩进则触发代码补全
              fill-column 80 ;; 文本自动折行/填充的参考列宽设置为 80 列
              truncate-lines t ;; 超过列宽的长行进行截断显示，而不是视觉自动折行
              truncate-partial-width-windows nil ;; 分屏窗口下保持一致的截断策略
              indent-tabs-mode nil ;; 全局禁用硬制表符（Tab），强制缩进全部转换为空格
              c-basic-offset 2 ;; C/C++ 模式下的基础代码缩进距离设置为 2 个空格
              c-default-style "linux") ;; C/C++ 模式的代码缩进风格采用 Linux 内核标准风格

;; 编辑器快捷行为与交互 ;; 交互行为注释
(setq enable-recursive-minibuffers t ;; 允许在 Minibuffer 输入过程中递归嵌套调出新的 Minibuffer
      minibuffer-message-timeout 1 ;; Minibuffer 底部临时消息停留时间设为 1 秒
      read-quoted-char-radix 16 ;; 输入转义字符（C-q）时默认使用 16 进制解析
      load-prefer-newer t ;; 载入 Elisp 库时优先加载最新的未编译源文件而非旧字节码
      ring-bell-function 'ignore ;; 彻底忽略并屏蔽系统声音/视觉响铃警告
      highlight-nonselected-windows nil ;; 禁用非当前选中窗口的高亮显示以提升性能
      kill-buffer-query-functions nil ;; 删除 Buffer 时不再弹出烦人的二次确认询问
      x-selection-timeout 100) ;; 设置与系统剪贴板通信的超时时长为 100 毫秒

(defalias 'yes-or-no-p 'y-or-n-p) ;; 将繁琐的 yes/no 对话框提示简化为单字母 y/n 快速响应
(minibuffer-depth-indicate-mode 1) ;; 在 Minibuffer 左侧显示当前嵌套的深度数字提示
(blink-cursor-mode -1) ;; 彻底关闭文本光标的闪烁效果，降低系统资源开销
(global-auto-revert-mode 1) ;; 开启全局文件自动刷新，磁盘文件变更时自动同步到 Buffer
(setq auto-revert-verbose nil) ;; 自动同步磁盘文件时关闭底部 Minibuffer 提示
(winner-mode 1) ;; 开启 winner-mode，允许使用快捷键撤销或恢复分屏窗口布局

;; 使用安全 advice 机制替换 set-window-dedicated-p，避免窗口被某些插件锁定 ;; Window dedicated 解决策略
(ora-advice-add 'set-window-dedicated-p :override #'ignore) ;; 忽略窗口锁定指令，保证窗口分屏的灵活操控

;; 性能参数：GC 阈值与进程单次读取流 ;; 内存与进程性能参数注释
(setq gc-cons-threshold (* 100 1024 1024) ;; 提高垃圾回收（GC）触发阈值到 100MB，减少日常编辑卡顿
      read-process-output-max (* 1024 1024) ;; 提升单次读取子进程输出的最大缓冲区至 1MB（LSP/AutoComplete 必备）
      process-adaptive-read-buffering nil ;; 禁用子进程自适应读取缓冲，提高数据传输实时性
      ad-redefinition-action 'accept ;; 忽略 Advice 重新定义时的警告提示
      native-comp-async-report-warnings-errors nil) ;; 静默并屏蔽原生编译（Native Comp）的异步警告弹窗

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 5. 文件处理、Dired、备份与文件系统 ;; 文件与备份配置模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 使用 csetq 设置那些会联动版本控制钩子的 VC 变量 ;; VC 变量配置段
(csetq vc-follow-symlinks t ;; 自动追溯软链接指向的真实文件，不再弹窗询问确认
       vc-find-revision-no-save t ;; 查找 Git 历史版本时不强制提示保存当前 Buffer
       vc-handled-backends '(Git)) ;; 版本控制后端仅保留 Git，禁用 SVN/Hg 等以大幅提升打开文件速度

;; 基础文件与 Dired 目录树设置 ;; Dired 与文件配置
(setq remote-file-name-inhibit-locks t ;; 禁用远程文件编辑锁定，加快远程操作响应
      find-file-suppress-same-file-warnings t ;; 打开相同文件时不弹出重复警告信息
      read-file-name-completion-ignore-case t ;; 在 Minibuffer 补全文件名时忽略大小写
      read-buffer-completion-ignore-case t ;; 在 Minibuffer 补全 Buffer 名时忽略大小写
      dired-recursive-deletes 'always ;; Dired 模式下删除非空目录时直接递归删除，不再频繁二次询问
      dired-recursive-copies 'always ;; Dired 模式下复制目录时直接递归复制
      dired-dwim-target t) ;; Dired 启用 DWIM（Do What I Mean）特性，双分屏时自动将对侧 Dired 目录作为默认目标路径

(defun my/vc-off-if-remote () ;; 定义函数：针对远程文件自动关闭 VC 版本控制检测
  "当当前文件处于远程 TRAMP 环境时禁用 VC 检查以提升响应速度。" ;; 函数文档说明字符串
  (when (file-remote-p (buffer-file-name)) ;; 判断当前 Buffer 中的文件是否为 TRAMP 远程文件
    (setq-local vc-handled-backends nil))) ;; 若为远程文件，则在当前 Buffer 本地禁用 VC 检查
(add-hook 'find-file-hook #'my/vc-off-if-remote) ;; 将上述函数挂载到打开文件的 Hook 列表中

;; 隔离备份文件与锁文件，避免污染项目目录 ;; 备份文件隔离设置注释
(csetq backup-by-copying t ;; 采用复制方式创建备份，防止破坏文件的原始硬链接与权限
       delete-old-versions t ;; 自动清理并删除超出数量制限的旧版本备份文件
       version-control t ;; 开启备份版本控制，为每次保存生成带编号的多个备份
       create-lockfiles nil) ;; 禁用 #.file# 锁定文件创建，防止干扰 Web 开发框架的热重载

(dolist (directory '("backups/" "auto-save/" "auto-save-list/"
                     "tramp/" "url/" "projects/"))
  (make-directory (my/runtime-file directory) t))

(setq backup-directory-alist
      (list (cons tramp-file-name-regexp (my/runtime-file "backups/"))
            (cons "." (my/runtime-file "backups/")))
      auto-save-file-name-transforms
      (list (list ".*" (my/runtime-file "auto-save/") t))
      auto-save-list-file-prefix
      (my/runtime-file "auto-save-list/.saves-")
      custom-file (my/runtime-file "custom.el")
      bookmark-default-file (my/runtime-file "bookmarks")
      project-list-file (my/runtime-file "projects/list.eld")
      tramp-persistency-file-name (my/runtime-file "tramp/persistency.el")
      url-configuration-directory (my/runtime-file "url/"))

;; 将 Customize 自动生成的配置隔离写入 custom.el ;; Custom 隔离文件注释
(when (file-exists-p custom-file) ;; 检查 custom.el 文件是否存在
  (load custom-file t)) ;; 若存在则加载该文件，且不输出加载错误提示

;; 解禁内置高级命令 ;; 命令解禁注释
(mapc (lambda (x) (put x 'disabled nil)) ;; 批量解除 Emacs 默认对高阶命令的禁用保护
      '(erase-buffer upcase-region downcase-region dired-find-alternate-file narrow-to-region set-goal-column)) ;; 解禁：清空Buffer、转大写、转小写、Dired替换打开、局部收缩编辑、固定列游标

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 6. 网络设置 ;; 网络模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 不在配置中写死代理地址。若需要代理，请在启动 Emacs 前通过系统环境或
;; `url-proxy-services' 显式设置，避免不存在的本地代理阻断首次启动。

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 7. straight.el + use-package 包管理器集成 ;; 包管理器集成模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(defmacro my/setup-straight-and-use-package-d ()
  "自动化初始化 straight.el 并将其作为全局包管理器。"
  `(progn
     (setq package-enable-at-startup nil)
     (setq straight-vc-git-default-clone-depth 1)
     (setq straight-check-for-modifications nil)

     (defvar bootstrap-version)
     (let ((bootstrap-file
            (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
           (bootstrap-version 6))
       (unless (file-exists-p bootstrap-file)
         (condition-case err
             (let ((buffer
                    (url-retrieve-synchronously
                     "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
                     'silent 'inhibit-cookies)))
               (unless buffer
                 (error "下载 straight.el 安装脚本时没有收到响应"))
               (unwind-protect
                   (with-current-buffer buffer
                     (goto-char (point-min))
                     (unless (re-search-forward "^$" nil t)
                       (error "straight.el 安装脚本响应格式无效"))
                     (eval-print-last-sexp))
                 (kill-buffer buffer)))
           (error
            (message "straight.el 未安装：%s；Emacs 将继续启动。" (error-message-string err)))))
       (when (file-exists-p bootstrap-file)
         (load bootstrap-file nil 'nomessage)
         (straight-use-package 'use-package)
         (setq straight-use-package-by-default t
               use-package-always-defer t
               use-package-expand-minimally t)))))

(defmacro my/setup-straight-and-use-package ()
  "自动化初始化 straight.el：若本地不存在则先自动用 git clone 拉取，再加载。"
  `(progn
     (setq package-enable-at-startup nil)
     (setq straight-vc-git-default-clone-depth 1)
     (setq straight-check-for-modifications nil)

     (defvar bootstrap-version)
     (let* ((straight-dir (expand-file-name "straight/repos/straight.el" user-emacs-directory))
            (bootstrap-file (expand-file-name "bootstrap.el" straight-dir))
            (bootstrap-version 6))
       
       ;; 1. 检查本地是否存在 straight.el 仓库目录，若不存在则自动通过外部 git 命令拉取
       (unless (file-exists-p bootstrap-file)
         (message "未找到 straight.el，准备自动通过 Git 进行克隆...")
         
         ;; 递归创建目标父目录 ~/.emacs.d/straight/repos/
         (make-directory (file-name-directory straight-dir) t)
         
         ;; 检查系统是否存在 git 可执行程序
         (if (executable-find "git")
             (let ((exit-code
                    ;; 执行 git clone 命令 (使用 depth=1 深度加速下载)
                    (call-process "git" nil "*straight-clone-log*" t
                                  "clone" "--depth" "1"
                                  "https://github.com/radian-software/straight.el.git"
                                  straight-dir)))
               (if (= exit-code 0)
                   (message "straight.el 自动克隆成功！")
                 (error "git clone straight.el 失败，退出码为 %d！请检查网络代理或查看 *straight-clone-log* 缓冲区。" exit-code)))
           (error "系统未检测到 git 命令，请先安装 Git！")))

       ;; 2. 确保 bootstrap.el 存在后正式加载
       (load bootstrap-file nil 'nomessage))

     ;; 3. 配置 use-package 默认使用 straight.el
     (straight-use-package 'use-package)
     (setq straight-use-package-by-default t)
     (setq use-package-always-defer t)
     (setq use-package-expand-minimally t)))

(my/setup-straight-and-use-package) ;; 调用并执行上面定义好的宏，完成全套包管理器的初始化配置


;;;; 后续配置需要插件
;;;; 下载普通 MELPA 插件（自动从 GitHub 克隆）
;;;; (use-package vertico)

;;;; 从 GitHub 克隆指定仓库
;;;; (use-package example-plugin
;;;; :straight (:host github :repo "username/example-plugin"))

;;;; 也可以指定特定分支或 Tag
;;;; (use-package dirvish
;;;; :straight (:host github :repo "alexluigit/dirvish" :branch "main"))

;;;; 甚至直接指定完整的 Git URL (如 Gitee 或自建 GitLab)
;;;;(use-package my-private-pkg
;;;; :straight (:type git :host nil :repo "https://gitee.com/user/my-private-pkg.git"))

;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 8. 常用现代化生态插件配置 ;; 现代化插件配置模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(require 'init-base) ;; 加载基础配置模块 init-base.el
(require 'init-keybindings) ;; 加载快捷键配置模块 init-keybindings.el
(require 'init-themes) ;; 加载主题配置模块 init-themes.el
(require 'init-minbuffer) ;; 加载 Minibuffer 配置模块 init-minbuffer.el
(require 'init-eshell) ;; 加载shell，让emacs和系统（mac/linux）具有同样的bash环境
(require 'init-ranger) ;; 加载ranger，目录选择器
(require 'init-consult) ;; 加载搜索等一系列的插件
(require 'init-rainbow) ;; 彩虹括号
(require 'init-edit) ;; 使用插件的编辑操作，黄金3插件



;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
;; 9. 启动时间统计与 GC 恢复Hook ;; 启动统计与收尾模块标题
;; ---------------------------------------------------------------------------- ;; 模块分隔装饰线
(require 'server) ;; 提供 server-running-p 和 server-start
(add-hook 'emacs-startup-hook ;; 将匿名函数挂载到 Emacs 启动完成的 Hook 中
          (lambda () ;; 定义匿名函数
            ;; 启动完成后恢复 GC 阈值为 16MB，兼顾性能与内存占用 ;; GC 阈值恢复注释
            (setq gc-cons-threshold (* 16 1024 1024)) ;; 将垃圾回收阈值回落恢复到 16MB 正常水平
            (message "Emacs 加载完成！总耗时: %.3f 秒，执行了 %d 次 GC。" ;; 底部 Minibuffer 打印启动时间与 GC 统计
                     (float-time (time-subtract after-init-time before-init-time)) ;; 计算绝对加载时间差（秒）
                     gcs-done))) ;; 输出从启动到目前为止总共触发 GC 的次数

(unless (server-running-p)
  (condition-case err
      (server-start)
    (file-error
     ;; 不能创建 server socket 不应阻断编辑器本身启动。
     (message "Emacs server 未启动：%s" (error-message-string err)))))
