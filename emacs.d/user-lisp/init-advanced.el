;;; -*- lexical-binding: t -*-

;;; 中文导读：高级内置工具集合。Eldoc 显示/复制光标处文档，minibuffer/isearch
;;; 调整输入与搜索，Dired/WDired/image-dired 管理文件和图片，Speedbar 浏览目录，
;;; compile 运行构建，Ibuffer/Bufler 按项目组织缓冲区，jit-lock 控制即时着色。
;;; 常用键：C-c h . 复制文档，M-RET 打印符号信息，C-RET 补全；Dired 中 e 进入
;;; 可编辑模式、- 新建空文件、C-c C-e 编辑文件名；C-| 打开 Speedbar；C-c c
;;; 编译；C-c b i 打开 Ibuffer；C-x C-b/C-x b 打开 Bufler/切换缓冲区。
;; =============================================================================
;; 1. jit-lock: 延迟语法高亮优化（Jit-Lock / Font-Lock 核心引擎）
;; =============================================================================
(use-package jit-lock
  :ensure nil
  :custom
  ;; 延迟高亮等待时间（秒）。0 表示屏幕滚动时立即着色当前可见区域
  (jit-lock-defer-time 0)
  ;; 隐蔽/后台高亮启动延迟（秒）。当系统空闲 0.5 秒后，在后台静默渲染未可见区域
  (jit-lock-stealth-time 0.5)
  ;; 后台高亮时每批次渲染间的暂停时间，避免后台高亮抢占 CPU 造成打字卡顿
  (jit-lock-stealth-nice 0.5)
  ;; 后台高亮的 CPU 负载阈值（百分比）。CPU 负载低于 100% 时才运行后台高亮
  (jit-lock-stealth-load 100)
  ;; 每次高亮渲染的文本块大小（字节）
  (jit-lock-chunk-size 1024))


