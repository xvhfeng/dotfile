;;; -*- lexical-binding: t -*-

;;; 中文导读：实现上下文感知的右键菜单，根据当前缓冲区、选区和点击位置动态加入
;;; 剪切复制、跳转、项目与模式命令。鼠标右键在正文、左边距和右边距中都会调用
;;; `nn-context-menu'，因此三处菜单行为保持一致。
;; 返回当前缓冲区是否已有 Eglot/LSP 会话，用于决定是否显示代码操作菜单。
;; 检查当前 Buffer 是否已经启用了 Eglot LSP 客户端服务
(defun nn-has-lsp ()
  (and (fboundp 'eglot-current-server)
       (eglot-current-server)))

;; 将当前缓冲区的文件编码改为 UTF-8，保存时按 UTF-8 写入磁盘。
(defun nn-convert-utf8 ()
  (interactive)
  (set-buffer-file-coding-system 'utf-8))

;; 调用系统文件管理器打开当前文件所在目录。
(defun nn-explorer-open ()
  (interactive)
  (shell-command "explorer ."))

;; 为当前 Web 项目启动或切换 live-server 预览。
(defun nn-live-server ()
  (interactive)
  (require 'live-server)
  (live-server-start))

;; 翻译光标处单词的占位交互命令，供上下文菜单按条件替换/扩展。
(defun my-translate-word () (interactive))

;; 翻译活动选区的占位交互命令。
(defun my-translate-region () (interactive))

;; 翻译整个缓冲区的占位交互命令。
(defun my-translate-buffer () (interactive))

;; 按当前 major mode、选区和可用功能构造并弹出右键上下文菜单。
(defun nn-context-menu ()
  (interactive)
  (popup-menu
   (cond
    ;; 1. 若处于文件列表（Dired）或目录树（Speedbar）下，弹出项目/文件相关菜单
    ((or (derived-mode-p 'dired-mode)
         (derived-mode-p 'speedbar-mode))
     nn-project-menu-items)
    ;; 2. 若处于代码（prog-mode）或文本（text-mode）模式下，弹出代码编辑菜单
    ((or (derived-mode-p 'prog-mode)
         (derived-mode-p 'text-mode))
     nn-edit-menu-items)
    ;; 3. 其他默认场景，弹出休闲/生活类菜单
    (t nn-leisure-menu-items))
   ;; 在鼠标右键点击的具体像素位置弹出菜单
   `(mouse-3 ,(mouse-absolute-pixel-position))))

;; 定义代码编辑右键菜单的具体选项
(defconst nn-edit-menu-items
  '("NN Edit Menu"
    ["Comman Format" apheleia-format-buffer]               ; 使用 apheleia 异步格式化代码
    ["Debug Code"    dape]                                 ; 使用 dape 启动调试器
    ["Lsp Connect"   eglot]                                ; 连接/启动 Eglot LSP
    ["Lsp Shutdown"  eglot-shutdown]                       ; 关闭 Eglot LSP 连接
    ["Lsp Format"    eglot-format-buffer :active (nn-has-lsp)] ; LSP 格式化（仅当连接 LSP 时激活）
    ["Lsp Log"       eglot-stderr-buffer :active (nn-has-lsp)] ; 打开 LSP 日志（仅当连接 LSP 时激活）
    ("Code Actions"                                        ; 子菜单：LSP 重构与代码操作
     :active (nn-has-lsp)
     ["Quick Fix"        eglot-code-actions]               ; 快速修复
     ["Extract"          eglot-code-action-extract]        ; 提炼/抽取代码
     ["Inline"           eglot-code-action-inline]         ; 代码内联化
     ["Organize Imports" eglot-code-action-organize-imports]; 整理引入包
     ["Rewrite"          eglot-code-action-rewrite])       ; 代码重写
    "--"                                                   ; 分割线
    ["Translate Word"    my-translate-word]                ; 翻译光标下的词
    ["Translate Region"  my-translate-region]              ; 翻译选中文本
    ["Translate Bufefer" my-translate-buffer]              ; 翻译当前 Buffer
    "--"                                                   ; 分割线
    ["Indent Format"  indent-region]                       ; 按语言规则自动缩进选区
    ["Spell Check"    ispell-buffer]                       ; 拼写检查
    ["Convert Utf8"   nn-convert-utf8]                     ; 转为 UTF-8 编码
    ["Align Region"   align-regexp]                        ; 正则表达式列对齐
    ["Regexp Builder" re-builder]                          ; 启动正则表达式交互构建器
    ["Sort Lines"     sort-lines]))                        ; 对选中行按照字母排序

;; 定义项目/文件浏览器右键菜单的具体选项
(defconst nn-project-menu-items
  '("NN Project Menu"
    ["Create Tasg File" citre-create-tags-file]       ; 使用 Citre 创建 Ctags 标签文件
    ["Update Tags File" citre-update-this-tags-file]  ; 更新现有的 Tags 文件
    ["On Live server"   nn-live-server]              ; 开启网页 Live Server 服务
    ["On Explorer Open" nn-explorer-open]             ; 打开系统文件资源管理器
    ;; TODO：未完成的功能占位（目前绑定为 kill-buffer）
    ("C/C++ Module"
     ["New header File"     kill-buffer]
     ["New C++ Module File" kill-buffer]
     ["New C/C++ Project"   kill-buffer])
    ("Web Module"
     ["New HTML Project"  kill-buffer]
     ["New Vue Project"   kill-buffer]
     ["New React Project" kill-buffer])))

;; 定义休闲模式右键菜单的具体选项
(defconst nn-leisure-menu-items
  '("NN Leisure Menu"
    ["telegram"  telega]                 ; 启动 Telega 客户端收发 Telegram
    ["Read Mail" gnus]                   ; 启动 Gnus 阅读邮件/新闻组
    ["Read Rss"  my-newsticker-show-news]; 启动 RSS 阅读器
    ["Send Mail" compose-mail]           ; 撰写邮件
    "--"                                 ; 分割线
    ["Translate Word"    my-translate-word]
    ["Translate Region"  my-translate-region]
    ["Translate Bufefer" my-translate-buffer]))

;; 在加载 speedbar 模块后，禁用其默认的右键按下响应，防止与自定义菜单冲突
(with-eval-after-load 'speedbar
  (keymap-set speedbar-mode-map "<down-mouse-3>" nil))

;; 将自定义菜单绑到全局鼠标右键（包括编辑区、左侧边距、右侧边距）
(keymap-global-set "<mouse-3>" #'nn-context-menu)
(keymap-global-set "<left-margin> <mouse-3>" #'nn-context-menu)
(keymap-global-set "<right-margin> <mouse-3>" #'nn-context-menu)

(provide 'init-context-menu)
