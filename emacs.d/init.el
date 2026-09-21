;;; -*- lexical-binding: t -*-

;;; 中文导读：这是第二套配置的总入口。前半部分统一 UTF-8、双向文字、长行、
;;; 撤销容量、缩进和换行等核心行为；后半部分按依赖顺序 require user-lisp 中的
;;; 模块。`custom-file' 单独保存 Customize 自动生成的内容，避免污染手写配置。
;;; Windows 分支兼容系统剪贴板和外部进程编码，其他系统统一使用 UTF-8 Unix。

;;; 作用：在 early-init.el 之后、基础命令行参数和包初始化完成后加载。这是 Emacs 传统的主配置文件。
;;; 主要用途：
;;; 安装与加载插件：使用 use-package 或其他包管理器配置第三方插件。
;;; 绑定快捷键：自定义全局或特定模式的快捷键。
;;; 外观与行为设置：设置主题、字体、缩进、文件编码等绝大多数日常个性化配置。


;; 默认用 UTF-8 + Unix 换行符读写文件及进程文本。
(set-default-coding-systems 'utf-8-unix)
;; 设置 C 库区域环境，影响日期、排序及外部进程的语言/编码。
(set-locale-environment "en_US.UTF-8")
;; 编码自动探测出现歧义时优先按 Unicode 解释。
(set-charset-priority 'unicode)
;; Windows 剪贴板使用 UTF-16LE，并为 plink/cmdproxy 单独兼容 GBK；其他系统全用 UTF-8。
(if (eq system-type 'windows-nt)
    (progn
      (set-clipboard-coding-system 'utf-16-le)
      (setq default-process-coding-system `(utf-8-dos . ,locale-coding-system)
            process-coding-system-alist
            '(("[pP][lL][iI][nN][kK]" utf-8-dos . gbk-dos)
              ("[cC][mM][dD][pP][rR][oO][xX][yY]" utf-8-dos . gbk-dos))))
  (set-clipboard-coding-system 'utf-8-unix)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix)))

;; 光标显示为方框；关闭可视响铃和旧式 visible-cursor。
(setq cursor-type 'box
      visible-bell nil
      visible-cursor nil
      ;; 自动填充段落时识别缩进、编号和项目符号作为前缀。
      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      ;; 按从左到右的单向文本快速显示，降低超长代码文件的双向排版开销。
      bidi-inhibit-bpa t
      bidi-display-reordering 'left-to-right
      bidi-paragraph-direction 'left-to-right
      ;; 超过阈值的长行采用性能保护策略，横向滚动也提前优化。
      long-line-threshold 1000
      large-hscroll-threshold 1000
      ;; 扩大普通、强边界和最外层撤销历史的内存上限。
      undo-limit (* 13 160000)
      undo-strong-limit (* 13 240000)
      undo-outer-limit (* 13 24000000)
      ;; 句号后一格即可视为句末；删除自动配对字符时把位置压入 mark ring。
      sentence-end-double-space nil
      delete-pair-push-mark t)

;; 每个缓冲区默认 Tab 宽 2 列；TAB 先缩进，已正确缩进时尝试补全。
(setq-default tab-width 2
              tab-always-indent 'complete
              ;; 自动填充参考列为 80，长行采用截断而不是视觉折行。
              fill-column 80
              truncate-lines t
              truncate-partial-width-windows nil)

;; 将 Customize 自动生成设置隔离到 custom.el。
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;; 加载模块期间临时关闭文件名 handler，减少本地配置文件查找开销。
(let ((file-name-handler-alist nil))
  ;; 加载主题、公共定义及用户 Customize 文件；noerror 允许 custom.el 尚不存在。
  (require 'nn-world-theme)
  (require 'init-def)
  (require 'init-packages)
  (nn-bootstrap-packages)
  (load custom-file 'noerror)
  ;; 字体配置只对图形 frame 有意义，终端 Emacs 不加载。
  (when (display-graphic-p)
    (require 'init-font))
  ;; 依次加载基础行为、界面、编辑、语言、诊断、补全、导航、版本控制等功能模块。
  (require 'init-base)
  (require 'init-advanced)
  (require 'init-display)
  (require 'init-editor)
  (require 'init-lang)
  (require 'init-debug)
  (require 'init-diagnostics)
  ;;(require 'init-completion)
  (require 'init-navigation)
  (require 'init-vc)
  (require 'init-www)
  (require 'init-utils)
  (require 'init-mode-line)
  (require 'init-terminal)
  (require 'init-keybind)
  (require 'init-word-move)
  (require 'init-context-menu)
  (require 'init-filemanage)
  (require 'init-windows)
   (require 'init-vertico)
  (require 'init-home))