;; =============================================================================
;; 2. eldoc: 光标处函数/变量参数文档实时提示
;; =============================================================================
(use-package eldoc
  :ensure nil
  :bind
  ("C-c h ." . my-eldoc-copy)                 ; 快捷键：复制当前 Eldoc 提示内容到剪贴板
  ("M-<return>" . eldoc-print-current-symbol-info) ; 快捷键：手动强制触发打印当前符号文档
  :custom
  ;; 在光标所在位置显示文档提示
  (eldoc-help-at-pt t)
  ;; 空闲延迟时间（秒）。停顿 0.5 秒后自动显示当前函数的参数列表/文档
  (eldoc-idle-delay 0.5)
  ;; 仅在 Eldoc 窗口已打开或处于可见状态时才应用延迟逻辑
  (eldoc-idle-delay-visible-only t)
  ;; 禁用 Echo Area（底部回显区）的多行扩展，防止提示文档太长时挤压主编辑区
  (eldoc-echo-area-use-multiline-p nil)
  ;; 文档汇总策略：热情模式（尽可能收集并合并来自多个后端如 Eglot/LSP 的提示）
  (eldoc-documentation-strategy 'eldoc-documentation-enthusiast)
  :config
  ;; 自定义函数：提取当前 Eldoc Buffer 中的文本并复制到剪贴环（Kill-ring）
  (defun my-eldoc-copy ()
    (interactive)
    (when-let* ((buf (eldoc-doc-buffer)))
      (kill-new (with-current-buffer buf (buffer-string)))
      (message "Copied eldoc to kill ring"))))


;; =============================================================================
;; 3. minibuffer: Emacs 原生底栏补全与交互界面增强
;; =============================================================================
(use-package minibuffer
  :ensure nil
  :bind ("C-<return>" . completion-at-point) ; 快捷键：手动触发代码/文本补全
  :hook (minibuffer-setup . cursor-intangible-mode) ; 禁用光标进入 Minibuffer 提示词前缀区
  :custom
  ;; 触发补全时自动弹出帮助/候选列表
  (completion-auto-help t)
  ;; 自动选中第一个候选词
  (completion-auto-select t)
  ;; 输入时急迫更新补全结果
  (completion-eager-update t)
  ;; 不急迫强行展示候选面板（提升响应体验）
  (completion-eager-display nil)
  ;; 补全时忽略字母大小写
  (completion-ignore-case t)
  ;; 显示补全帮助信息
  (completion-show-help t)
  ;; 补全匹配样式策略：依次尝试部分匹配(partial-completion)、模糊匹配(flex)和首字母匹配(initials)
  (completion-styles '(partial-completion flex initials))
  ;; 补全候选窗口最大行高限制为 10 行
  (completions-max-height 10)
  ;; 候选列表采用单列垂直排列（更符合现代阅读习惯）
  (completions-format 'one-column)
  ;; 候选词排序策略：优先展示历史频繁使用过的项
  (completions-sort 'historical)
  ;; 允许在 Minibuffer 激活时递归开启嵌套的 Minibuffer
  (enable-recursive-minibuffers t)
  ;; 切换 Buffer 时补全忽略大小写
  (read-buffer-completion-ignore-case t)
  ;; 打开文件（read-file-name）时补全忽略大小写
  (read-file-name-completion-ignore-case t)
  ;; 使用上下键（up-down）在 Minibuffer 可见候选词中导航（Emacs 29+ 特性）
  (minibuffer-visible-completions 'up-down)
  ;; 设置 Minibuffer 提示前缀文本属性为只读且光标不可穿越
  (minibuffer-prompt-properties
   '(read-only t intangible t cursor-intangible t face minibuffer-prompt))
  :config
  ;; 当发生 Minibuffer 嵌套递归时，在提示栏显示当前嵌套深度（如 [(1)]）
  (minibuffer-depth-indicate-mode 1)
  ;; 自动将默认候选选项放到可以直接回车确认的位置
  (minibuffer-electric-default-mode 1))


;; =============================================================================
;; 4. wdired: 可编辑 Dired 模式（像编辑普通文本一样批量重命名/修改文件）
;; =============================================================================
(use-package wdired
  :ensure nil
  :commands wdired-change-to-wdired-mode
  :custom
  ;; 允许在 WDired 中直接修改文件/目录的权限属性
  (wdired-allow-to-change-permissions t)
  ;; 重命名或移动文件到新路径时，若父目录不存在则自动创建
  (wdired-create-parent-directories t))


;; =============================================================================
;; 5. dired: 文件管理器核心配置
;; =============================================================================
(use-package dired
  :ensure nil
  :commands dired-jump
  :bind
  (:map dired-mode-map
   ("e" . dired-toggle-read-only)             ; 按 e 快速切换到 WDired 编辑模式
   ("-" . dired-create-empty-file)            ; 按 - 快速创建空文件
   ("C-c C-e" . wdired-change-to-wdired-mode)) ; 进入 WDired 模式
  :hook (dired-mode . my-dired-vc-ignores)
  :custom
  ;; 智能双面板操作：若开启了两个 Dired 窗口，复制/移动文件时自动将另一个窗口设为目标路径
  (dired-dwim-target t)
  ;; 支持从 Dired 窗口中用鼠标拖拽文件到外部系统或其他软件
  (dired-mouse-drag-files t)
  ;; 当磁盘内容变动时自动刷新 Dired 缓冲区
  (dired-auto-revert-buffer #'dired-buffer-stale-p)
  ;; 递归删除文件夹策略：仅在顶层目录询问一次
  (dired-recursive-deletes 'top)
  ;; 递归复制文件夹策略：总是自动递归复制子目录而无需逐一确认
  (dired-recursive-copies 'always)
  ;; 复制/移动文件时，如果目标目录不存在则直接自动创建
  (dired-create-destination-dirs 'always)
  ;; 执行移动、复制、删除操作时不弹出二次确认框
  (dired-no-confirm '(move copy delete))
  ;; 在 Dired 中进入新目录时，自动杀死旧的 Dired 缓冲区（防止产生大量 Dired buffer）
  (dired-kill-when-opening-new-dired-buffer t)
  ;; 传递给系统的 ls 参数：显示全部(a)、人性化文件大小(h)、详细属性(l)，且文件夹排在最前
  (dired-listing-switches "-alh --group-directories-first")
  :config
  ;; 启用 disabled 的 `dired-find-alternate-file` 命令（用 a 键进入目录时不新建 buffer）
  (put 'dired-find-alternate-file 'disabled nil)

  ;; 修复：不在虚拟 Dired 缓冲区（dired-virtual）中触发自动刷新
  (define-advice dired-buffer-stale-p (:before-while (&rest args)
                                       my-dired--no-revert-in-virtual-buffers-a)
    "Don't auto-revert in dired-virtual buffers (see `dired-virtual-revert')."
    (not (eq revert-buffer-function #'dired-virtual-revert)))

  ;; 函数：解析当前 Git 版本库的 .gitignore 规则，并在 Dired 中将匹配的忽略文件高亮为灰色/暗色
  (defun my-dired-vc-ignores ()
    (when-let* ((root (vc-root-dir))
                (backend (vc-responsible-backend root))
                (ignores (vc-call-backend
                          backend
                          'ignore-completion-table default-directory))
                (pattern (concat "\\=\\(" (regexp-opt ignores)
                                 "\\)\\(?:$\\|\\s-\\)")))
      (font-lock-add-keywords
       nil
       `((,dired-move-to-filename-regexp
          (,pattern (dired-move-to-filename) nil (1 'dired-ignored t))))
       'add-to-end))))


;; =============================================================================
;; 6. dired-x: Dired 扩展（隐藏/忽略特定文件与外部默认打开关联）
;; =============================================================================
(use-package dired-x
  :ensure nil
  :hook (dired-mode . dired-omit-mode) ; 默认开启文件隐藏模式（Omit Mode）
  :custom
  (dired-omit-verbose nil)   ; 隐藏文件时不打印详细提示信息
  (dired-omit-extensions nil)
  ;; 正则表达式：在 Dired 中按下 `z o` 默认隐藏的临时文件与系统垃圾文件
  (dired-omit-files
   (concat
    "^#"
    "\\|^\\.#"
    "\\|^desktop\\.ini\\'"
    "\\|^Thumbs\\.db\\'"
    "\\|^System Volume Information\\'"
    "\\|^\\$RECYCLE\\.BIN\\'"
    "\\|^ntuser\\."
    "\\|^\\.DS_Store\\'"))
  :config
  ;; 根据操作系统自动获取调用外部软件的命令（open / xdg-open / start）
  (let ((cmd (cond ((eq system-type 'darwin) "open")
                   ((eq system-type 'gnu/linux) "xdg-open")
                   ((eq system-type 'windows-nt) "start")
                   (t ""))))
    ;; 在 Dired 中按 `!` 关联快捷打开规则：使用系统默认程序打开 PDF、视频、图片、音频等格式
    (setq dired-guess-shell-alist-user
          `(("\\.pdf\\'" ,cmd)
            ("\\.docx\\'" ,cmd)
            ("\\.\\(?:djvu\\|eps\\)\\'" ,cmd)
            ("\\.\\(?:jpg\\|jpeg\\|png\\|gif\\|xpm\\)\\'" ,cmd)
            ("\\.\\(?:xcf\\)\\'" ,cmd)
            ("\\.csv\\'" ,cmd)
            ("\\.tex\\'" ,cmd)
            ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|rm\\|rmvb\\|ogv\\)\\(?:\\.part\\)?\\'" ,cmd)
            ("\\.\\(?:mp3\\|flac\\)\\'" ,cmd)
            ("\\.html?\\'" ,cmd)
            ("\\.md\\'" ,cmd)))))


;; =============================================================================
;; 7. dired-aux: Dired 进阶文件压缩与版本控制集成
;; =============================================================================
(use-package dired-aux
  :ensure nil
  :custom
  ;; 使用 Git / VC 的重命名机制重命名已经被版本控制跟踪的文件
  (dired-vc-rename-file t)
  ;; 创建目标目录时进行询问
  (dired-create-destination-dirs 'ask)
  ;; 配置压缩单个文件的解压缩/压缩命令行工具算法（使用 7z）
  (dired-compress-file-alist
   '(("\\.7z\\'" . "7z a -r %o %i")
     ("\\.zip\\'" . "7z a -r %o  %i")))
  ;; 配置批量压缩多个文件的命令行工具算法
  (dired-compress-files-alist
   '(("\\.7z\\'" . "7z a -r %o %i")
     ("\\.zip\\'" . "7z a -r %o  %i")))
  ;; 默认打压缩包时的后缀格式名
  (dired-compress-directory-default-suffix ".7z")
  (dired-compress-file-default-suffix ".7z"))


;; =============================================================================
;; 8. image-dired: Dired 内置图片缩略图预览与画廊
;; =============================================================================
(use-package image-dired
  :ensure nil
  :custom
  ;; 设置缩略图及数据库文件的存放路径
  (image-dired-dir (expand-file-name "image-dired/" nn-directory))
  (image-dired-db-file (expand-file-name "image-dired/db.el" nn-directory))
  (image-dired-gallery-dir (expand-file-name "image-dired/gallery/" nn-directory))
  (image-dired-temp-image-file (expand-file-name "image-dired/temp-image" nn-directory))
  (image-dired-temp-rotate-image-file (expand-file-name "image-dired/temp-rotate-image" nn-directory))
  ;; 预览缩略图的像素尺寸
  (image-dired-thumb-size 150)
  :config
  ;; 自动创建画廊所需目录
  (make-directory (expand-file-name "image-dired/gallery/" nn-directory) t)
  ;; 弹窗规则：将图片预览窗口固定在底部侧边栏，占 80% 宽度
  (add-to-list
   'display-buffer-alist
   '("^\\*image-dired"
     (display-buffer-in-side-window)
     (side . bottom)
     (slot . 20)
     (window-width . 0.8))))


;; =============================================================================
;; 9. speedbar: 内置项目/文件/代码结构大纲树侧边栏
;; =============================================================================
(use-package speedbar
  :ensure nil
  :bind
  (("C-|" . speedbar-window)                  ; 快捷键 C-| 快速打开/关闭 Speedbar
   :map speedbar-mode-map
   ("q" . delete-window))                      ; 按 q 关闭 Speedbar 窗口
  :custom
  ;; 窗口固定放在右侧
  (speedbar-window-side 'right)
  ;; 侧边栏默认宽度为 30 列
  (speedbar-window-default-width 30)
  ;; 极简/极速优化：关闭各类耗时的后台检查与图标渲染
  (speedbar-vc-do-check nil)                  ; 禁用版本控制状态检查
  (speedbar-obj-do-check nil)                 ; 禁用编译目标文件检查
  (speedbar-use-images nil)                   ; 禁用图标（使用纯文本显示提升性能）
  (speedbar-use-imenu-flag nil)               ; 禁用 Imenu 索引解析
  (speedbar-use-tool-tips-flag nil)           ; 禁用 Tooltip 气泡提示
  (speedbar-hide-button-brackets-flag t)      ; 隐藏按钮旁边的方括号，让界面更精简
  (speedbar-mode-functions-list nil)          ; 禁用特定 Mode 扩展函数
  (speedbar-mode-specific-contents-flag nil)
  (speedbar-dynamic-tags-function-list nil)   ; 禁用动态 Tag 解析
  (speedbar-special-mode-expansion-list nil)
  (speedbar-show-unknown-files t)             ; 显示未识别扩展名的文件
  (speedbar-smart-directory-expand-flag nil)  ; 禁用智能目录展开（手动展开）
  (speedbar-verbosity-level 0)                ; 极其安静模式（不输出提示）
  (speedbar-directory-unshown-regexp "^\\(\\.\\.*$\\)")) ; 过滤 . 和 .. 目录


;; =============================================================================
;; 10. compile: 项目编译、构建与日志输出
;; =============================================================================
(use-package compile
  :ensure nil
  :hook
  ;; 编译日志输出时，自动解析并渲染终端 ANSI 彩色转义字符
  (compilation-filter . ansi-color-compilation-filter)
  ;; 日志输出过多时自动截断开头，避免 Compile 缓冲区过大卡死 Emacs
  (compilation-filter . nn-comint-truncate-buffer-h)
  :bind
  (("C-c c" . compile)                        ; 快捷键：触发编译
   :map compilation-mode-map
   ("r" . compile)                            ; 按 r 重新运行编译
   ("C-c C-k" . delete-process))              ; 强行终止正在运行的编译进程
  :custom
  (compile-command "")                        ; 默认编译命令置空
  (compilation-always-kill t)                 ; 重新编译时，自动杀死上次尚未结束的编译进程
  (compilation-ask-about-save nil)            ; 编译前自动保存所有文件，不弹窗确认
  (compilation-max-output-line-length nil)    ; 不限制单行输出最大长度
  (compilation-scroll-output 'first-error)    ; 自动向下滑动日志，直到遇到第一个 Error 错误时停下
  (compilation-window-height 12)              ; 编译窗口默认占用 12 行高度
  (compilation-skip-threshold 1)              ; 使用 next-error (M-g n) 时，自动跳过 Warning 警告直达 Error 错误
  (compilation-transform-file-name-alist nil)
  :config
  ;; 添加额外的正则表达式以解析某些非标编译器/构建工具的错误/警告格式
  (add-to-list
   'compilation-error-regexp-alist
   '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
     1 2 (4) (5)))

  ;; 钩子函数：高效截断超大编译日志 Buffer，防止长串输出引发 GC 或渲染卡顿
  (defun nn-comint-truncate-buffer-h (&optional _string)
    "Rate-limit `comint-truncate-buffer' in compilation-mode buffers."
    (if (> (buffer-size)
           ;; HACK: Approximate this because counting lines is prohibitively
           ;;   expensive in longer buffers, especially in
           ;;   `compilation-filter-hook' which fires rapidly.
           (* 80 comint-buffer-maximum-size))
        (let ((gc-cons-threshold most-positive-fixnum)
              (gc-cons-percentage 1.0))
          (with-silent-modifications
            (comint-truncate-buffer))))))


;; =============================================================================
;; 11. isearch: 原生增量搜索增强 (C-s / C-r)
;; =============================================================================
(use-package isearch
  :ensure nil
  :bind
  (:map isearch-mode-map
   ([remap isearch-delete-char] . isearch-del-char)) ; 退格键只删除搜索字符而不是退回上一次搜索匹配位置
  :custom
  (isearch-lazy-highlight t)                  ; 开启延时高亮屏幕上所有匹配项
  (isearch-wrap-pause t)                      ; 搜索到文件末尾/开头时，先暂停并提示，再次按 C-s 才循环回头部
  (isearch-allow-motion t)                    ; 搜索时允许使用光标移动快捷键
  (isearch-motion-changes-direction t)        ; 向上/向下移动光标时自动改变搜索方向
  (isearch-lazy-count t)                      ; 在底栏实时显示“第 X 项 / 共 Y 项”匹配计数
  (lazy-highlight-cleanup t)                  ; 退出搜索时自动清理高亮背景
  (lazy-count-prefix-format "%s/%s ")         ; 计数格式：例如 "3/15 "
  :config
  ;; 内部变量及 Advice：记录上一次 isearch 搜索的方向（向前/向后）
  (defvar my-isearch--direction nil)
  (define-advice isearch-exit (:after nil)
    (setq-local my-isearch--direction nil))
  (define-advice isearch-repeat-forward (:after (_))
    (setq-local my-isearch--direction 'forward))
  (define-advice isearch-repeat-backward (:after (_))
    (setq-local my-isearch--direction 'backward)))


;; =============================================================================
;; 12. ibuffer: 高级 Buffer 管理器（替代传统的 C-x C-b 窗口）
;; =============================================================================
(use-package ibuffer
  :ensure nil
  :bind ("C-c b i" . ibuffer)
  ;; 打开 IBuffer 时默认应用名为 "main" 的预定义分组过滤规则
  :hook (ibuffer-mode . (lambda () (ibuffer-switch-to-saved-filter-groups "main")))
  :custom
  (ibuffer-expert t)                          ; 专家模式：删除缓冲区时不弹窗确认提示
  (ibuffer-display-summary nil)               ; 不显示底部的摘要信息行
  (ibuffer-use-other-window nil)              ; 在当前窗口打开 IBuffer（不强行切分新窗口）
  (ibuffer-show-empty-filter-groups nil)      ; 隐藏当前没有任何 Buffer 的空分组
  (ibuffer-default-sorting-mode 'filename/process) ; 默认按照文件名/进程排序
  (ibuffer-title-face 'font-lock-doc-face)
  (ibuffer-use-header-line t)                 ; 使用顶部 Header Line 显示列名
  (ibuffer-default-shrink-to-minimum-size nil)
  ;; 格式化列表展示字段：标记、修改状态、名称、大小、模式、文件名
  (ibuffer-formats
   '((mark " " (name 16 -1) " " filename)
     (mark modified read-only " "
           (name 18 18 :left :elide) " "
           (size 9 -1 :right) " "
           (mode 16 16 :left :elide) " "
           filename-and-process)))
  ;; 核心：IBuffer 的分类分组规则（将不同的文件根据正则表达式和 Mode 自动聚合）
  (ibuffer-saved-filter-groups
   '(("main"
      ("C/C++" (name . "\\.\\(c\\Vert{}cpp\\Vert{}cc\\Vert{}h\\Vert{}hpp\\Vert{}cppm\\Vert{}ixx\\)$"))
      ("Scripts" (name . "\\.\\(sh\\Vert{}lua\\Vert{}bat\\Vert{}cmd\\Vert{}ps1\\Vert{}py\\Vert{}pl\\)$"))
      ("Web" (or (name . "\\.\\(html?\\Vert{}xml\\Vert{}css\\Vert{}s[ac]ss\\Vert{}less\\Vert{}jsx?\\Vert{}tsx?\\Vert{}json\\Vert{}md\\)$")))
      ("Config" (or (name . "\\.\\(toml\\Vert{}ya?ml\\Vert{}ini\\Vert{}cfg\\Vert{}conf\\Vert{}gitignore\\)$")
                    (name . "^\\.clangd$")
                    (name . "^Doxyfile$")
                    (name . "^config\\.toml$")))
      ("Assets" (or (name . "\\.\\(png\\Vert{}jpe?g\\Vert{}svg\\Vert{}webp\\Vert{}bpm\\Vert{}ppm\\Vert{}mp[34]\\Vert{}mov\\Vert{}avi\\Vert{}obj\\)$")))
      ("News" (name . "^\\*Newsticker.*"))
      ("Gnus" (or
               (mode  . message-mode)
               (mode  . gnus-group-mode)
               (mode  . gnus-summary-mode)
               (mode  . gnus-article-mode)
               (name  . "^\\*Group\\*")
               (name  . "^\\*Summary\\*")
               (name  . "^\\*Article\\*")
               (name  . "^\\*BBDB\\*")))
      ("Chat" (or (mode . telega-root-mode)
                  (mode . telega-chat-mode)
                  (mode . rcirc-mode)
                  (mode . erc-mode)
                  (name . "^\\*rcirc.*")
                  (name . "^\\*ERC.*")))
      ("Document" (name . "\\.\\(md\\Vert{}markdown\\Vert{}org\\Vert{}adoc\\Vert{}tex\\Vert{}pdf\\Vert{}rst\\Vert{}txt\\)$"))
      ("VC" (or (name . "\\*vc-")))
      ("LLM" (or (mode . gptel-mode)
                 (mode . gptel-chat-mode)))
      ("LSP" (or (name . "\\`\\*\\(EGLOT\\|eldoc\\|LSP\\|lsp-help\\|Flymake\\)")
                 (derived-mode . eglot--managed-mode)))
      ("Debug" (or (derived-mode . special-mode)
                   (name . "\\`\\*\\(Backtrace\\Vert{}debug\\Vert{}Messages\\Vert{}Warnings\\Vert{}Compile-Log\\Vert{}gud-\\Vert{}dap-\\)")
                   (mode . debugger-mode)
                   (mode . gdb-mi-mode)))
      ("Compile/Shell" (or (derived-mode . comint-mode)
                           (name . "\\`\\*\\(compilation\\|Async Shell Command\\)")))
      ("Dired" (mode . dired-mode))
      ("Emacs" (or (derived-mode . emacs-lisp-mode)
                   (name . "\\`\\*\\(Help\\Vert{}Custom\\Vert{}info\\Vert{}scratch\\)"))))))
  :config
  ;; 扩展：为 IBuffer 添加人性化（Human-Readable，如 1.2k、4M）的文件大小列显示
  (define-ibuffer-column size
    (:name "Size" :inline t :header-mouse-map ibuffer-size-header-map)
    (file-size-human-readable (buffer-size))))


;; =============================================================================
;; 13. bufler: 现代化智能工作区与 Buffer 分类切换面板 (第三方包)
;; =============================================================================
(use-package bufler
  :bind
  (("C-x C-b" . bufler)                       ; 替代传统的 C-x C-b
   ("C-x b" . bufler-switch-buffer)            ; 智能切换 Buffer
   ("C-c b b" . bufler)
   ("C-c b s" . bufler-sidebar)                ; 打开 Bufler 侧边栏
   ("C-c b f" . bufler-workspace-focus-buffer) ; 聚焦当前工作区 Buffer
   ("C-c b w" . bufler-workspace-set)          ; 设置/切换工作区
   ("C-c b n" . bufler-workspace-buffer-name-workspace))
  :hook (nn-first-input . bufler-mode)
  :custom
  ;; 启用缓存以提升大量 Buffer 时的加载性能
  (bufler-use-cache t)
  (bufler-reverse nil)
  ;; 关闭在列表中实时查询文件的 Git VC 状态（提升显示响应速度）
  (bufler-vc-state nil)
  (bufler-vc-refresh nil)
  (bufler-vc-remote nil)
  ;; 列表分组间的分隔符配置
  (bufler-list-group-separators '((0 . "\n")))
  ;; 显示列：名称、大小、Mode、路径
  (bufler-columns '("Name" "Size" "Mode" "Path"))
  (bufler-column-name-max-width 40)
  (bufler-column-path-max-width nil)
  (bufler-workspace-ignore-case t)
  ;; 切换 Buffer 时将最近使用过的文件一并包含在候选菜单中
  (bufler-switch-buffer-include-recent-buffers t))

(provide 'init-advanced)
