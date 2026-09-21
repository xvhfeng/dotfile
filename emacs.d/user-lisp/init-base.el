;;; -*- lexical-binding: t -*-

;;; 中文导读：基础行为模块，仅配置 Emacs 自带功能。autorevert 自动刷新磁盘变更，
;;; recentf/savehist 保存最近文件与输入历史，project 管理项目，repeat 允许短键重复
;;; 命令，uniquify 消除同名缓冲区歧义，pixel-scroll/mwheel 改善滚动，comint 统一
;;; 交互式进程行为，files/window/frame/simple 则控制文件、窗口和通用编辑细节。
(use-package project
  :ensure nil
  :custom
  (project-list-file (concat nn-directory "project-list.el"))
  (project-vc-ignores
   '("node_modules" ".git" ".svn" "vendor" "dist" "build"
     ".cache" ".tox" "__pycache__" "target" "out"))
  (project-vc-include-untracked t)
  (project-vc-merge-submodules nil)
  (project-files-relative-names t)
  (project-search-function #'project-ripgrep))


(use-package simple
  :ensure nil ; simple 是 Emacs 核心内置包，无需从外部仓库（MELPA/ELPA）下载
  :custom
  ;; 【缩进设置】
  ;; 禁用 Tab 字符缩进。按 TAB 缩进时自动转为空格，避免不同编辑器下排版错乱
  (indent-tabs-mode nil)

  ;; 【UI与性能】
  ;; 空闲更新延迟（秒）。停止打字 0.5 秒后才触发后台 UI/状态刷新，提升连续打字流畅度
  (idle-update-delay 0.5)

  ;; 【Minibuffer 补全行为】
  ;; 按 TAB 补全时，若存在候选词则直接在输入框中依次循环替换，不弹静态菜单 (t 表示总是循环)
  (completion-cycle-threshold t)
  ;; 在 M-x 命令补全中，自动过滤掉当前 Mode 下不可用的命令（Emacs 28+ 特性）
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; 隐藏 *Completions* 补全窗口顶部的帮助提示说明文字（节省屏效空间）
  (completion-show-help nil)

  ;; 【文本编辑与剪切】
  ;; 当光标位于行首时，按 C-k 会直接剪切整行内容以及行尾的换行符（不留空行）
  (kill-whole-line t)
  ;; 剪贴环（kill-ring）去重，连续剪切完全相同的内容时不会重复占用历史记录
  (kill-do-not-save-duplicates t)
  ;; 未选中区域（Region）时按剪切键（如 C-w），智能剪切当前行或光标下的词 (DWIM)
  (kill-region-dwim t)
  ;; 垂直移动光标（C-n/C-p）时，保持光标贴在每行的最末尾（EOL）
  (track-eol t)

  ;; 【错误/检索跳转高亮】
  ;; 使用 next-error (如 M-g n) 跳转到下一个编译错误或 grep 结果时，保持高亮目标行
  (next-error-highlight t)
  ;; 在不切换焦点到目标窗口的情况下预览下一个错误，同样高亮目标行
  (next-error-highlight-no-select t))


;; =============================================================================
;; 1. files: 文件读写、备份、自动保存与文件系统行为
;; =============================================================================
(use-package files
  :ensure nil
  :custom
  ;; 禁用原生的 .~ 文件备份（通过后面配置集中存储或彻底关闭）
  (make-backup-files nil)
  ;; 将备份文件集中存放在配置目录的 backup/ 文件夹下
  (backup-directory-alist `(("." . ,(concat nn-directory "backup"))))
  ;; 禁用自动保存路径前缀文件
  (auto-save-list-file-prefix nil)
  ;; 配置自动保存文件的命名转换规则（特别是支持 TRAMP 远程文件并使用 sha1 哈希）
  (auto-save-file-name-transforms
   `(("\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
      ,(concat nn-directory "autosave/tramp-\\2-") sha1)
     ("\\`/\\([^/]/\\)*\\([^/]\\)\\'"
      ,(concat nn-directory "autosave/\\2-") sha1)))
  ;; 关闭默认的 `#file#` 自动保存机制
  (auto-save-default nil)
  ;; 匹配文件模式（auto-mode-alist）时区分大小写，提升匹配速度
  (auto-mode-case-fold nil)
  ;; 备份文件时自动删除旧版本
  (delete-old-versions t)
  ;; 删除文件时直接移入系统回收站（而不是彻底删除）
  (delete-by-moving-to-trash t)
  ;; 禁用 .# 锁文件（防止在多人/多客户端协作或版本控制目录下生成临时锁文件）
  (create-lockfiles nil)
  ;; 退出 Emacs 时若有后台进程，直接杀死而不弹窗提示确认
  (confirm-kill-processes nil)
  ;; 打开不存在的文件或缓冲区时不需要二次确认
  (confirm-nonexistent-file-or-buffer nil)
  ;; 保留的最新的备份文件数量
  (kept-new-versions 3)
  ;; 保留的最旧的备份文件数量
  (kept-old-versions 2)
  ;; 开启备份文件的版本控制（生成 .~1~, .~2~ 等）
  (version-control t)
  ;; 备份时采用复制方式，保持原文件的硬链接和符号链接属性不被破坏
  (backup-by-copying t)
  ;; 打开符号链接文件时，自动追踪并访问其真实的物理路径
  (find-file-visit-truename t)
  ;; 忽略“打开了同一个文件的不同链接”时的重复警告
  (find-file-suppress-same-file-warnings t)
  ;; 保存文件时，若末尾缺失换行符则自动补全换行符
  (require-final-newline t))


;; =============================================================================
;; 2. ls-lisp: Emacs 内部实现的目录列表工具（跨平台/Windows优化）
;; =============================================================================
(use-package ls-lisp
  :ensure nil
  :custom
  ;; 如果系统安装了原生的 ls 程序，则优先使用系统 ls
  (ls-lisp-use-insert-directory-program (when (executable-find "ls") t))
  ;; 模拟 UNIX 风格的 ls 输出格式
  (ls-lisp-emulation 'UNIX)
  ;; 禁用字符串排序的 locale 比较（使用纯字节排序），提升速度
  (ls-lisp-use-string-collate nil)
  ;; 使用本地化的时间格式显示文件时间
  (ls-lisp-use-localized-time-format t)
  ;; 开启对符号链接（Symlink）的支持显示
  (ls-lisp-support-symlinks t)
  ;; 排序时永远将文件夹（目录）排在文件前面
  (ls-lisp-dirs-first t)
  ;; 设置详细信息列表中显示的内容：符号链接、用户ID、权限模式
  (ls-lisp-verbosity '(links uid modes))
  :config
  ;; Windows 平台特供优化：修复 MSYS/Cygwin 下 ls 命令行输出字符集的编码乱码问题
  (when (and ls-lisp-use-insert-directory-program
             (eq system-type 'windows-nt))
    (define-advice insert-directory (:around (orig &rest args) my-w32-msys-ls)
      "Pass ANSI-codepage argv to `insert-directory-program', decode its UTF-8 output."
      (let ((coding-system-for-read 'utf-8))
        (apply orig args)))))


;; =============================================================================
;; 3. recentf: 最近打开文件历史记录
;; =============================================================================
(use-package recentf
  :ensure nil
  ;; 每次进入 Dired 目录模式时，把当前目录加入最近文件列表
  :hook (dired-mode . my-recentf-add-dired-directory-h)
  :custom
  ;; 指定最近文件历史记录的持久化保存路径
  (recentf-save-file (concat nn-directory "recentf.eld"))
  ;; 自动刷新的文件匹配项不进行询问
  (revert-without-query '("."))
  ;; 列表中最多保留 5 个最近打开项（注：此设置极小，一般推荐 50-200）
  (recentf-max-saved-items 5)
  ;; 启动时自动清理历史记录中已不存在的文件
  (recentf-auto-cleanup t)
  ;; 禁用定时器自动保存历史记录（仅在 Emacs 退出或手动时保存）
  (recentf-auto-save-timer nil)
  ;; 忽略/排除不需要记入历史的文件路径正规表达式（缓存、图片、临时文件等）
  (recentf-exclude
   '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
     "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
     "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
     "^/tmp/" "^/var/folders/.$" "^/ssh:" "/persp-confs/"
     (lambda (file) (file-in-directory-p file package-user-dir))))
  :config
  ;; 让 recentf 能够识别并保留 Dired 目录
  (add-to-list 'recentf-keep '(derived-mode-p . dired-mode))
  ;; 保存文件名时去除文本属性（Text Properties），防止历史文件受污染
  (add-to-list 'recentf-filename-handlers #'substring-no-properties)

  ;; 钩子函数：把 Dired 目录当作文件加入 recentf
  (defun my-recentf-add-dired-directory-h ()
    "Add dired directories to recentf file list."
    (recentf-add-file default-directory))

  ;; 钩子函数：当切换到某个已经打开的 Buffer 时，更新它在 recentf 中的最近访问顺序
  (defun my-recentf-touch-buffer-h ()
    "Bump file in recent file list when it is switched or written to."
    (when buffer-file-name
      (recentf-add-file buffer-file-name))
    nil))


;; =============================================================================
;; 4. autorevert: 自动刷新被外部修改的文件
;; =============================================================================
(use-package autorevert
  :ensure nil
  ;; 首次打开文件时，全局开启自动重载机制
  :hook (nn-first-file . global-auto-revert-mode)
  :custom
  ;; 文件被外部修改并在 Emacs 中自动重载时，在 Echo Area 提示信息
  (auto-revert-verbose t)
  ;; 优先使用文件系统通知（File Notifications, 如 inotify/fsevents）代替轮询
  (auto-revert-use-notify t)
  ;; 如果使用了文件通知机制，避免周期性轮询磁盘（节约 CPU 资源）
  (auto-revert-avoid-polling t)
  ;; 即使当前有用户输入，也不要挂起自动重载
  (auto-revert-stop-on-user-input nil))


;; =============================================================================
;; 5. comint: 交互式终端/Shell 缓冲区基础配置
;; =============================================================================
(use-package comint
  :ensure nil
  :commands comint-truncate-buffer
  :custom
  ;; 设置 Shell/Comint 缓冲区的最大行数/字符容量，超过后截断（防止长时间运行卡顿）
  (comint-buffer-maximum-size 2048)
  ;; 将 Shell 提示符（Prompt）设置为只读，防止误删提示符
  (comint-prompt-read-only t))


;; =============================================================================
;; 6. savehist: Minibuffer 历史记录与变量持久化保存
;; =============================================================================
(use-package savehist
  :ensure nil
  :hook
  ;; 首次在 Minibuffer 输入时激活 savehist-mode
  (nn-first-input . savehist-mode)
  ;; 保存前去除文本属性
  (savehist-save . my-savehist-unpropertize-variables-h)
  ;; 保存前清理无法序列化的寄存器项
  (savehist-save . my-savehist-remove-unprintable-registers-h)
  :custom
  ;; save-place（光标历史位置）的保存文件路径
  (save-place-file (concat nn-directory "saveplace.el"))
  ;; savehist（Minibuffer 历史记录）的保存文件路径
  (savehist-file (concat nn-directory "savehist.el"))
  ;; 禁用定时自动保存，仅在 Emacs 关闭时写入磁盘
  (savehist-autosave-interval nil)
  ;; 持久化保存 Minibuffer 的输入历史
  (savehist-save-minibuffer-history t)
  ;; 额外需要跨 Session 持久化保存的 Emacs 变量列表（剪贴环、寄存器、标记环、搜索历史等）
  (savehist-additional-variables
   '(kill-ring register-alist mark-ring global-mark-ring
     search-ring regexp-search-ring))
  :config
  ;; 函数：写盘前剥离 kill-ring 和 register-alist 中字符串的文本格式属性
  (defun my-savehist-unpropertize-variables-h ()
    (setq kill-ring
          (mapcar #'substring-no-properties
                  (cl-remove-if-not #'stringp kill-ring))
          register-alist
          (cl-loop for (reg . item) in register-alist
                   if (stringp item)
                   collect (cons reg (substring-no-properties item))
                   else collect (cons reg item))))

  ;; 函数：移除包含了复杂/不可打印 Lisp 对象的 register，防止 savehist 报错
  (defun my-savehist-remove-unprintable-registers-h ()
    (setq-local register-alist (cl-remove-if-not #'savehist-printable register-alist)))

  ;; 增强：恢复上次光标位置（save-place）后，自动将光标所在行居中显示
  (define-advice save-place-find-file-hook (:after-while (&rest _) my-recenter)
    "Recenter on cursor when loading a saved place."
    (if buffer-file-name (ignore-errors (recenter))))

  ;; 增强：对超长文件（so-long-mode）跳过恢复光标位置，防止性能卡顿
  (define-advice save-place-to-alist (:around (fn &rest args) my-inhibit-long-files)
    (unless (bound-and-true-p so-long-minor-mode)
      (apply fn args)))

  ;; 增强：如果已经有其他 Hook 移动了光标，则不再强制移动
  (define-advice save-place-find-file-hook (:before-while (&rest _) my-point-at-bol)
    "If something else has moved point, don't try to move it again."
    (bobp))

  ;; 优化：保存 save-place 数据时，使用原生的 `prin1` 替换较慢的 `pp`（Pretty Print），大幅提升退出时的保存速度
  (define-advice save-place-alist-to-file (:around (fn &rest args) my-no-pp)
    "`save-place-alist-to-file' uses `pp' to prettify the contents of its cache.
`pp' can be expensive for longer lists, and there's no reason to prettify cache
files, so this replace calls to `pp' with the much faster `prin1'."
    (cl-letf (((symbol-function 'pp) #'prin1))
      (apply fn args))))


;; =============================================================================
;; 7. repeat: 快捷键重复模式
;; =============================================================================
(use-package repeat
  :ensure nil
  :hook nn-first-file
  ;; 在 Mode-line（状态栏）上显示当前处于快捷键重复（Repeat）状态
  :custom (repeat-echo-mode-line t))


;; =============================================================================
;; 8. uniquify: 同名 Buffer 命名去重
;; =============================================================================
(use-package uniquify
  :ensure nil
  :custom
  ;; 当打开同名文件时，使用前向路径区分，如 `file.txt|path(a)` 和 `file.txt|path(b)`
  (uniquify-buffer-name-style 'forward)
  ;; 剥离路径中公共的相同前缀目录，保持 Buffer 名称简洁
  (uniquify-strip-common-suffix t)
  ;; 关闭某个同名 Buffer 后，自动重命名剩下的同名 Buffer 恢复简洁名称
  (uniquify-after-kill-buffer-flag t))


;; =============================================================================
;; 9. mwheel: 鼠标滚轮行为设置
;; =============================================================================
(use-package mwheel
  :ensure nil
  :custom
  ;; 禁用滚轮加速（滚动速度保持恒定，避免滚轮滑动太快直接飞掉）
  (mouse-wheel-progressive-speed nil)
  ;; 滚轮滚动时不强制让光标跟着焦点移动
  (mouse-wheel-follow-mouse nil)
  ;; 禁用触控板/鼠标的水平倾斜滚动
  (mouse-wheel-tilt-scroll nil)
  ;; 滚动幅度配置：默认每次 2 行；按住 Shift 每次 2 行；按住 Ctrl 缩放字体大小
  (mouse-wheel-scroll-amount '(2 ((shift) . 2) ((control) . text-scale))))


;; =============================================================================
;; 10. pixel-scroll: 像素级平滑滚动（Emacs 29+ 现代化滚动）
;; =============================================================================
(use-package pixel-scroll
  :ensure nil
  ;; 首次打开文件时开启高精度像素平滑滚动（支持触控板平滑滑动）
  :hook (nn-first-file . pixel-scroll-precision-mode)
  :custom
  ;; 禁用光标靠近上下边缘时的强制边距保持
  (scroll-margin 0)
  ;; 滚动步长设为 0（交给像素滚动接管）
  (scroll-step 0)
  ;; 防止光标移动到屏幕外时发生页面大跳动（大于 100 表示逐行平滑移动）
  (scroll-conservatively 101)
  ;; 翻页（PageUp/PageDown）时，保持光标在屏幕上的相对位置不变
  (scroll-preserve-screen-position t)
  ;; 禁用触控板滚动的惯性动量（防止手停下后页面还在继续滑）
  (pixel-scroll-precision-use-momentum nil))


;; =============================================================================
;; 11. frame: Window / Frame 窗口边框与外观线
;; =============================================================================
(use-package frame
  :ensure nil
  :hook (window-configuration-change . my-update-window-divider-bottom)
  :init
  ;; 禁用光标闪烁（保持静态光标，节约性能且不打扰注意力）
  (blink-cursor-mode -1)
  ;; 开启窗口分隔线模式，方便鼠标拖拽调整窗口大小
  (window-divider-mode 1)
  :custom
  ;; 默认在所有边缘显示窗口分隔线
  (window-divider-default-places t)
  ;; 右侧分隔线宽度为 1 像素
  (window-divider-default-right-width 1)
  ;; 底部分隔线默认宽度为 0 像素
  (window-divider-default-bottom-width 0)
  :config
  ;; 动态更新底部分隔线：如果当前 Frame 只有一个窗口，隐藏底部分隔线；多窗口时显示 1 像素线
  (defun my-update-window-divider-bottom ()
    (set-frame-parameter nil 'bottom-divider-width
                         (if (eq (next-window) (selected-window))
                             0 1)))

  ;; 过滤器函数：在切换 Buffer 时，过滤掉以 `*` 开头的内部临时 Buffer（除非显式白名单允许）
  (defun my-buffer-predicate (buf)
    "Filter out * and space-prefixed buffers unless in `nn-buffer-allow-names'."
    (let ((name (buffer-name buf)))
      (or (member name nn-buffer-allow-names)
          (let ((first (aref name 0)))
            (not (= first ?*))))))
  ;; 将上面定义的 Buffer 过滤器应用到当前 Frame
  (set-frame-parameter nil 'buffer-predicate #'my-buffer-predicate))


;; =============================================================================
;; 12. window: 窗口切分策略与 `display-buffer` 弹窗管理
;; =============================================================================
(use-package window
  :ensure nil
  :custom
  ;; 只有当 Frame 宽度大于 160 列时，Emacs 才允许自动左右垂直切分窗口
  (split-width-threshold 160)
  ;; 禁用自动上下水平切分窗口
  (split-height-threshold nil)
  ;; 调整窗口大小按像素级别进行（更精确平滑）
  (window-resize-pixelwise t)
  ;; 调整某个窗口大小时，自动平均调整关联的其他窗口大小
  (window-combination-resize t)
  
  ;; 【核心配置】弹出窗口行为规则控制（使用 Side Window 侧边/底部固定的专业级配置）
  (display-buffer-alist
   '(;; 1. 回溯栈、警告、编译日志、消息、书签、Occur、ElDoc 等窗口：固定弹在底部侧边栏
     ("\\*\\(Backtrace\\Vert{}Warnings\\Vert{}Compile-Log\\Vert{}Messages\\Vert{}Bookmark List\\Vert{}Occur\\Vert{}eldoc\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.35) ; 占用 35% 高度
      (side . bottom)        ; 底部显示
      (slot . 0))            ; 槽位 0
     
     ;; 2. 帮助文档 (*Help*)：固定弹在右侧侧边栏，占用 50% 宽度
     ("\\*\\([Hh]elp\\)\\*"
      (display-buffer-in-side-window)
      (window-width . 0.5)   ; 占用 50% 宽度
      (side . right)         ; 右侧显示
      (slot . 0))
     
     ;; 3. Flymake 语法检查诊断窗口：弹在底部槽位 2
     ("\\*\\(Flymake diagnostics\\)"
      (display-buffer-in-side-window)
      (window-height . 0.35)
      (side . bottom)
      (slot . 2))
     
     ;; 4. Grep/Xref 代码搜索与引用跳转窗口：弹在底部槽位 1
     ("\\*\\(grep\\Vert{}xref\\Vert{}find\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.35)
      (side . bottom)
      (slot . 1))
     
     ;; 5. 交互式 REPL / 终端进程（如 *inferior-python*）：弹在底部，占用 50% 高度
     ("\\*inferior.*"
      (display-buffer-in-side-window)
      (window-height . 0.5)
      (side . bottom)
      (slot . 1)))))

(provide 'init-base)
