

; -*- lexical-binding: t -*-

; Copyright (C) 2026  xvhfeng

; Author: xvhfeng <xvhfeng@xvhfengdeMacBook-Air.local>

; Keywords: lisp

; neotree.el --- 类似于 Vim 中 NerdTree 的 Emacs 侧边栏文件树插件

; 版权所有 (C) 2014 jaypei

; 作者: jaypei jaypei97159@gmail.com

; 网址: https://github.com/jaypei/emacs-neotree

; 版本: 0.6.0

; 依赖包: ((cl-lib "0.5"))

; 本程序为自由软件；您可以根据自由软件基金会发布的 GNU 通用公共许可证（第3版

; 或更高版本）的条款重新分发和/或修改它。

; 简要说明 (Commentary):

; 要使用此文件，请将类似以下的代码放入您的 ~/.emacs 配置中：

; (add-to-list 'load-path "/放置/neotree/的路径/")

; (require 'neotree)

; 输入 M-x neotree 即可启动。

; 代码实现 (Code):

; 引入 Common Lisp 扩展库
(require 'cl-lib)

; 常量定义 (Constants)

; 定义 NeoTree 侧边栏 Buffer 的名称
(defconst neo-buffer-name " NeoTree"

  "NeoTree 用于显示目录内容的 Buffer 名称。")

; 获取当前插件所在的路径
(defconst neo-dir
  (expand-file-name (if load-file-name
                        (file-name-directory load-file-name)
                      default-directory)))

; 定义顶部 Header 占用的行数
(defconst neo-header-height 5)

; 编译并评估：针对旧版 Emacs 进行兼容性宏补丁
(eval-and-compile

; 如果当前 Emacs 版本低于 24.3，补齐 user-error 函数
  (unless (fboundp 'user-error)
    (defalias 'user-error 'error))

; 如果缺少 setq-local，定义 Buffer 局部变量赋值宏
  (unless (fboundp 'setq-local)
    (defmacro setq-local (var val)
      "在当前 Buffer 中将变量 VAR 设置为值 VAL。"
      (list 'set (list 'make-local-variable (list 'quote var)) val)))

; 如果缺少 defvar-local，定义局部变量声明宏
  (unless (fboundp 'defvar-local)
    (defmacro defvar-local (var val &optional docstring)
      "将 VAR 定义为默认值为 VAL 的 Buffer 局部变量。"
      (declare (debug defvar) (doc-string 3))
      (list 'progn (list 'defvar var val docstring)
            (list 'make-variable-buffer-local (list 'quote var))))))

; 预加载 VC (版本控制) 的后台处理函数
(autoload 'vc-responsible-backend "vc.elc")

; 实用宏 (Macros)

; 将任意对象转化为标准的布尔值 (t 或 nil)
(defmacro neo-util--to-bool (obj)
  "如果 OBJ 为非 nil 则返回 t，否则返回 nil。"
  `(and ,obj t))

; 在全局 NeoTree Buffer 上下文中执行代码
(defmacro neo-global--with-buffer (&rest body)
  "在全局 NeoTree Buffer 内执行 BODY 中的表达式。"
  (declare (indent 0) (debug t))
  `(let ((neotree-buffer (neo-global--get-buffer)))
     (unless (null neotree-buffer)
       (with-current-buffer neotree-buffer
         ,@body))))

; 在全局 NeoTree 窗口上下文中执行代码
(defmacro neo-global--with-window (&rest body)
  "在全局 NeoTree 窗口内执行 BODY 中的表达式。"
  (declare (indent 0) (debug t))
  `(save-selected-window
     (neo-global--select-window)
     ,@body))

; 当当前选中的窗口是 NeoTree 窗口时执行代码
(defmacro neo-global--when-window (&rest body)
  "当当前选中窗口为 NeoTree 窗口时执行 BODY。"
  (declare (indent 0) (debug t))
  `(when (eq (selected-window) neo-global--window)
     ,@body))

; 切换焦点到 NeoTree Buffer
(defmacro neo-global--switch-to-buffer ()
  "切换到 NeoTree Buffer。"
  `(let ((neotree-buffer (neo-global--get-buffer)))
     (unless (null neotree-buffer)
       (switch-to-buffer neotree-buffer))))

; 暂时解除只读限制并在 NeoTree Buffer 中编辑内容
(defmacro neo-buffer--with-editing-buffer (&rest body)
  "在解除只读限制的情况下在 NeoTree Buffer 中执行 BODY。"
  `(let (rlt)
     (neo-global--with-buffer
       (setq buffer-read-only nil)
       (setq rlt (progn ,@body))
       (setq buffer-read-only t))
     rlt))

; 暂时解除窗口尺寸固定限制
(defmacro neo-buffer--with-resizable-window (&rest body)
  "在解除 window-size-fixed 限制的情况下执行 BODY。"
  `(let (rlt)
     (neo-global--with-buffer
       (neo-buffer--unlock-width))
     (setq rlt (progn ,@body))
     (neo-global--with-buffer
       (neo-buffer--lock-width))
     rlt))

; 生成打开事件的处理函数
(defmacro neotree-make-executor (&rest fn-form)
  "创建打开事件处理句柄，FN-FORM 为事件句柄形式。"
  (let* ((get-args-fn
          (lambda (sym) (or (plist-get fn-form sym) (lambda (&rest _)))))
         (file-fn (funcall get-args-fn :file-fn))
         (dir-fn (funcall get-args-fn :dir-fn)))
    `(lambda (&optional arg)
       (interactive "P")
       (neo-global--select-window)
       (neo-buffer--execute arg ,file-fn ,dir-fn))))

; 用户自定义配置组 (Customization)
(defgroup neotree nil
  "NeoTree 插件配置组。"
  :prefix "neo-"
  :group 'files)

(defgroup neotree-vc-options nil
  "NeoTree 版本控制 (VC) 自定义配置。"
  :prefix "neo-vc-"
  :group 'neotree
  :link '(info-link "(neotree)Configuration"))(defgroup neotree-confirmations nil
  "NeoTree 确认提示框自定义配置。"
  :prefix "neo-confirm-"
  :group 'neotree)

; 设置 NeoTree 窗口放置位置（左侧或右侧）
(defcustom neo-window-position 'left
  "*NeoTree 侧边栏窗口放置的位置 (left/right)。"
  :group 'neotree
  :type '(choice (const left)
          (const right)))

; 窗口显示的 Action 函数
(defcustom neo-display-action '(neo-default-display-fn)
  "*用于展示 NeoTree 窗口的函数动作。"
  :type 'sexp
  :group 'neotree)

; 创建文件后是否自动打开
(defcustom neo-create-file-auto-open nil
  "*若为非 nil，创建新文件后会自动打开该文件。"
  :type 'boolean
  :group 'neotree)

; 横幅标语消息
(defcustom neo-banner-message nil
  "*NeoTree 顶部的 Banner 欢迎标语。"
  :type 'string
  :group 'neotree)

; 是否显示返回上一级目录 (..) 节点
(defcustom neo-show-updir-line t
  "*若为非 nil，将在最上方显示返回父目录的 '..' 行。"
  :type 'boolean
  :group 'neotree)

; 文件夹后是否附加斜杠 '/'
(defcustom neo-show-slash-for-folder t
  "*若为非 nil，文件夹名称末尾会带有斜杠。"
  :type 'boolean
  :group 'neotree)

; 打开文件时是否重置窗口宽度
(defcustom neo-reset-size-on-open nil
  "*若为非 nil，每次打开文件时都会重置 NeoTree 的窗口宽度。"
  :type 'boolean
  :group 'neotree)

; 主题外观样式设置
(defcustom neo-theme 'classic
  "*文件树展示主题。
classic GUI模式图标；ascii 极简 +/- 符号模式；arrow 箭头符号；
nerd NERDTree 缩进风格；icons 使用 all-the-icons 矢量图标；
nerd-icons 使用 nerd-icons 矢量图标。"
  :group 'neotree
  :type '(choice (const classic)
          (const ascii)
          (const arrow)
          (const icons)
          (const nerd-icons)
          (const nerd)))

; 状态栏 Mode-Line 类型
(defcustom neo-mode-line-type 'neotree
  "*Mode-line 展示类型 (default, neotree, custom, none)。"
  :group 'neotree
  :type '(choice (const default)
          (const neotree)
          (const custom)
          (const none)))(defcustom neo-mode-line-custom-format nil
  "*自定义 Mode-line 的格式表达式。"
  :type 'sexp
  :group 'neotree)

; 智能定位当前文件
(defcustom neo-smart-open nil
  "*若为非 nil，每次打开 NeoTree 时会自动定位并高亮当前编辑的文件。"
  :type 'boolean
  :group 'neotree)

; 默认是否显示隐藏文件
(defcustom neo-show-hidden-files nil
  "*若为非 nil，默认显示隐藏文件（以点开头的文件）。"
  :type 'boolean
  :group 'neotree)

; 是否开启自动刷新
(defcustom neo-autorefresh nil
  "*若为非 nil，NeoTree 将在闲置时自动刷新目录结构。"
  :type 'boolean
  :group 'neotree)

; 侧边栏默认宽度
(defcustom neo-window-width 25
  "*NeoTree 侧边栏窗口的像素或字符宽度。"
  :type 'integer
  :group 'neotree)

; 窗口宽度是否锁定（防止 balance-windows 改变宽度）
(defcustom neo-window-fixed-size t
  "*若为非 nil，调整其他窗口大小时 NeoTree 宽度保持固定。"
  :type 'boolean
  :group 'neotree)

; 默认按键映射风格
(defcustom neo-keymap-style 'default
  "*NeoTree 的快捷键风格 (default 标准风格，concise 极简风格)。"
  :group 'neotree
  :type '(choice (const default)
          (const concise)))

; 当前工作目录 Header 样式
(defcustom neo-cwd-line-style 'text
  "*Header 展示样式：text 纯文本，button 可点击按钮。"
  :group 'neotree
  :type '(choice (const text)
          (const button)))

; 鼠标悬浮提示信息风格
(defcustom neo-help-echo-style 'default
  "鼠标移动到节点上时的悬浮提示类型。"
  :group 'neotree
  :type '(choice (const default)
          (const none)))

; 点击目录是否直接设为新 Root 根节点
(defcustom neo-click-changes-root nil
  "*若为非 nil，点击文件夹会直接将其设置为根目录，而不是展开。"
  :type 'boolean
  :group 'neotree)

; 光标是否自动对齐到文件名首字母
(defcustom neo-auto-indent-point nil
  "*若为非 nil，光标会自动移动到节点名称的第一个字母上。"
  :type 'boolean
  :group 'neotree)

; 匹配隐藏文件的正则表达式列表
(defcustom neo-hidden-regexp-list
  '("^\." "\.pyc$" "~$" "^#.*#$" "\.elc$" "\.o$")
  "*用于匹配和隐藏特定文件的正则表达式列表。"
  :type  '(repeat (choice regexp))
  :group 'neotree)

; 节点按下/进入时的 Hook 钩子
(defcustom neo-enter-hook nil
  "当进入/打开一个节点时执行的 Hook 函数列表。"
  :type 'hook
  :group 'neotree)

; Buffer 创建后的 Hook 钩子
(defcustom neo-after-create-hook nil
  "创建 NeoTree Buffer 后调用的 Hook。"
  :type 'hook
  :group 'neotree)

; 版本控制 (VC) 集成方式
(defcustom neo-vc-integration nil
  "是否以及如何集成 Git/VC 状态显示 (face 字体颜色，char 状态字符)。"
  :group 'neotree-vc
  :type '(set (const :tag "使用不同颜色高亮" face)
          (const :tag "使用不同字符表示" char)))

; VC 状态与指示字符映射表
(defcustom neo-vc-state-char-alist
  '((up-to-date       . ?\s)
    (edited           . ?E)
    (added            . ?+)
    (removed          . ?-)
    (missing          . ?!)
    (needs-merge      . ?M)
    (conflict         . ?!)
    (unlocked-changes . ?!)
    (needs-update     . ?U)
    (ignored          . ?\s)
    (user             . ?U)
    (unregistered     . ?\s)
    (nil              . ?\s))
  "版本控制状态到前缀指示字符的映射表。"
  :group 'neotree-vc
  :type '(alist :key-type symbol
          :value-type character))

; 各种交互操作的确认提示框配置
(defcustom neo-confirm-change-root 'yes-or-no-p
  "切换根目录时的二次确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-confirm-create-file 'yes-or-no-p
  "创建文件时的确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-confirm-create-directory 'yes-or-no-p
  "创建目录时的确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-confirm-delete-file 'yes-or-no-p
  "删除文件时的确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-confirm-delete-directory-recursively 'yes-or-no-p
  "递归删除非空目录时的确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-confirm-kill-buffers-for-files-in-directory 'yes-or-no-p
  "删除目录时，是否同时关闭关联 Buffer 的确认函数。"
  :type '(choice (function-item :tag "详细" yes-or-no-p)
          (function-item :tag "简短" y-or-n-p)
          (function-item :tag "关闭提示" off-p))
  :group 'neotree-confirmations)(defcustom neo-toggle-window-keep-p nil
  "切换 NeoTree 时，焦点是否保持在原主编辑窗口。"
  :type 'boolean
  :group 'neotree)(defcustom neo-force-change-root t
  "切换根目录时是否强制进行，不提示警告。"
  :type 'boolean
  :group 'neotree)(defcustom neo-filepath-sort-function 'string<
  "文件节点排序函数。"
  :type '(symbol (const :tag "默认字典序" string<)
          (const :tag "隐藏文件置底" neo-sort-hidden-last)
          (function :tag "自定义"))
  :group 'neotree)(defcustom neo-default-system-application "xdg-open"
  "用系统默认程序打开文件时的调用命令（Linux 上默认 xdg-open）。"
  :type 'string
  :group 'neotree)(defcustom neo-hide-cursor nil
  "是否隐藏 NeoTree 中的光标并开启行高亮。"
  :type 'boolean
  :group 'neotree)

; 视觉样式 / 颜色配置 (Faces)
(defface neo-banner-face
  '((((background dark)) (:foreground "lightblue" :weight bold))
    (t                   (:foreground "DarkMagenta")))
  "NeoTree 横幅标语的颜色样式。"
  :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-banner-face 'neo-banner-face)(defface neo-header-face
                                           '((((background dark)) (:foreground "White"))
                                             (t                   (:foreground "DarkMagenta")))
                                           "NeoTree Header 的颜色样式。"
                                           :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-header-face 'neo-header-face)(defface neo-root-dir-face
                                           '((((background dark)) (:foreground "lightblue" :weight bold))
                                             (t                   (:foreground "DarkMagenta")))
                                           "根目录节点的颜色样式。"
                                           :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-root-dir-face 'neo-root-dir-face)(defface neo-dir-link-face
                                               '((((background dark)) (:foreground "DeepSkyBlue"))
                                                 (t                   (:foreground "MediumBlue")))
                                               "目录节点与展开符 [+] 的颜色样式。"
                                               :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-dir-link-face 'neo-dir-link-face)(defface neo-file-link-face
                                               '((((background dark)) (:foreground "White"))
                                                 (t                   (:foreground "Black")))
                                               "普通文件节点的颜色样式。"
                                               :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-file-link-face 'neo-file-link-face)(defface neo-button-face
                                                 '((t (:underline nil)))
                                                 "按钮的样式。"
                                                 :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-button-face 'neo-button-face)(defface neo-expand-btn-face
                                           '((((background dark)) (:foreground "SkyBlue"))
                                             (t                   (:foreground "DarkCyan")))
                                           "展开/折叠符号按钮的颜色样式。"
                                           :group 'neotree :group 'font-lock-highlighting-faces)
(defvar neo-expand-btn-face 'neo-expand-btn-face)

; 各种 Git/VC 状态的颜色定义
(defface neo-vc-default-face
  '((((background dark)) (:foreground "White"))
    (t                   (:foreground "Black")))
  "未识别 VC 状态文件的颜色样式。"
  :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-default-face 'neo-vc-default-face)(defface neo-vc-user-face
                                                    '((t                   (:foreground "Red" :slant italic)))
                                                    "用户锁定的文件的颜色样式。"
                                                    :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-user-face 'neo-vc-user-face)(defface neo-vc-up-to-date-face
                                              '((((background dark)) (:foreground "LightGray"))
                                                (t                   (:foreground "DarkGray")))
                                              "未修改 (Up-to-date) 文件的颜色样式。"
                                              :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-up-to-date-face 'neo-vc-up-to-date-face)(defface neo-vc-edited-face
                                                          '((((background dark)) (:foreground "Magenta"))
                                                            (t                   (:foreground "DarkMagenta")))
                                                          "已被修改 (Edited) 文件的颜色样式。"
                                                          :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-edited-face 'neo-vc-edited-face)(defface neo-vc-needs-update-face
                                                  '((t                   (:underline t)))
                                                  "需要从远程更新 (Needs update) 文件的颜色样式。"
                                                  :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-needs-update-face 'neo-vc-needs-update-face)(defface neo-vc-needs-merge-face
                                                              '((((background dark)) (:foreground "Red1"))
                                                                (t                   (:foreground "Red3")))
                                                              "需要合并 (Needs merge) 文件的颜色样式。"
                                                              :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-needs-merge-face 'neo-vc-needs-merge-face)(defface neo-vc-unlocked-changes-face
                                                            '((t                   (:foreground "Red" :background "Blue")))
                                                            "未锁定变动文件的颜色样式。"
                                                            :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-unlocked-changes-face 'neo-vc-unlocked-changes-face)(defface neo-vc-added-face
                                                                      '((((background dark)) (:foreground "LightGreen"))
                                                                        (t                   (:foreground "DarkGreen")))
                                                                      "已暂存/新添加 (Added) 文件的颜色样式。"
                                                                      :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-added-face 'neo-vc-added-face)(defface neo-vc-removed-face
                                                '((t                    (:strike-through t)))
                                                "已删除 (Removed) 文件的删除线样式。"
                                                :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-removed-face 'neo-vc-removed-face)(defface neo-vc-conflict-face
                                                    '((((background dark)) (:foreground "Red1"))
                                                      (t                   (:foreground "Red3")))
                                                    "存在冲突 (Conflict) 文件的颜色样式。"
                                                    :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-conflict-face 'neo-vc-conflict-face)(defface neo-vc-missing-face
                                                      '((((background dark)) (:foreground "Red1"))
                                                        (t                   (:foreground "Red3")))
                                                      "丢失 (Missing) 文件的颜色样式。"
                                                      :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-missing-face 'neo-vc-missing-face)(defface neo-vc-ignored-face
                                                    '((((background dark)) (:foreground "DarkGrey"))
                                                      (t                   (:foreground "LightGray")))
                                                    "被 Git 忽略 (Ignored) 文件的颜色样式。"
                                                    :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-ignored-face 'neo-vc-ignored-face)(defface neo-vc-unregistered-face
                                                    nil
                                                    "未追踪 (Unregistered/Untracked) 文件的颜色样式。"
                                                    :group 'neotree-vc :group 'font-lock-highlighting-faces)
(defvar  neo-vc-unregistered-face 'neo-vc-unregistered-face)

; 内部变量 (Variables)

; 全局 NeoTree Buffer 句柄
(defvar neo-global--buffer nil)

; 全局 NeoTree 窗口句柄
(defvar neo-global--window nil)

; 自动刷新的定时器
(defvar neo-global--autorefresh-timer nil)

; Mode-line 的动态计算展示格式
(defvar neo-mode-line-format
  (list
   '(:eval
     (let* ((fname (neo-buffer--get-filename-current-line))
            (current (if fname fname neo-buffer--start-node))
            (parent (if fname (file-name-directory current) current))
            (nodes (neo-buffer--get-nodes parent))
            (dirs (car nodes))
            (files (cdr nodes))
            (ndirs (length dirs))
            (nfiles (length files))
            (index
             (when fname
               (1+ (if (file-directory-p current)
                       (neo-buffer--get-node-index current dirs)
                     (+ ndirs (neo-buffer--get-node-index current files)))))))
       (neo-mode-line--compute-format parent index ndirs nfiles))))
  "当前节点的 Mode-line 展示格式。")

; 局部变量：当前侧边栏展示的起点目录根节点
(defvar-local neo-buffer--start-node nil
  "当前窗口起始显示的目录根节点。")

; 局部变量：根节点所在的起始行数
(defvar-local neo-buffer--start-line nil
  "根节点起始行的索引。")

; 局部变量：用于恢复光标位置的点（路径 . 行号）
(defvar-local neo-buffer--cursor-pos (cons nil 1)
  "用于保存光标位置的点对。")

; 局部变量：记录上次滚动位置
(defvar-local neo-buffer--last-window-pos (cons nil 1)
  "保存 NeoTree 窗口的滚动位置。")

; 局部变量：是否显示隐藏节点
(defvar-local neo-buffer--show-hidden-file-p nil
  "记录是否在树中显示隐藏节点。")

; 局部变量：已被展开的目录节点列表
(defvar-local neo-buffer--expanded-node-list nil
  "当前已被展开的目录节点列表。")

; 局部变量：当前 Buffer 内所有节点的矢量模型
(defvar-local neo-buffer--node-list nil
  "当前 NeoTree Buffer 的节点模型。")

; 临时节点模型列表
(defvar-local neo-buffer--node-list-1 nil
  "当前 NeoTree Buffer 的临时节点模型。")

; 主模式定义与按键绑定 (Major mode & Keymaps)

; 文件节点的鼠标点击映射
(defvar neotree-file-button-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map [mouse-2]
      (neotree-make-executor
       :file-fn 'neo-open-file))
    map)
  "文件按钮节点的 Keymap。")

; 目录节点的鼠标点击映射
(defvar neotree-dir-button-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map [mouse-2]
      (neotree-make-executor :dir-fn  'neo-open-dir))
    map)
  "目录按钮节点的 Keymap。")

; NeoTree 主按键绑定表 (neotree-mode-map)
(defvar neotree-mode-map
  (let ((map (make-sparse-keymap)))

; TAB 键折叠/展开目录
    (define-key map (kbd "TAB")     (neotree-make-executor
                                     :dir-fn  'neo-open-dir))

; Enter 键打开文件或切换目录折叠
    (define-key map (kbd "RET")     (neotree-make-executor
                                     :file-fn 'neo-open-file
                                     :dir-fn  'neo-open-dir))

; | 键：垂直分屏打开文件
    (define-key map (kbd "|")       (neotree-make-executor
                                     :file-fn 'neo-open-file-vertical-split))

; - 键：水平分屏打开文件
    (define-key map (kbd "-")       (neotree-make-executor
                                     :file-fn 'neo-open-file-horizontal-split))

; a 键：配合 ace-window 选择窗口打开
    (define-key map (kbd "a")       (neotree-make-executor
                                     :file-fn 'neo-open-file-ace-window))

; d 键：在 Dired 模式中打开当前目录
    (define-key map (kbd "d")       (neotree-make-executor
                                     :dir-fn 'neo-open-dired))

; O 键：递归展开目录
    (define-key map (kbd "O")       (neotree-make-executor
                                     :dir-fn  'neo-open-dir-recursive))

; 空格键：快速预览文件内容
    (define-key map (kbd "SPC")     'neotree-quick-look)

; g 键：刷新文件树
    (define-key map (kbd "g")       'neotree-refresh)

; q 键：隐藏 NeoTree 侧边栏
    (define-key map (kbd "q")       'neotree-hide)

; p / C-p：移动到上一行
    (define-key map (kbd "p")       'neotree-previous-line)
    (define-key map (kbd "C-p")     'neotree-previous-line)

; n / C-n：移动到下一行
    (define-key map (kbd "n")       'neotree-next-line)
    (define-key map (kbd "C-n")     'neotree-next-line)

; A 键：最大化/恢复侧边栏宽度
    (define-key map (kbd "A")       'neotree-stretch-toggle)

; U 键：跳转到上一级父目录
    (define-key map (kbd "U")       'neotree-select-up-node)

; D 键：跳转到下一个展开的子节点
    (define-key map (kbd "D")       'neotree-select-down-node)

; H 键：切换隐藏文件的显隐
    (define-key map (kbd "H")       'neotree-hidden-file-toggle)

; S/s 键：在同级兄弟节点间上下跳跃
    (define-key map (kbd "S")       'neotree-select-previous-sibling-node)
    (define-key map (kbd "s")       'neotree-select-next-sibling-node)

; o 键：调用系统默认应用打开文件
    (define-key map (kbd "o")       'neotree-open-file-in-system-application)

; 禁用/重定向部分原生分屏快捷键
    (define-key map (kbd "C-x C-f") 'find-file-other-window)
    (define-key map (kbd "C-x 1")   'neotree-empty-fn)
    (define-key map (kbd "C-x 2")   'neotree-empty-fn)
    (define-key map (kbd "C-x 3")   'neotree-empty-fn)
    (define-key map (kbd "C-c C-f") 'find-file-other-window)

; C-c C-c：更改当前树的 Root 目录
    (define-key map (kbd "C-c C-c") 'neotree-change-root)
    (define-key map (kbd "C-c c")   'neotree-dir)
    (define-key map (kbd "C-c C-a")  'neotree-collapse-all)

; 根据配置按键风格载入文件操作指令（新建、删除、重命名、复制）
    (cond
     ((eq neo-keymap-style 'default)
      (define-key map (kbd "C-c C-n") 'neotree-create-node)
      (define-key map (kbd "C-c C-d") 'neotree-delete-node)
      (define-key map (kbd "C-c C-r") 'neotree-rename-node)
      (define-key map (kbd "C-c C-p") 'neotree-copy-node))
     ((eq neo-keymap-style 'concise)
      (define-key map (kbd "C") 'neotree-change-root)
      (define-key map (kbd "c") 'neotree-create-node)
      (define-key map (kbd "+") 'neotree-create-node)
      (define-key map (kbd "d") 'neotree-delete-node)
      (define-key map (kbd "r") 'neotree-rename-node)
      (define-key map (kbd "e") 'neotree-enter)))
    map)
  "NeoTree 模式的快捷键映射表。")

; 定义 neotree-mode 主模式（继承自 special-mode）
(define-derived-mode neotree-mode special-mode "NeoTree"
  "用于在文本模式下显示目录树的主模式。"
  (setq indent-tabs-mode nil            
; 禁用 Tab，纯空格缩进
        buffer-read-only t              
; Buffer 默认只读
        truncate-lines -1               
; 开启长行截断
        neo-buffer--show-hidden-file-p neo-show-hidden-files)
  (when neo-hide-cursor
    (progn
      (setq cursor-type nil)            
; 隐藏光标
      (hl-line-mode +1)))               
; 开启整行高亮

; 状态栏配置
  (pcase neo-mode-line-type
    (neotree (setq-local mode-line-format neo-mode-line-format) (add-hook 'post-command-hook 'force-mode-line-update nil t)) (none (setq-local mode-line-format nil))
    (`custom
     (setq-local mode-line-format neo-mode-line-custom-format)
     (add-hook 'post-command-hook 'force-mode-line-update nil t))
    (_ nil))

; 禁用自动缩进模式 (electric-indent-mode) 影响
  (if (fboundp 'electric-indent-local-mode)
      (electric-indent-local-mode -1)
    (add-hook 'electric-indent-functions
              (lambda (arg) 'no-indent) nil 'local))
  (when neo-auto-indent-point
    (add-hook 'post-command-hook 'neo-hook--node-first-letter nil t)))

; 全局方法 (Global methods)

; 检查 NeoTree 窗口是否存在
(defun neo-global--window-exists-p ()
  "如果 NeoTree 窗口已存在且有效则返回非 nil。"
  (and (not (null (window-buffer neo-global--window)))
       (eql (window-buffer neo-global--window) (neo-global--get-buffer))))

; 聚焦选中 NeoTree 窗口
(defun neo-global--select-window ()
  "选中 NeoTree 侧边栏窗口。"
  (interactive)
  (let ((window (neo-global--get-window t)))
    (select-window window)))

; 获取 NeoTree 窗口（如果不存在可选择自动创建）
(defun neo-global--get-window (&optional auto-create-p)
  "获取 NeoTree 窗口句柄；若不存在且 AUTO-CREATE-P 为非 nil，则创建并返回它。"
  (unless (neo-global--window-exists-p)
    (setf neo-global--window nil))
  (when (and (null neo-global--window)
             auto-create-p)
    (setq neo-global--window
          (neo-global--create-window)))
  neo-global--window)

; 默认的窗口弹出逻辑：调用原生的 side-window 技术
(defun neo-default-display-fn (buffer _alist)
  "使用 side-window 技术在主窗口的左侧或右侧弹出显示 NeoTree。"
  (let ((window-pos (if (eq neo-window-position 'left) 'left 'right)))
    (display-buffer-in-side-window buffer `((side . ,window-pos)))))

; 创建全局侧边栏窗口
(defun neo-global--create-window ()
  "创建 NeoTree 侧边栏窗口。"
  (let ((window nil)
        (buffer (neo-global--get-buffer t)))
    (setq window
          (select-window
           (display-buffer buffer neo-display-action)))
    (neo-window--init window buffer)
    (neo-global--attach)
    (neo-global--reset-width)
    window))

; 获取或新建 NeoTree Buffer
(defun neo-global--get-buffer (&optional init-p)
  "获取全局 NeoTree Buffer 句柄。"
  (unless (equal (buffer-name neo-global--buffer)
                 neo-buffer-name)
    (setf neo-global--buffer nil))
  (when (and init-p
             (null neo-global--buffer))
    (save-window-excursion
      (setq neo-global--buffer
            (neo-buffer--create))))
  neo-global--buffer)

; 判断路径是否包含在当前根目录内
(defun neo-global--file-in-root-p (path)
  "判断 PATH 是否位于当前根目录下方。"
  (neo-global--with-buffer
    (and (not (null neo-buffer--start-node))
         (neo-path--file-in-directory-p path neo-buffer--start-node))))

; 检查 NeoTree 窗口是否与其他窗口同存
(defun neo-global--alone-p ()
  "检查全局 NeoTree 窗口是否与其他窗口并存。"
  (let ((windows (window-list)))
    (and (= (length windows)
            2)
         (member neo-global--window windows))))

; 执行自动刷新
(defun neo-global--do-autorefresh ()
  "在后台定时触发的自动刷新函数。"
  (interactive)
  (when (and neo-autorefresh (neo-global--window-exists-p)
             (buffer-file-name))
    (neotree-refresh t)))

; 打开 NeoTree 窗口
(defun neo-global--open ()
  "显示 NeoTree 侧边栏窗口。"
  (let ((valid-start-node-p nil))
    (neo-global--with-buffer
      (setf valid-start-node-p (neo-buffer--valid-start-node-p)))
    (if (not valid-start-node-p)
        (neo-global--open-dir (neo-path--get-working-dir))
      (neo-global--get-window t))))

; 打开侧边栏并设置特定的根目录
(defun neo-global--open-dir (path)
  "显示 NeoTree 窗口，并将 Root 路径更改为 PATH。"
  (neo-global--get-window t)
  (neo-global--with-buffer
    (neo-buffer--change-root path)))

; 打开侧边栏并自动查找高亮文件
(defun neo-global--open-and-find (path)
  "在 NeoTree 中快速定位并高亮指定的 PATH 节点。"
  (let ((npath path)
        root-dir)
    (when (null npath)
      (throw 'invalid-path "用于选择的路径无效。"))
    (setq root-dir (if (file-directory-p npath)
                       npath (neo-path--updir npath)))
    (when (or (not (neo-global--window-exists-p))
              (not (neo-global--file-in-root-p npath)))
      (neo-global--open-dir root-dir))
    (neo-global--with-window
      (neo-buffer--select-file-node npath t))))

; 决定打开文件时在哪个目标窗口展示
(defun neo-global--select-mru-window (arg)
  "当打开文件节点时，寻找或创建一个合适的目标编辑窗口。"
  (when (eq (safe-length (window-list)) 1)
    (neo-buffer--with-resizable-window
     (split-window-horizontally)))
  (when neo-reset-size-on-open
    (neo-global--when-window
      (neo-window--zoom 'minimize)))

; 根据前缀参数或逻辑分配选中的窗口
  (cond

; 配合 winum 插件窗口编号机制选择窗口
   ((and (integerp arg)
         (bound-and-true-p winum-mode)
         (fboundp 'winum-select-window-by-number))
    (winum-select-window-by-number arg))

; 配合 window-numbering 插件选择窗口
   ((and (integerp arg)
         (boundp 'window-numbering-mode)
         (symbol-value window-numbering-mode)
         (fboundp 'select-window-by-number))
    (select-window-by-number arg))

; 使用 ace-window 交互式选择窗口
   ((and (stringp arg) (string= arg "a")
         (fboundp 'ace-select-window))
    (ace-select-window))

; 垂直分屏打开新窗口
   ((and (stringp arg) (string= arg "|"))
    (select-window (get-mru-window))
    (split-window-right)
    (windmove-right))

; 水平分屏打开新窗口
   ((and (stringp arg) (string= arg "-"))
    (select-window (get-mru-window))
    (split-window-below)
    (windmove-down)))

; 在最近使用的活动窗口中打开节点
  (select-window (get-mru-window)))

; 解绑/清理 NeoTree 全局变量与定时器
(defun neo-global--detach ()
  "解除全局 NeoTree Buffer 的绑状态。"
  (when neo-global--autorefresh-timer
    (cancel-timer neo-global--autorefresh-timer))
  (neo-global--with-buffer
    (neo-buffer--unlock-width))
  (setq neo-global--buffer nil)
  (setq neo-global--window nil))

; 挂载/初始化 NeoTree 全局 Buffer
(defun neo-global--attach ()
  "挂载全局 NeoTree Buffer。"
  (when neo-global--autorefresh-timer
    (cancel-timer neo-global--autorefresh-timer))
  (when neo-autorefresh
    (setq neo-global--autorefresh-timer
          (run-with-idle-timer 2 10 'neo-global--do-autorefresh)))
  (setq neo-global--buffer (get-buffer neo-buffer-name))
  (setq neo-global--window (get-buffer-window
                            neo-global--buffer))
  (neo-global--with-buffer
    (neo-buffer--lock-width))
  (run-hook-with-args 'neo-after-create-hook '(window)))

; 设置侧边栏绝对宽度
(defun neo-global--set-window-width (width)
  "将 NeoTree 窗口宽度设置为 WIDTH。"
  (neo-global--with-window
    (neo-buffer--with-resizable-window
     (neo-util--set-window-width (selected-window) width))))

; 重置窗口宽度为默认配置的宽度
(defun neo-global--reset-width ()
  "重置 NeoTree 窗口宽度为 neo-window-width。"
  (neo-global--set-window-width neo-window-width))

; Advice 钩子通知 (Advices)

; 解决拖拽垂直边框时因锁定宽度导致的失效问题
(defadvice mouse-drag-vertical-line
    (around neotree-drag-vertical-line (start-event) activate)
  "允许通过鼠标拖拽边框来改变侧边栏宽度。"
  (neo-buffer--with-resizable-window
   ad-do-it))

; 修复 balance-windows (重新平分窗口尺寸) 破坏侧边栏宽度的 bug
(defadvice balance-windows
    (around neotree-balance-windows activate)
  "防止 balance-windows 命令改变 NeoTree 侧边栏的固定宽度。"
  (if (neo-global--window-exists-p)
      (let (old-width)
        (neo-global--with-window
          (setq old-width (window-width)))
        (neo-buffer--with-resizable-window
         ad-do-it)
        (neo-global--with-window
          (neo-global--set-window-width old-width)))
    ad-do-it))

; 适配 popwin 弹窗插件，防止冲突
(eval-after-load 'popwin
  '(progn
     (defadvice popwin:create-popup-window
         (around neotree/popwin-popup-buffer activate)
       (let ((neo-exists-p (neo-global--window-exists-p)))
         (when neo-exists-p
           (neo-global--detach))
         ad-do-it
         (when neo-exists-p
           (neo-global--attach)
           (neo-global--reset-width)))) (defadvice popwin:close-popup-window
       (around neotree/popwin-close-popup-window activate)
       (let ((neo-exists-p (neo-global--window-exists-p)))
         (when neo-exists-p
           (neo-global--detach))
         ad-do-it
         (when neo-exists-p
           (neo-global--attach)
           (neo-global--reset-width))))))

; 钩子函数 (Hooks)

; 移动光标时自动跳到节点名称的首字母
(defun neo-hook--node-first-letter ()
  "将光标移动到当前节点名称的第一位字母上。"
  (when (or (eq this-command 'next-line)
            (eq this-command 'previous-line))
    (neo-point-auto-indent)))

; 实用工具方法 (Util methods)

; 列表过滤工具函数
(defun neo-util--filter (condp lst)
  "对 LST 的元素应用谓词 CONDP，保留返回非 nil 的项。"
  (delq nil
        (mapcar (lambda (x) (and (funcall condp x) x)) lst)))

; 在列表中查找元素
(defun neo-util--find (where which)
  "在列表 WHERE 中查找匹配谓词 WHICH 的第一个元素。"
  (catch 'found
    (dolist (elt where)
      (when (funcall which elt)
        (throw 'found elt)))
    nil))

; 清除字符串中的换行符
(defun neo-util--make-printable-string (string)
  "剥离 STRING 中的换行符。"
  (replace-regexp-in-string "\n" "" string))

; 深度遍历读取目录下的文件和子目录
(defun neo-util--walk-dir (path)
  "获取 PATH 下的所有子目录与文件。"
  (let* ((full-path (neo-path--file-truename path)))
    (condition-case nil
        (directory-files
         path 'full directory-files-no-dot-files-regexp)
      ('file-error
       (message "读取目录失败: %S" path)
       nil))))

; 隐藏文件过滤函数
(defun neo-util--hidden-path-filter (node)
  "如果 NODE 匹配 neo-hidden-regexp-list 则予以过滤（返回 nil）。"
  (if (not neo-buffer--show-hidden-file-p)
      (let ((shortname (neo-path--file-short-name node)))
        (null (neo-util--filter
               (lambda (x) (not (null (string-match-p x shortname))))
               neo-hidden-regexp-list)))
    node))

; 移除左侧空白字符
(defun neo-str--trim-left (s)
  "移除字符串 S 开头的空白字符。"
  (if (string-match "\`[ \t\n\r]+" s)
      (replace-match "" t t s)
    s))

; 移除右侧空白字符
(defun neo-str--trim-right (s)
  "移除字符串 S 结尾的空白字符。"
  (if (string-match "[ \t\n\r]+\'" s)
      (replace-match "" t t s)
    s))

; 移除首尾空白字符
(defun neo-str--trim (s)
  "移除字符串 S 两端的空白字符。"
  (neo-str--trim-left (neo-str--trim-right s)))

; 展开路径名称
(defun neo-path--expand-name (path &optional current-dir)
  (expand-file-name (or (if (file-name-absolute-p path) path)
                        (let ((r-path path))
                          (setq r-path (substitute-in-file-name r-path))
                          (setq r-path (expand-file-name r-path current-dir))
                          r-path))))

; 截断超长路径
(defun neo-path--shorten (path len)
  "将超长 PATH 截断为适应窗口宽度的 LEN 长度。"
  (let ((result
         (if (> (length path) len)
             (concat "<" (substring path (- (- len 2))))
           path)))
    (when result
      (decode-coding-string result 'utf-8))))

; 插入可点击的切换根目录按钮
(defun neo-path--insert-chroot-button (label path face)
  (insert-button
   label
   'action '(lambda (x) (neotree-change-root))
   'follow-link t
   'face face
   'neo-full-path path))

; 插入响应点击的面包屑 Header 按钮
(defun neo-path--insert-header-buttonized (path)
  "把 PATH 转换为可点击面包屑按钮列表并插入 Header。"
  (let* ((dirs (reverse (cl-maplist 'identity (reverse (split-string path "/" :omitnulls)))))
         (last (car-safe (car-safe (last dirs)))))
    (neo-path--insert-chroot-button "/" "/" 'neo-root-dir-face)
    (dolist (dir dirs)
      (if (string= (car dir) last)
          (neo-buffer--insert-with-face last 'neo-root-dir-face)
        (neo-path--insert-chroot-button
         (concat (car dir) "/")
         (apply 'neo-path--join (cons "/" (reverse dir)))
         'neo-root-dir-face))))
  (when (> (current-column) (window-body-width))
    (forward-char (- (window-body-width)))
    (delete-region (point-at-bol) (point))
    (let* ((button (button-at (point)))
           (path (if button (overlay-get button 'neo-full-path) "/")))
      (neo-path--insert-chroot-button "<" path 'neo-root-dir-face))
    (end-of-line)))

; 获取父级目录路径
(defun neo-path--updir (path)
  (let ((r-path (neo-path--expand-name path)))
    (if (and (> (length r-path) 0)
             (equal (substring r-path -1) "/"))
        (setq r-path (substring r-path 0 -1)))
    (if (eq (length r-path) 0)
        (setq r-path "/"))
    (directory-file-name
     (file-name-directory r-path))))

; 拼接路径 (类似于 Python 的 os.path.join)
(defun neo-path--join (root &rest dirs)
  "拼接 ROOT 以及后面的 DIRS 目录路径。"
  (or (if (not dirs) root)
      (let ((tdir (car dirs))
            (epath nil))
        (setq epath
              (or (if (equal tdir ".") root)
                  (if (equal tdir "..") (neo-path--updir root))
                  (neo-path--expand-name tdir root)))
        (apply 'neo-path--join
               epath
               (cdr dirs)))))

; 获取文件的短文件名 (不含目录)
(defun neo-path--file-short-name (file)
  "获取 FILE 的文件名。"
  (or (if (string= file "/") "/")
      (neo-util--make-printable-string (file-name-nondirectory (directory-file-name file)))))

; 获取文件的绝对真实路径 (解析软链接)
(defun neo-path--file-truename (path)
  (let ((rlt (file-truename path)))
    (if (not (null rlt))
        (progn
          (if (and (file-directory-p rlt)
                   (> (length rlt) 0)
                   (not (equal (substring rlt -1) "/")))
              (setq rlt (concat rlt "/")))
          rlt)
      nil)))

; 判断目录内是否存在文件或子目录
(defun neo-path--has-subfile-p (dir)
  "判断 DIR 目录下是否存在文件或子目录。"
  (and (file-exists-p dir)
       (file-directory-p dir)
       (neo-util--walk-dir dir)
       t))

; 规范化并匹配目录路径
(defun neo-path--match-path-directory (path)
  (let ((true-path (neo-path--file-truename path))
        (rlt-path nil))
    (setq rlt-path
          (catch 'rlt
            (if (file-directory-p true-path)
                (throw 'rlt true-path))
            (setq true-path
                  (file-name-directory true-path))
            (if (file-directory-p true-path)
                (throw 'rlt true-path))))
    (if (not (null rlt-path))
        (setq rlt-path (neo-path--join "." rlt-path "./")))
    rlt-path))

; 获取当前 Buffer 对应的工作目录
(defun neo-path--get-working-dir ()
  "返回当前 Buffer 的工作目录。"
  (file-name-as-directory (file-truename default-directory)))

; 剥离路径末尾多余的斜杠
(defun neo-path--strip (path)
  "清理 PATH 结尾的尾随斜杠与空格。"
  (let* ((rlt (neo-str--trim path))
         (pos (string-match "[\\/]+\'" rlt)))
    (when pos
      (setq rlt (replace-match "" t t rlt))
      (when (eq (length rlt) 0)
        (setq rlt "/")))
    rlt))

; 比较两条路径是否等价
(defun neo-path--path-equal-p (path1 path2)
  "如果 PATH1 与 PATH2 指向同一路径则返回非 nil。"
  (string-equal (neo-path--strip path1)
                (neo-path--strip path2)))

; 比较两个文件对象是否完全一致
(defun neo-path--file-equal-p (file1 file2)
  "如果 FILE1 与 FILE2 为同一文件则返回非 nil。"
  (unless (or (null file1)
              (null file2))
    (let ((nfile1 (neo-path--strip file1))
          (nfile2 (neo-path--strip file2)))
      (file-equal-p nfile1 nfile2))))

; 检查文件是否位于特定目录下
(defun neo-path--file-in-directory-p (file dir)
  "检查 FILE 是否属于 DIR 目录或其子目录下。"
  (let ((nfile (neo-path--strip file))
        (ndir (neo-path--strip dir)))
    (setq ndir (concat ndir "/"))
    (file-in-directory-p nfile ndir)))

; 强行关闭指定路径及其所有子路径打开的 Buffer
(defun neo-util--kill-buffers-for-path (path)
  "关闭访问 PATH 内文件的所有 Emacs Buffer。"
  (let ((buffer (find-buffer-visiting path)))
    (when buffer
      (kill-buffer buffer)))
  (dolist (filename (directory-files path t directory-files-no-dot-files-regexp))
    (let ((buffer (find-buffer-visiting filename)))
      (when buffer
        (kill-buffer buffer))
      (when (and
             (file-directory-p filename)
             (neo-path--has-subfile-p filename))
        (neo-util--kill-buffers-for-path filename)))))

; 设置选定窗口的字符列数宽度
(defun neo-util--set-window-width (window n)
  "调整 WINDOW 的宽度为 N 列。"
  (let ((w (max n window-min-width)))
    (unless (null window)
      (if (> (window-width) w)
          (shrink-window-horizontally (- (window-width) w))
        (if (< (window-width) w)
            (enlarge-window-horizontally (- w (window-width))))))))

; 光标自动对齐到文件名开头
(defun neo-point-auto-indent ()
  "将光标放在当前节点的第一个非空字符上。"
  (when (neo-buffer--get-filename-current-line)
    (beginning-of-line 1)
    (re-search-forward "[^-\s+]" (line-end-position 1) t)
    (backward-char 1)))

; 强制返回 t 的空提示判断函数
(defun off-p (msg)
  "忽略参数，直接返回 t。"
  t)

; 排序逻辑：隐藏文件排在最后
(defun neo-sort-hidden-last (x y)
  "按字母排序，但将隐藏文件统一排在最底部。"
  (let ((x-hidden (neo-filepath-hidden-p x))
        (y-hidden (neo-filepath-hidden-p y)))
    (cond
     ((and x-hidden (not y-hidden))
      nil)
     ((and (not x-hidden) y-hidden)
      t)
     (t
      (string< x y)))))

; 判断某节点是否属于隐藏路径
(defun neo-filepath-hidden-p (node)
  "判断 NODE 是否属于被隐藏的节点。"
  (let ((shortname (neo-path--file-short-name node)))
    (neo-util--filter
     (lambda (x) (not (null (string-match-p x shortname))))
     neo-hidden-regexp-list)))

; 从 Projectile 插件中获取未保存的 Buffer 列表
(defun neo-get-unsaved-buffers-from-projectile ()
  "获取 Projectile 项目中所有未保存文件的 Buffer 路径列表。"
  (interactive)
  (let ((rlist '())
        (rtag t))
    (condition-case nil
        (projectile-project-buffers)
      (error (setq rtag nil)))
    (when (and rtag (fboundp 'projectile-project-buffers))
      (dolist (buf (projectile-project-buffers))
        (with-current-buffer buf
          (if (and (buffer-modified-p) buffer-file-name)
              (setq rlist (cons (buffer-file-name) rlist))
            ))))
    rlist))

; Buffer 核心渲染逻辑 (Buffer methods)

; 换行并移动光标到行首
(defun neo-buffer--newline-and-begin ()
  "插入新行并将光标拉回行首。"
  (newline)
  (beginning-of-line))

; 加载与创建图像图标
(defun neo-buffer--get-icon (name)
  "根据图标名称 NAME 构建并返回 Image 对象。"
  (let ((icon-path (neo-path--join neo-dir "icons"))
        image)
    (setq image (create-image
                 (neo-path--join icon-path (concat name ".xpm"))
                 'xpm nil :ascent 'center :mask '(heuristic t)))
    image))

; 为 nerd-icons 插件构建带展开箭头的目录图标
(defun neo--nerd-icons-icon-for-dir-with-chevron (dir &optional chevron padding)
  (let ((icon (nerd-icons-icon-for-dir dir))
        (chevron (if chevron (nerd-icons-octicon (format "nf-oct-chevron_%s" chevron) :height 0.8 :v-adjust -0.1) ""))
        (padding (or padding "\t")))
    (format "%s%s%s%s%s" padding chevron padding icon padding)))

; 根据 theme 主题插入对应的展开/折叠标志符号
(defun neo-buffer--insert-fold-symbol (name &optional node-name)
  "根据当前主题插入目录展开、折叠或叶节点图标。"
  (let ((n-insert-image (lambda (n)
                          (insert-image (neo-buffer--get-icon n))))
        (n-insert-symbol (lambda (n)
                           (neo-buffer--insert-with-face
                            n 'neo-expand-btn-face))))
    (cond
     ((and (display-graphic-p) (equal neo-theme 'classic))
      (or (and (equal name 'open)  (funcall n-insert-image "open"))
          (and (equal name 'close) (funcall n-insert-image "close"))
          (and (equal name 'leaf)  (funcall n-insert-image "leaf"))))
     ((equal neo-theme 'arrow)
      (or (and (equal name 'open)  (funcall n-insert-symbol "▾"))
          (and (equal name 'close) (funcall n-insert-symbol "▸"))))
     ((equal neo-theme 'nerd)
      (or (and (equal name 'open)  (funcall n-insert-symbol "▾ "))
          (and (equal name 'close) (funcall n-insert-symbol "▸ "))
          (and (equal name 'leaf)  (funcall n-insert-symbol "  "))))
     ((and (display-graphic-p) (equal neo-theme 'icons))
      (unless (require 'all-the-icons nil 'noerror)
        (error "未安装 all-the-icons 插件"))
      (setq-local tab-width 1)
      (or (and (equal name 'open)  (insert (all-the-icons-icon-for-dir-with-chevron (directory-file-name node-name) "down")))
          (and (equal name 'close) (insert (all-the-icons-icon-for-dir-with-chevron (directory-file-name node-name) "right")))
          (and (equal name 'leaf)  (insert (format "\t\t\t%s\t" (all-the-icons-icon-for-file node-name))))))
     ((equal neo-theme 'nerd-icons)
      (unless (require 'nerd-icons nil 'noerror)
        (error "未安装 nerd-icons 插件"))
      (setq-local tab-width 1)
      (or (and (equal name 'open)  (insert (neo--nerd-icons-icon-for-dir-with-chevron (directory-file-name node-name) "down")))
          (and (equal name 'close) (insert (neo--nerd-icons-icon-for-dir-with-chevron (directory-file-name node-name) "right")))
          (and (equal name 'leaf)  (insert (format "\t\t\t%s\t" (nerd-icons-icon-for-file node-name))))))
     (t
      (or (and (equal name 'open)  (funcall n-insert-symbol "- "))
          (and (equal name 'close) (funcall n-insert-symbol "+ ")))))))

; 保存当前光标与滚动位置
(defun neo-buffer--save-cursor-pos (&optional node-path line-pos)
  "保存当前侧边栏的光标位置。"
  (let ((cur-node-path nil)
        (cur-line-pos nil)
        (ws-wind (selected-window))
        (ws-pos (window-start)))
    (setq cur-node-path (if node-path
                            node-path
                          (neo-buffer--get-filename-current-line)))
    (setq cur-line-pos (if line-pos
                           line-pos
                         (line-number-at-pos)))
    (setq neo-buffer--cursor-pos (cons cur-node-path cur-line-pos))
    (setq neo-buffer--last-window-pos (cons ws-wind ws-pos))))

; 还原跳回保存的光标位置
(defun neo-buffer--goto-cursor-pos ()
  "恢复跳转到先前保存的光标节点位置。"
  (let ((line-pos nil)
        (node (car neo-buffer--cursor-pos))
        (line-pos (cdr neo-buffer--cursor-pos))
        (ws-wind (car neo-buffer--last-window-pos))
        (ws-pos (cdr neo-buffer--last-window-pos)))
    (catch 'line-pos-founded
      (unless (null node)
        (setq line-pos 0)
        (mapc
         (lambda (x)
           (setq line-pos (1+ line-pos))
           (unless (null x)
             (when (neo-path--path-equal-p x node)
               (throw 'line-pos-founded line-pos))))
         neo-buffer--node-list))
      (setq line-pos (cdr neo-buffer--cursor-pos))
      (throw 'line-pos-founded line-pos))

; 跳转到目标行
    (goto-char (point-min))
    (neo-buffer--forward-line (1- line-pos))

; 恢复视口滚动
    (when (equal (selected-window) ws-wind)
      (set-window-start ws-wind ws-pos t))))

; 清空内部节点数组缓存
(defun neo-buffer--node-list-clear ()
  "清空 Buffer 节点的索引缓存数组。"
  (setq neo-buffer--node-list nil))

; 向 Buffer 节点映射表中记录路径
(defun neo-buffer--node-list-set (line-num path)
  "将 LINE-NUM 行与 PATH 路径绑定并存入 neo-buffer--node-list。"
  (let ((node-list-length (length neo-buffer--node-list))
        (node-index line-num))
    (when (null node-index)
      (setq node-index (line-number-at-pos)))
    (when (< node-list-length node-index)
      (setq neo-buffer--node-list
            (vconcat neo-buffer--node-list
                     (make-vector (- node-index node-list-length) nil))))
    (aset neo-buffer--node-list (1- node-index) path))
  neo-buffer--node-list)

; 带有特定颜色 Face 样式插入文本
(defun neo-buffer--insert-with-face (content face)
  "按 FACE 样式把 CONTENT 字符串写入 Buffer。"
  (let ((pos-start (point)))
    (insert content)
    (set-text-properties pos-start
                         (point)
                         (list 'face face))))

; 判断当前的起始根节点路径是否合法且可读
(defun neo-buffer--valid-start-node-p ()
  "检查当前根节点路径是否依然合法存在。"
  (and (not (null neo-buffer--start-node))
       (file-accessible-directory-p neo-buffer--start-node)))

; 初始化并创建底层 Buffer 对象
(defun neo-buffer--create ()
  "创建并初始化 NeoTree Buffer。"
  (switch-to-buffer
   (generate-new-buffer-name neo-buffer-name))
  (neotree-mode)

; 在侧边栏中禁用行号插件 linum-mode
  (when (and (boundp 'linum-mode)
             (not (null linum-mode)))
    (linum-mode -1))
  (setq-local helm-split-window-inside-p t)
  (current-buffer))

; 插入顶部 Banner 标语
(defun neo-buffer--insert-banner ()
  (unless (null neo-banner-message)
    (let ((start (point)))
      (insert neo-banner-message)
      (set-text-properties start (point) '(face neo-banner-face)))
    (neo-buffer--newline-and-begin)))

; 渲染 Root 根节点项
(defun neo-buffer--insert-root-entry (node)
  (neo-buffer--node-list-set nil node)
  (cond ((eq neo-cwd-line-style 'button)
         (neo-path--insert-header-buttonized node))
        (t
         (neo-buffer--insert-with-face (neo-path--shorten node (window-body-width))
                                       'neo-root-dir-face)))
  (neo-buffer--newline-and-begin)
  (when neo-show-updir-line
    (neo-buffer--insert-fold-symbol 'close node)
    (insert-button ".."
                   'action '(lambda (x) (neotree-change-root))
                   'follow-link t
                   'face neo-dir-link-face
                   'neo-full-path (neo-path--updir node))
    (neo-buffer--newline-and-begin)))

; 计算悬浮提示消息文本
(defun neo-buffer--help-echo-message (node-name)
  (cond
   ((eq neo-help-echo-style 'default)
    (if (<= (+ (current-column) (string-width node-name))
            neo-window-width)
        nil
      node-name))
   (t nil)))

; 渲染插入一个目录节点
(defun neo-buffer--insert-dir-entry (node depth expanded)
  (let ((node-short-name (neo-path--file-short-name node)))
    (insert-char ?\s (* (- depth 1) 2)) 
; 根据深度写入两倍空格层级缩进
    (when (memq 'char neo-vc-integration)
      (insert-char ?\s 2))
    (neo-buffer--insert-fold-symbol
     (if expanded 'open 'close) node)
    (insert-button (if neo-show-slash-for-folder (concat node-short-name "/") node-short-name)
                   'follow-link t
                   'face neo-dir-link-face
                   'neo-full-path node
                   'keymap neotree-dir-button-keymap
                   'help-echo (neo-buffer--help-echo-message node-short-name))
    (neo-buffer--node-list-set nil node)
    (neo-buffer--newline-and-begin)))

; 渲染插入一个文件节点
(defun neo-buffer--insert-file-entry (node depth)
  (let ((node-short-name (neo-path--file-short-name node))
        (vc (when neo-vc-integration (neo-vc-for-node node))))
    (insert-char ?\s (* (- depth 1) 2)) 
; 层级缩进
    (when (memq 'char neo-vc-integration)
      (insert-char (car vc))
      (insert-char ?\s))
    (neo-buffer--insert-fold-symbol 'leaf node-short-name)
    (insert-button node-short-name
                   'follow-link t
                   'face (if (memq 'face neo-vc-integration)
                             (cdr vc)
                           neo-file-link-face)
                   'neo-full-path node
                   'keymap neotree-file-button-keymap
                   'help-echo (neo-buffer--help-echo-message node-short-name))
    (neo-buffer--node-list-set nil node)
    (neo-buffer--newline-and-begin)))

; 获取并计算节点对应的 VC (Git) 状态颜色与指示符号
(defun neo-vc-for-node (node)
  (let* ((backend (ignore-errors
                    (vc-responsible-backend node)))
         (vc-state (when backend (vc-state node backend))))
    (cons (cdr (assoc vc-state neo-vc-state-char-alist))
          (cl-case vc-state
            (up-to-date       neo-vc-up-to-date-face)
            (edited           neo-vc-edited-face)
            (needs-update     neo-vc-needs-update-face)
            (needs-merge      neo-vc-needs-merge-face)
            (unlocked-changes neo-vc-unlocked-changes-face)
            (added            neo-vc-added-face)
            (removed          neo-vc-removed-face)
            (conflict         neo-vc-conflict-face)
            (missing          neo-vc-missing-face)
            (ignored          neo-vc-ignored-face)
            (unregistered     neo-vc-unregistered-face)
            (user             neo-vc-user-face)
            (otherwise        neo-vc-default-face)))))

; 递归读取并按规则排序 PATH 路径下的子文件与目录
(defun neo-buffer--get-nodes (path)
  (let* ((nodes (neo-util--walk-dir path))
         (comp neo-filepath-sort-function)
         (nodes (neo-util--filter 'neo-util--hidden-path-filter nodes)))
    (cons (sort (neo-util--filter 'file-directory-p nodes) comp)
          (sort (neo-util--filter #'(lambda (f) (not (file-directory-p f))) nodes) comp))))

; 查找节点在列表中的索引编号
(defun neo-buffer--get-node-index (node nodes)
  "返回 NODE 在 NODES 集合中的索引位置。"
  (let ((i 0)
        (l (length nodes))
        (cur (car nodes))
        (rest (cdr nodes)))
    (while (and cur (not (equal cur node)))
      (setq i (1+ i))
      (setq cur (car rest))
      (setq rest (cdr rest)))
    (if (< i l) i)))

; 检查目录节点是否处于展开状态
(defun neo-buffer--expanded-node-p (node)
  "判断 NODE 目录当前是否已展开。"
  (neo-util--to-bool
   (neo-util--find
    neo-buffer--expanded-node-list
    #'(lambda (x) (equal x node)))))

; 设置节点的折叠/展开状态标志
(defun neo-buffer--set-expand (node do-expand)
  "设置 NODE 的展开状态为 DO-EXPAND (t 表示展开，nil 表示折叠)。"
  (if (not do-expand)
      (setq neo-buffer--expanded-node-list
            (neo-util--filter
             #'(lambda (x) (not (equal node x)))
             neo-buffer--expanded-node-list))
    (push node neo-buffer--expanded-node-list))
  do-expand)

; 切换展开/折叠状态
(defun neo-buffer--toggle-expand (node)
  (neo-buffer--set-expand node (not (neo-buffer--expanded-node-p node))))

; 递归遍历并渲染构建整棵目录树
(defun neo-buffer--insert-tree (path depth)
  (if (eq depth 1)
      (neo-buffer--insert-root-entry path))
  (let* ((contents (neo-buffer--get-nodes path))
         (nodes (car contents))
         (leafs (cdr contents))
         (default-directory path))
    (dolist (node nodes)
      (let ((expanded (neo-buffer--expanded-node-p node)))
        (neo-buffer--insert-dir-entry
         node depth expanded)
        (if expanded (neo-buffer--insert-tree (concat node "/") (+ depth 1)))))
    (dolist (leaf leafs)
      (neo-buffer--insert-file-entry leaf depth))))

; 刷新 NeoTree 视图 Buffer
(defun neo-buffer--refresh (save-pos-p &optional non-neotree-buffer)
  "重新构建并刷新整个 NeoTree 侧边栏内容。"
  (let ((start-node neo-buffer--start-node))
    (unless start-node
      (setq start-node default-directory))
    (neo-buffer--with-editing-buffer

; 保存之前的上下文状态
     (when save-pos-p
       (neo-buffer--save-cursor-pos))
     (when non-neotree-buffer
       (setq neo-buffer--start-node start-node))

; 开始重绘
     (erase-buffer)
     (neo-buffer--node-list-clear)
     (neo-buffer--insert-banner)
     (setq neo-buffer--start-line neo-header-height)
     (neo-buffer--insert-tree start-node 1))

; 还原光标位置
    (neo-buffer--goto-cursor-pos)))

; 光标移动后的回调更新
(defun neo-buffer--post-move ()
  "光标移动时重置 default-directory 变量。"
  (funcall
   (neotree-make-executor
    :file-fn
    '(lambda (path _)
       (setq default-directory (neo-path--updir btn-full-path)))
    :dir-fn
    '(lambda (path _)
       (setq default-directory (file-name-as-directory path))))))

; 获取当前光标行上的 Button 对象
(defun neo-buffer--get-button-current-line ()
  "获取当前行对应的第一处按钮。"
  (let* ((btn-position nil)
         (pos-line-start (line-beginning-position))
         (pos-line-end (line-end-position))
         (current-button (or (button-at (point))
                             (button-at pos-line-start))))
    (if (null current-button)
        (progn
          (setf btn-position
                (catch 'ret-button
                  (let* ((next-button (next-button pos-line-start))
                         (pos-btn nil))
                    (if (null next-button) (throw 'ret-button nil))
                    (setf pos-btn (overlay-start next-button))
                    (if (> pos-btn pos-line-end) (throw 'ret-button nil))
                    (throw 'ret-button pos-btn))))
          (if (null btn-position)
              nil
            (setf current-button (button-at btn-position)))))
    current-button))

; 获取当前光标行绑定的文件/目录全路径
(defun neo-buffer--get-filename-current-line (&optional default)
  "获取当前行节点绑定的全路径名称。"
  (let ((btn (neo-buffer--get-button-current-line)))
    (if (not (null btn))
        (button-get btn 'neo-full-path)
      default)))

; 锁定 NeoTree 窗口宽度
(defun neo-buffer--lock-width ()
  "锁定 NeoTree 窗口的宽度。"
  (if neo-window-fixed-size
      (setq window-size-fixed 'width)))

; 解锁 NeoTree 窗口宽度
(defun neo-buffer--unlock-width ()
  "解除窗口宽度锁定。"
  (setq window-size-fixed nil))

; 重命名当前选中的文件/目录节点
(defun neo-buffer--rename-node ()
  "交互式重命名当前选中的节点。"
  (interactive)
  (let* ((current-path (neo-buffer--get-filename-current-line))
         (buffer (find-buffer-visiting current-path))
         to-path
         msg)
    (unless (null current-path)
      (setq msg (format "将 [%s] 重命名为: " (neo-path--file-short-name current-path)))
      (setq to-path (read-file-name msg (file-name-directory current-path)))
      (if buffer
          (with-current-buffer buffer
            (set-visited-file-name to-path nil t)))
      (if (vc-registered current-path)
          (vc-rename-file current-path to-path)
        (rename-file current-path to-path 1))
      (neo-buffer--refresh t)
      (message "重命名成功。"))))

; 复制当前节点
(defun neo-buffer--copy-node ()
  "复制当前选中的节点至新路径。"
  (interactive)
  (let* ((current-path (neo-buffer--get-filename-current-line))
         (buffer (find-buffer-visiting current-path))
         to-path
         msg)
    (unless (null current-path)
      (setq msg (format "复制 [%s] 到: " (neo-path--file-short-name current-path)))
      (setq to-path (read-file-name msg (file-name-directory current-path)))
      (if (file-directory-p current-path)
          (copy-directory current-path to-path)
        (copy-file current-path to-path))
      (neo-buffer--refresh t)
      (message "复制成功。"))))

; 根据 FILE 路径在 NeoTree 中匹配并定位选中该节点
(defun neo-buffer--select-file-node (file &optional recursive-p)
  "选中并高亮显示 FILE 对应的树节点。"
  (let ((efile file)
        (iter-curr-dir nil)
        (file-node-find-p nil)
        (file-node-list nil))
    (unless (file-name-absolute-p efile)
      (setq efile (expand-file-name efile)))
    (setq iter-curr-dir efile)
    (catch 'return
      (while t
        (setq iter-curr-dir (neo-path--updir iter-curr-dir))
        (push iter-curr-dir file-node-list)
        (when (neo-path--file-equal-p iter-curr-dir neo-buffer--start-node)
          (setq file-node-find-p t)
          (throw 'return nil))
        (let ((niter-curr-dir (file-remote-p iter-curr-dir 'localname)))
          (unless niter-curr-dir
            (setq niter-curr-dir iter-curr-dir))
          (when (neo-path--file-equal-p niter-curr-dir "/")
            (setq file-node-find-p nil)
            (throw 'return nil)))))
    (when file-node-find-p
      (dolist (p file-node-list)
        (neo-buffer--set-expand p t))
      (neo-buffer--save-cursor-pos file)
      (neo-buffer--refresh nil))))

; 更改文件树的根目录 Root
(defun neo-buffer--change-root (root-dir)
  "将 NeoTree 的根节点更改为 ROOT-DIR。"
  (let ((path root-dir)
        start-path)
    (unless (and (file-exists-p path)
                 (file-directory-p path))
      (throw 'error "该路径不是一个有效的目录。"))
    (setq start-path (expand-file-name (substitute-in-file-name path)))
    (setq neo-buffer--start-node start-path)
    (cd start-path)
    (neo-buffer--save-cursor-pos path nil)
    (neo-buffer--refresh nil)))

; 下跳选中的节点列表获取
(defun neo-buffer--get-nodes-for-select-down-node (path)
  "为向下定位节点获取可选的节点列表。"
  (if path
      (when (file-name-directory path)
        (if (neo-buffer--expanded-node-p path)
            (neo-buffer--get-nodes path)
          (neo-buffer--get-nodes (file-name-directory path))))
    (neo-buffer--get-nodes (file-name-as-directory neo-buffer--start-node))))

; 获取平级兄弟节点列表
(defun neo-buffer--get-nodes-for-sibling (path)
  "获取 PATH 的同级兄弟节点列表。"
  (when path
    (let ((nodes (neo-buffer--get-nodes (file-name-directory path))))
      (if (file-directory-p path)
          (car nodes)
        (cdr nodes)))))

; 获取下一个/上一个兄弟节点
(defun neo-buffer--sibling (path &optional previous)
  "返回节点 PATH 的相邻兄弟节点（PREVIOUS 为非 nil 时返回上一个）。"
  (let* ((nodes (neo-buffer--get-nodes-for-sibling path)))
    (when nodes
      (let ((i (neo-buffer--get-node-index path nodes))
            (l (length nodes)))
        (if i (nth (mod (+ i (if previous -1 1)) l) nodes))))))

; 核心交互命令调度器
(defun neo-buffer--execute (arg &optional file-fn dir-fn)
  "按键分发执行函数：根据光标下是文件还是目录分别调用 FILE-FN 或 DIR-FN。"
  (interactive "P")
  (let* ((btn-full-path (neo-buffer--get-filename-current-line))
         is-file-p
         enter-fn)
    (unless (null btn-full-path)
      (setq is-file-p (not (file-directory-p btn-full-path))
            enter-fn (if is-file-p file-fn dir-fn))
      (unless (null enter-fn)
        (funcall enter-fn btn-full-path arg)
        (run-hook-with-args
         'neo-enter-hook
         (if is-file-p 'file 'directory)
         btn-full-path
         arg)))
    btn-full-path))

; 切换隐藏文件的显示状态
(defun neo-buffer--set-show-hidden-file-p (show-p)
  "设置 SHOW-P 以开启或关闭隐藏文件的显示。"
  (setq neo-buffer--show-hidden-file-p show-p)
  (neo-buffer--refresh t))

; 下移 N 行
(defun neo-buffer--forward-line (n)
  "在 NeoTree Buffer 中向下移动 N 行。"
  (forward-line (or n 1))
  (neo-buffer--post-move))

; Mode-line 计算方法 (Mode-line methods)

(defun neo-mode-line--compute-format (parent index ndirs nfiles)
  "格式化并生成显示在 neotree 底部状态栏的信息文本。"
  (let* ((nall (+ ndirs nfiles))
         (has-dirs (> ndirs 0))
         (has-files (> nfiles 0))
         (msg-index (when index (format "[%s/%s] " index nall)))
         (msg-ndirs (when has-dirs (format (if has-files " (D:%s" " (D:%s)") ndirs)))
         (msg-nfiles (when has-files (format (if has-dirs " F:%s)" " (F:%s)") nfiles)))
         (msg-directory (file-name-nondirectory (directory-file-name parent)))
         (msg-directory-max-length (- (window-width)
                                      (length msg-index)
                                      (length msg-ndirs)
                                      (length msg-nfiles))))
    (setq msg-directory (if (<= (length msg-directory) msg-directory-max-length)
                            msg-directory
                          (concat (substring msg-directory
                                             0 (- msg-directory-max-length 3))
                                  "...")))
    (propertize
     (decode-coding-string (concat msg-index msg-directory msg-ndirs msg-nfiles) 'utf-8)
     'help-echo (decode-coding-string parent 'utf-8))))

; 窗口控制方法 (Window methods)

; 初始化 NeoTree 侧边栏窗口属性
(defun neo-window--init (window buffer)
  "将 WINDOW 初始化为专用的 NeoTree 侧边栏窗口。"
  (neo-buffer--with-resizable-window
   (switch-to-buffer buffer)
   (set-window-parameter window 'no-delete-other-windows t) 
; 防止被 C-x 1 意外关闭
   (set-window-dedicated-p window t))                       
; 设置为 Dedicated 专属窗口
  window)

; 缩放侧边栏窗口宽度
(defun neo-window--zoom (method)
  "按 METHOD 缩放 NeoTree 窗口 ('maximize 'minimize 'zoom-in 'zoom-out)。"
  (neo-buffer--unlock-width)
  (cond
   ((eq method 'maximize)
    (maximize-window))
   ((eq method 'minimize)
    (neo-util--set-window-width (selected-window) neo-window-width))
   ((eq method 'zoom-in)
    (shrink-window-horizontally 2))
   ((eq method 'zoom-out)
    (enlarge-window-horizontally 2)))
  (neo-buffer--lock-width))

; 判断侧边栏是否处于最小/默认宽度
(defun neo-window--minimize-p ()
  "如果 NeoTree 窗口处于默认缩进宽度则返回非 nil。"
  (<= (window-width) neo-window-width))

; 暴露给用户的交互式命令 (Interactive functions)

; 向下移动光标
(defun neotree-next-line (&optional count)
  "在 NeoTree Buffer 中向下移动 COUNT 行。"
  (interactive "p")
  (neo-buffer--forward-line (or count 1)))

; 向上移动光标
(defun neotree-previous-line (&optional count)
  "在 NeoTree Buffer 中向上移动 COUNT 行。"
  (interactive "p")
  (neo-buffer--forward-line (- (or count 1))))

;###autoload

; 自动在文件树中定位当前 Buffer 对应的文件
(defun neotree-find (&optional path default-path)
  "在 NeoTree 中快速定位并高亮指定 PATH 对应的节点。"
  (interactive)
  (let* ((ndefault-path (if default-path default-path
                          (neo-path--get-working-dir)))
         (npath (if path path
                  (or (buffer-file-name) ndefault-path)))
         (do-open-p nil))
    (if (and (not neo-force-change-root)
             (not (neo-global--file-in-root-p npath))
             (neo-global--window-exists-p))
        (setq do-open-p (funcall neo-confirm-change-root "当前文件不在 Root 路径下，是否切换根目录？"))
      (setq do-open-p t))
    (when do-open-p
      (neo-global--open-and-find npath))
    (when neo-auto-indent-point
      (neo-point-auto-indent)))
  (neo-global--select-window))

; 切换点击目录是否直接改变 Root 根节点的标志
(defun neotree-click-changes-root-toggle ()
  "切换点击文件夹是否直接将其切换为 Root 根目录。"
  (interactive)
  (setq neo-click-changes-root (not neo-click-changes-root)))

; 打开/展开目录节点
(defun neo-open-dir (full-path &optional arg)
  "展开或折叠一个目录节点。"
  (if neo-click-changes-root
      (neotree-change-root)
    (progn
      (let ((new-state (neo-buffer--toggle-expand full-path)))
        (neo-buffer--refresh t)
        (when neo-auto-indent-point
          (when new-state (forward-line 1))
          (neo-point-auto-indent))))))

; 递归展开子目录
(defun neo--expand-recursive (path state)
  "递归设置 PATH 的子目录展开状态为 STATE。"
  (let ((children (car (neo-buffer--get-nodes path) )))
    (dolist (node children)
      (neo-buffer--set-expand node state)
      (neo--expand-recursive node state ))))(defun neo-open-dir-recursive (full-path &optional arg)"递归展开当前目录节点及其所有子目录。"
  (if neo-click-changes-root
      (neotree-change-root)(let ((new-state (neo-buffer--toggle-expand full-path))
                                 (children (car (neo-buffer--get-nodes full-path))))
                             (dolist (node children)
                               (neo-buffer--set-expand node new-state)
                               (neo--expand-recursive node new-state))
                             (neo-buffer--refresh t))))

; 在 Dired 中打开节点
(defun neo-open-dired (full-path &optional arg)
  "在 Dired 模式中打开选中的文件或目录节点。"
  (neo-global--select-mru-window arg)
  (dired full-path))

; 在编辑器窗口中打开文件节点
(defun neo-open-file (full-path &optional arg)
  "打开一个文件节点。"
  (neo-global--select-mru-window arg)
  (find-file full-path))

; 垂直分屏打开文件
(defun neo-open-file-vertical-split (full-path arg)
  "在垂直切分的新窗口中打开当前文件节点。"
  (neo-open-file full-path "|"))

; 水平分屏打开文件
(defun neo-open-file-horizontal-split (full-path arg)
  "在水平切分的新窗口中打开当前文件节点。"
  (neo-open-file full-path "-"))

; 配合 ace-window 打开文件
(defun neo-open-file-ace-window (full-path arg)
  "通过 ace-window 选择目标窗口来打开当前节点。"
  (neo-open-file full-path "a"))

; 用系统默认程序（如外部图片查看器）打开该文件
(defun neotree-open-file-in-system-application ()
  "使用操作系统默认应用程序打开光标下的文件。"
  (interactive)
  (call-process neo-default-system-application nil 0 nil
                (neo-buffer--get-filename-current-line)))

; 更改根目录命令
(defun neotree-change-root ()
  "将 NeoTree 的根目录更改为当前光标所在的节点目录。"
  (interactive)
  (neo-global--select-window)
  (let ((btn-full-path (neo-buffer--get-filename-current-line)))
    (if (null btn-full-path)
        (call-interactively 'neotree-dir)
      (neo-global--open-dir btn-full-path))))

; 跳转到上一级父节点
(defun neotree-select-up-node ()
  "选中当前节点的父级目录；如果必要会切换 Root 根目录。"
  (interactive)
  (neo-global--select-window)
  (let* ((btn-full-path (neo-buffer--get-filename-current-line))
         (btn-parent-dir (if btn-full-path (file-name-directory btn-full-path)))
         (root-slash (file-name-as-directory neo-buffer--start-node)))
    (cond
     ((equal btn-parent-dir root-slash) (neo-global--open-dir root-slash))
     (btn-parent-dir (neotree-find btn-parent-dir))
     (t (neo-global--open-dir (file-name-directory
                               (directory-file-name root-slash)))))))

; 跳转到下一个展开的子节点
(defun neotree-select-down-node ()
  "向下选择第一个展开的子节点或同级兄弟节点。"
  (interactive)
  (let* ((btn-full-path (neo-buffer--get-filename-current-line))
         (path (if btn-full-path btn-full-path neo-buffer--start-node))
         (nodes (neo-buffer--get-nodes-for-select-down-node path)))
    (when nodes
      (if (or (equal path neo-buffer--start-node)
              (neo-buffer--expanded-node-p path))
          (let ((expanded-dir (catch 'break
                                (dolist (node (car nodes))
                                  (if (neo-buffer--expanded-node-p node)
                                      (throw 'break node)))
                                nil)))
            (if expanded-dir
                (neotree-find expanded-dir)
              (let ((dirs (car nodes))
                    (files (cdr nodes)))
                (if (> (length dirs) 0)
                    (neotree-find (car dirs))
                  (when (> (length files) 0)
                    (neotree-find (car files)))))))
        (let ((sibling (neo-buffer--sibling path)))
          (while (and (not (neo-buffer--expanded-node-p sibling))
                      (not (equal sibling path)))
            (setq sibling (neo-buffer--sibling sibling)))
          (when (not (string< sibling path))
            (neotree-find sibling)))))))

; 跳转到下一个平级兄弟节点
(defun neotree-select-next-sibling-node ()
  "选中当前节点的下一个同级兄弟节点。"
  (interactive)
  (let ((sibling (neo-buffer--sibling (neo-buffer--get-filename-current-line))))
    (when sibling (neotree-find sibling))))

; 跳转到上一个平级兄弟节点
(defun neotree-select-previous-sibling-node ()
  "选中当前节点的上一个同级兄弟节点。"
  (interactive)
  (let ((sibling (neo-buffer--sibling (neo-buffer--get-filename-current-line) t)))
    (when sibling (neotree-find sibling))))

; 在当前节点路径下创建文件或文件夹
(defun neotree-create-node (filename)
  "在当前选中的节点目录下新建文件或子目录。"
  (interactive
   (let* ((current-dir (neo-buffer--get-filename-current-line neo-buffer--start-node))
          (current-dir (neo-path--match-path-directory current-dir))
          (filename (read-file-name "新建文件名/目录: " current-dir)))
     (if (file-directory-p filename)
         (setq filename (concat filename "/")))
     (list filename)))
  (catch 'rlt
    (let ((is-file nil))
      (when (= (length filename) 0)
        (throw 'rlt nil))
      (setq is-file (not (equal (substring filename -1) "/")))
      (when (file-exists-p filename)
        (message "文件 %S 已存在。" filename)
        (throw 'rlt nil))
      (when (and is-file
                 (funcall neo-confirm-create-file (format "确认要创建文件 %S 吗？"
                                                          filename)))
        (mkdir (substring filename 0 (+ 1 (cl-position ?/ filename :from-end t))) t)
        (write-region "" nil filename)
        (neo-buffer--save-cursor-pos filename)
        (neo-buffer--refresh nil)
        (if neo-create-file-auto-open
            (find-file-other-window filename)))
      (when (and (not is-file)
                 (funcall neo-confirm-create-directory (format "确认要创建目录 %S 吗？"
                                                               filename)))
        (mkdir filename t)
        (neo-buffer--save-cursor-pos filename)
        (neo-buffer--refresh nil)))))

; 删除当前节点
(defun neotree-delete-node ()
  "交互式删除当前选中的文件或目录节点。"
  (interactive)
  (let* ((filename (neo-buffer--get-filename-current-line))
         (buffer (find-buffer-visiting filename))
         (deleted-p nil)
         (trash delete-by-moving-to-trash))
    (catch 'end
      (if (null filename) (throw 'end nil))
      (if (not (file-exists-p filename)) (throw 'end nil))
      (if (not (funcall neo-confirm-delete-file (format "真的确认删除 %S 吗？"
                                                        filename)))
          (throw 'end nil))
      (if (file-directory-p filename)

; 删除目录
          (progn
            (unless (neo-path--has-subfile-p filename)
              (delete-directory filename nil trash)
              (setq deleted-p t)
              (throw 'end nil))
            (when (funcall neo-confirm-delete-directory-recursively
                           (format "%S 是一个目录，是否递归删除其内部全部内容？"
                                   filename))
              (when (funcall neo-confirm-kill-buffers-for-files-in-directory
                             (format "是否同时关闭目录 %S 中文件关联的 Buffer？"
                                     filename))
                (neo-util--kill-buffers-for-path filename))
              (delete-directory filename t trash)
              (setq deleted-p t)))

; 删除普通文件
        (progn
          (delete-file filename trash)
          (when buffer
            (kill-buffer-ask buffer))
          (setq deleted-p t))))
    (when deleted-p
      (message "%S 已被成功删除。" filename)
      (neo-buffer--refresh t))
    filename))

; 重命名当前节点
(defun neotree-rename-node ()
  "重命名当前节点。"
  (interactive)
  (neo-buffer--rename-node))

; 复制当前节点
(defun neotree-copy-node ()
  "复制当前节点。"
  (interactive)
  (neo-buffer--copy-node))

; 切换隐藏文件显隐
(defun neotree-hidden-file-toggle ()
  "切换是否展示隐藏文件。"
  (interactive)
  (neo-buffer--set-show-hidden-file-p (not neo-buffer--show-hidden-file-p)))

; 空绑定函数（用于屏蔽部分危险快捷键）
(defun neotree-empty-fn ()
  "空函数，用于在 Keymap 中屏蔽不希望触发的 Emacs 原生快捷键。"
  (interactive))

; 刷新 NeoTree 命令
(defun neotree-refresh (&optional is-auto-refresh)
  "手动或自动刷新 NeoTree 侧边栏 Buffer。"
  (interactive)
  (if (eq (current-buffer) (neo-global--get-buffer))
      (neo-buffer--refresh t)
    (save-excursion
      (let ((cw (selected-window)))
        (if is-auto-refresh
            (let ((origin-buffer-file-name (buffer-file-name)))
              (when (and (fboundp 'projectile-project-p)
                         (projectile-project-p)
                         (fboundp 'projectile-project-root))
                (neo-global--open-dir (projectile-project-root))
                (neotree-find (projectile-project-root)))
              (neotree-find origin-buffer-file-name))
          (neo-buffer--refresh t t))
        (recenter)
        (when (or is-auto-refresh neo-toggle-window-keep-p)
          (select-window cw))))))

; 展开/收缩侧边栏宽度
(defun neotree-stretch-toggle ()
  "在最大化和默认宽度之间切换 NeoTree 窗口。"
  (interactive)
  (neo-global--with-window
    (if (neo-window--minimize-p)
        (neo-window--zoom 'maximize)
      (neo-window--zoom 'minimize))))

; 折叠所有展开的文件夹
(defun neotree-collapse-all ()
  "收起 NeoTree Buffer 中所有已经展开的文件夹。"
  (interactive)
  (setq list-of-expanded-folders neo-buffer--expanded-node-list)
  (dolist (folder list-of-expanded-folders)
    (neo-buffer--toggle-expand folder)
    (neo-buffer--refresh t)))

;###autoload

; 与 Projectile 自动切换项目根目录集成
(defun neotree-projectile-action ()
  "配合 Projectile 切换项目时调用的集成函数。用法:
(setq projectile-switch-project-action 'neotree-projectile-action)"
  (interactive)
  (cond
   ((fboundp 'projectile-project-root)
    (neotree-dir (projectile-project-root)))
   (t
    (error "Projectile 插件不可用"))))

;###autoload

; 切换 NeoTree 显示/隐藏
(defun neotree-toggle ()
  "切换 NeoTree 侧边栏窗口的显示与隐藏状态。"
  (interactive)
  (if (neo-global--window-exists-p)
      (neotree-hide)
    (neotree-show)))

;###autoload

; 显示 NeoTree
(defun neotree-show ()
  "打开并显示 NeoTree 侧边栏。"
  (interactive)
  (let ((cw (selected-window))
        (path (buffer-file-name)))
    (if neo-smart-open
        (progn
          (when (and (fboundp 'projectile-project-p)
                     (projectile-project-p)
                     (fboundp 'projectile-project-root))
            (neotree-dir (projectile-project-root)))
          (neotree-find path))
      (neo-global--open))
    (neo-global--select-window)
    (when neo-toggle-window-keep-p
      (select-window cw))))

;###autoload

; 隐藏 NeoTree
(defun neotree-hide ()
  "关闭并隐藏 NeoTree 侧边栏窗口。"
  (interactive)
  (if (neo-global--window-exists-p)
      (delete-window neo-global--window)))

;###autoload

; 打开侧边栏并指定路径
(defun neotree-dir (path)
  "显示 NeoTree 侧边栏，并将根目录更改为 PATH。"
  (interactive "D目录: ")
  (neo-global--open-dir path)
  (neo-global--select-window))

;###autoload

; 为 neotree-show 创建别名命令 M-x neotree
(defalias 'neotree 'neotree-show "显示 NeoTree 侧边栏窗口。")

; 废弃函数的向下兼容层 (Backward compatibility)
(defun neo-bc--make-obsolete-message (from to)
  (message "警告: %S 已废弃，请改用 %S。" from to))(defun neo-buffer--enter-file (path)
  (neo-bc--make-obsolete-message 'neo-buffer--enter-file 'neo-open-file))(defun neo-buffer--enter-dir (path)
  (neo-bc--make-obsolete-message 'neo-buffer--enter-dir 'neo-open-dir))(defun neotree-enter (&optional arg)
  "典型的 NeoTree 打开事件。"
  (interactive "P")
  (neo-buffer--execute arg 'neo-open-file 'neo-open-dir))(defun neotree-quick-look (&optional arg)
  "快速预览文件内容的打开事件。"
  (interactive "P")
  (neotree-enter arg)
  (neo-global--select-window))(defun neotree-enter-vertical-split ()
  (interactive)
  (neo-buffer--execute nil 'neo-open-file-vertical-split 'neo-open-dir))(defun neotree-enter-horizontal-split ()
  (interactive)
  (neo-buffer--execute nil 'neo-open-file-horizontal-split 'neo-open-dir))(defun neotree-enter-ace-window ()
  (interactive)
  (neo-buffer--execute nil 'neo-open-file-ace-window 'neo-open-dir))

; 复制当前选中节点的绝对路径到剪贴板 (Kill-ring)
(defun neotree-copy-filepath-to-yank-ring ()
  "快捷命令：将当前光标节点的文件路径复制到剪贴板。"
  (interactive)
  (kill-new (neo-buffer--get-filename-current-line)))

; 修正分屏分割比例问题的扩展函数 (解决 issue #209)
(defun neotree-split-window-sensibly (&optional window)
  "适配 NeoTree 侧边栏的 split-window-sensibly 分屏修正版本。"
  (let ((window (or window (selected-window))))
    (or (split-window-sensibly window)
        (and (get-buffer-window neo-buffer-name)
             (not (window-minibuffer-p window))
             (let ((split-height-threshold 0))
               (when (window-splittable-p window)
                 (with-selected-window window
                   (split-window-below))))))))

; 声明提供 neotree 特性包
(provide 'neotree)

; neotree.el 文件结尾
