;;; -*- lexical-binding: t -*-


;; 设置系统的编码，避免各处的乱码
;; UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)



;; 开启服务
;; (server-mode 1)

(electric-pair-mode t)                       ; 括号补全
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号

(global-auto-revert-mode t)                  ; 自动加载外部修改过的文件
(setq auto-save-default nil)                 ; 关闭自动保存文件，#为后缀的文件


(global-display-line-numbers-mode 1)                ;; 显示行号 29版本。29之前用(global-linum-mode 1)
(global-hl-line-mode t)                             ;; 高亮当前行
(setq-default cursor-type 'bar)                     ;; 更改光标的样式，默认比较粗. 更多C-h v 查询帮助
;;(setq cursor-type 'bar)                           ;; 更改光标的样式。setq当前buffer生效，不能全局生效

;;(set-face-attribute 'default nil :height 150)     ;; 修改字号，大小为16pt
;;让鼠标滚动更好用。默认滚动很快
(setq mouse-wheel-scroll-amount '(3 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)


;;; -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------------------
;; 1. 剪贴板与选择集 (Clipboard & Selection)
;; ----------------------------------------------------------------------------
(setq select-enable-clipboard t)
;; 作用：允许 Emacs 与系统的剪贴板进行交互（替代已废弃的 x-select-enable-clipboard）。
;; 影响：在 Emacs 中复制/剪切的内容可以粘贴到其他外部软件（如浏览器、Word）中，反之亦然。

(delete-selection-mode 1)
;; 作用：开启删除选中文本模式（即 Typing Replaces Selection）。
;; 影响：当选中文本后直接输入新字符或按 Backspace 时，会直接删除或替换选中的文本，符合现代操作习惯。

(setq shift-select-mode nil)
;; 作用：禁用按住 Shift 键配合方向键选择文本的功能。
;; 影响：防止误触 Shift 键选中文本；对于习惯经典 Emacs（使用 C-SPC 设置 Mark 选区）的用户更加纯粹。


;; ----------------------------------------------------------------------------
;; 2. 文件与 Buffer 自动重载 (Auto Revert)
;; ----------------------------------------------------------------------------
(setq global-auto-revert-non-file-buffers t)
;; 作用：将自动重载应用到非文件 Buffer（如 Dired 目录树列表）。
;; 影响：当在外部（如终端/访达）新建或删除了文件，Emacs 的 Dired 目录列表会自动同步更新。

;; ----------------------------------------------------------------------------
;; 3. 基础界面与交互体验 (UI & Interaction)
;; ----------------------------------------------------------------------------
(setq echo-keystrokes 0.1)
;; 作用：设置未完成按键组合在 Echo Area 显示的延迟时间为 0.1 秒。
;; 影响：当按下一个快捷键的前缀（如 C-x）后，仅需 0.1 秒就会在底部显示出来，方便确认按键状态。

(setq delete-by-moving-to-trash t)
;; 作用：在 Emacs 中删除文件时，将文件移动到系统的“废纸篓/回收站”而非彻底物理删除。
;; 影响：大幅提升文件安全性，避免在 Dired 或编辑中误删文件导致无法找回。

(auto-compression-mode 1)
;; 作用：全局启用文件自动解压缩解包模式。
;; 影响：直接打开 .gz、.z 等压缩格式的文件时，Emacs 会透明地自动解压并显示其内容，保存时自动再压缩。

(global-font-lock-mode t)
;; 作用：开启全局语法高亮模式（Font Lock）。
;; 影响：确保在所有支持的代码与文本模式下，关键字、注释、字符串等均有颜色的语法高亮显示。

;; ----------------------------------------------------------------------------
;; 4. 全局字符编码设置 (Coding Systems)
;; ----------------------------------------------------------------------------
(setq locale-coding-system 'utf-8)
;; 作用：设置 Emacs 的区域（Locale）语言环境默认编码为 UTF-8。
;; 影响：确保系统环境相关的字符串输出与时间日期格式解析正常。

(set-terminal-coding-system 'utf-8)
;; 作用：设置终端输出的编码格式为 UTF-8。
;; 影响：在终端（-nw）模式下启动 Emacs 时，防止输出的字符或乱码展示。

(set-keyboard-coding-system 'utf-8)
;; 作用：设置键盘输入的编码格式为 UTF-8。
;; 影响：保证按键输入的特殊符号或中文字符能够正确被 Emacs 识别。

(set-selection-coding-system 'utf-8)
;; 作用：设置 Emacs 与外部剪贴板/选择集通信时的编码为 UTF-8。
;; 影响：彻底解决从外部复制中文到 Emacs，或者从 Emacs 复制中文到其他软件时的乱码问题。

(prefer-coding-system 'utf-8)
;; 作用：设置全局首选编码为 UTF-8。
;; 影响：当 Emacs 无法自动判断文件编码时，优先选择 UTF-8 解码，确保多语言环境兼容。


;; ----------------------------------------------------------------------------
;; 5. 选区与 Mark 高亮 (Region & Mark)
;; ----------------------------------------------------------------------------
(transient-mark-mode 1)
;; 作用：开启高亮显示当前激活选区（Region）模式。
;; 影响：设置 Mark（C-SPC）后移动光标，选中的文本块会高亮显示，清晰指示操作范围。

(make-variable-buffer-local 'transient-mark-mode)
;; 作用：将 `transient-mark-mode` 变量设置为 Buffer 局部变量。
;; 影响：允许在不同的 Buffer 中独立控制选区高亮的开关状态。

(put 'transient-mark-mode 'permanent-local t)
;; 作用：将 `transient-mark-mode` 标记为永久局部变量。
;; 影响：即使当前 Buffer 切换或重置了 Major Mode（主模式），选区高亮配置也不会被重置回默认状态。

(setq-default transient-mark-mode t)
;; 作用：将 `transient-mark-mode` 的全局默认值设为启用 (t)。
;; 影响：所有新建立的 Buffer 默认都拥有选区高亮效果。

(setq jump-char-lazy-highlight-face nil)
;; 作用：将 `jump-char` 插件的延迟高亮样式设为空（禁用）。
;; 影响：在使用 `jump-char` 快速跳转时，不会高亮显示其他匹配字符，避免界面杂乱分散注意力。


;; ----------------------------------------------------------------------------
;; 6. 排版与状态栏 (Formatting & Mode Line)
;; ----------------------------------------------------------------------------
(setq line-number-mode t)
;; 作用：在底部的 Mode Line 状态栏中显示当前光标所在行号。
;; 影响：随时能在底部直观看到文件行的位置。

(setq column-number-mode t)
;; 作用：在底部的 Mode Line 状态栏中显示当前光标所在列号。
;; 影响：方便精确查看和排查代码的具体列位置。

(setq-default indicate-empty-lines t)
;; 作用：在窗口左侧的 Fringe（边框列）标示出文件末尾之后的空行。
;; 影响：文件最后一行后面的空白区域左侧会显示微小的虚线/符号，方便区分“真实空行”与“超出文件结尾”。

(global-subword-mode 1)
;; 作用：全局开启 Subword（子词跳转）模式。
;; 影响：光标按词移动（M-f/M-b）时能够识别驼峰命名（CamelCase），在 `sillyCasedWords` 的每个子单词间按停。

;; ----------------------------------------------------------------------------
;; 7. 最近文件与历史记录 (History & Recentf)
;; ----------------------------------------------------------------------------
(setq recentf-save-file (my/runtime-file "recentf")
      savehist-file (my/runtime-file "history")
      save-place-file (my/runtime-file "save-place"))
(save-place-mode 1)

(recentf-mode 1)
;; 作用：开启最近打开文件记录（Recentf）模式。
;; 影响：Emacs 会在后台持续追踪并保存你打开过的文件列表。

(setq recentf-max-saved-items 100)
;; 作用：将最近文件列表中保留的最大条目数提升至 100 项。
;; 影响：可以让你通过 `recentf-open-files` 快速回溯并打开更久之前访问过的历史文件。

(savehist-mode 1)
;; 作用：开启 Minibuffer 历史记录保存模式。
;; 影响：在 Minibuffer 中输入的命令、搜索关键词、文件路径等在 Emacs 重启后依然会被保留。

;; ----------------------------------------------------------------------------
;; 9. 平滑滚屏 (Smooth Scrolling)
;; ----------------------------------------------------------------------------
(require 'smooth-scrolling nil 'noerror)
;; 作用：尝试加载 `smooth-scrolling` 扩展包（若不存在则静默跳过）。
;; 影响：避免光标移动到屏幕最顶/最底端时页面发生剧烈的跳跃式滚屏，保持平滑过度。


;; ----------------------------------------------------------------------------
;; 10. 内存与垃圾回收 (GC Optimization)
;; ----------------------------------------------------------------------------
(setq gc-cons-threshold 20000000)
;; 作用：将 Emacs 的垃圾回收（GC）触发阈值提高到 20MB（默认仅约为 800KB）。
;; 影响：大幅减少高频触发 GC 导致的卡顿，显著提升在大文件编辑或加载包时的运行流畅度。


;; ----------------------------------------------------------------------------
;; 11. Org-Mode 专用优化
;; ----------------------------------------------------------------------------
(setq org-replace-disputed-keys t)
;; 作用：开启 Org-mode 快捷键冲突自动替换机制。
;; 影响：防止 Org-mode 默认占用的 Shift+方向键 与系统/ Emacs 的窗口切换快捷键产生冲突。

(setq org-src-fontify-natively t)
;; 作用：开启 Org-mode 内部代码块（Source Blocks）的原生语法高亮。
;; 影响：在 Org 文档中嵌入的 Elisp、Python、C 等代码块会直接以各自语言的语法高亮样式渲染。


;; ----------------------------------------------------------------------------
;; 12. 撤销树历史 (Undo-Tree)
;; ----------------------------------------------------------------------------
(setq undo-tree-mode-lighter "")
;; 作用：将 `undo-tree` 在状态栏 (Mode Line) 显示的模式标识设为空字符串。
;; 影响：隐藏底部状态栏上 `Undo-Tree` 的文字提示，保持状态栏整洁。

(when (require 'undo-tree nil 'noerror)
  (global-undo-tree-mode 1))
;; 作用：安全加载并全局启用 `undo-tree` 撤销树模式。
;; 影响：替换 Emacs 默认的线型 Undo 机制，使用 `C-x u` 可调出极为强大的可视化撤销/重做树状分支图。


;; ----------------------------------------------------------------------------
;; 13. 同名 Buffer 路径辨识 (Uniquify)
;; ----------------------------------------------------------------------------
(require 'uniquify)
;; 作用：加载 `uniquify` 内置库。
;; 影响：开启同名 Buffer 重命名管理功能。

(setq uniquify-buffer-name-style 'forward)
;; 作用：设置同名 Buffer 的命名命名风格为“前向路径”模式（例如 `file.txt|dir-a`）。
;; 影响：当同时打开不同目录下的同名文件（如 `a/style.css` 和 `b/style.css`）时，Buffer 名称会自动附带父级目录区别，不再显示为无意义的 `style.css<2>`。


;; ----------------------------------------------------------------------------
;; 14. 差异比较与合并 (Ediff Optimization)
;; ----------------------------------------------------------------------------
(setq ediff-diff-options "-w")
;; 作用：设置内置 Diff 命令行参数，增加 `-w`（忽略所有空格变化）。
;; 影响：使用 Ediff 比较文件差异时，会自动忽略纯空格/缩进导致的无关差异。

(setq ediff-split-window-function 'split-window-horizontally)
;; 作用：设置 Ediff 比较窗口默认采用“左右分屏”展示。
;; 影响：替代默认的上下分屏，在宽屏显示器上能更直观地对比左右两份代码。

(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; 作用：设置 Ediff 界面为“平铺框”模式，而不是弹出一个独立的悬浮控制小窗口。
;; 影响：将控制面板限制在当前框架内部，防止多余的悬浮窗口对平铺桌面或平铺窗口管理器造成干扰。


;; ----------------------------------------------------------------------------
;; 15. 智能缩进控制 (Electric Indent)
;; ----------------------------------------------------------------------------
(electric-indent-mode -1)
;; 作用：关闭全局自动换行智能缩进模式。
;; 影响：回车换行时不会自动对上一行重新进行强制缩进对齐，完全尊重手动排版。


;; ----------------------------------------------------------------------------
;; 16. Elisp 求值限制 (Eval Print Limit)
;; ----------------------------------------------------------------------------
(setq eval-expression-print-level 100)
;; 作用：设置使用 `M-:` 评估 Elisp 表达式时，嵌套结构打印的最大深度层级为 100。
;; 影响：防止在打印极深的嵌套列表/结构体时被截断为 `(...)`，让你能够完整观察到绝大多数数据结果。


;; ----------------------------------------------------------------------------
;; 17. 优化 Mark 弹出定位 (Pop to Mark Optimization)
;; ----------------------------------------------------------------------------
;; 现代写法：使用 advice-add 替代已被废弃的 defadvice 宏
(defun my/pop-to-mark-command-advice (orig-fun &rest args)
  "确保跳回 Mark 位置时光标能够真正发生移动，并滤除特定高频重复操作。"
  (let ((p (point)))
    (when (eq last-command 'save-region-or-current-line)
      (apply orig-fun args)
      (apply orig-fun args)
      (apply orig-fun args))
    (dotimes (_ 10)
      (when (= p (point))
        (apply orig-fun args)))))

(advice-add 'pop-to-mark-command :around #'my/pop-to-mark-command-advice)
;; 作用：拦截 `pop-to-mark-command` (C-u C-SPC) 命令并包裹一层智能校验逻辑。
;; 影响：多次弹退光标时，如果弹出后光标位置没变（例如在同一行多次重置了 Mark），它会自动继续向后弹出，直到光标真正跳转到不同的位置。

(setq set-mark-command-repeat-pop t)
;; 作用：开启 Mark 连续弹出模式。
;; 影响：在第一次按 `C-u C-SPC` 弹退光标后，后续无需再按 `C-u`，只需连续按 `C-SPC` 即可持续向后跳转 Mark 历史。


;; ----------------------------------------------------------------------------
;; 18. 自动创建不存在的父级目录 (Auto-Create Non-Existent Directories)
;; ----------------------------------------------------------------------------
(defun my-create-non-existent-directory ()
  "当打开或新建的文件所在父目录不存在时，询问用户并自动创建该目录。"
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "目录 `%s' 不存在！是否立即创建？" parent-directory)))
      (make-directory parent-directory t))))

(add-to-list 'find-file-not-found-functions 'my-create-non-existent-directory)
;; 作用：将上面的自定义函数挂载到 `find-file-not-found-functions` Hook 钩子上。
;; 影响：当你使用 `C-x C-f` 试图新建一个位于不存在的深度目录下的文件（如 `a/b/c/new.txt`）时，Emacs 会自动捕捉并弹窗提示，确认后自动创建所有层级的父级文件夹。





(message "Load init-basic done...")
(provide 'init-base)
