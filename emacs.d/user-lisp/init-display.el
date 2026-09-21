;;; -*- lexical-binding: t -*-

;;; 中文导读：集中管理视觉呈现。行号、fringe、tooltip、括号匹配、空白字符和 SHR
;;; 文本渲染来自内置组件；nerd-icons/material-icon 提供图标；colorful-mode 与
;;; color-picker 显示/选取颜色；rainbow-delimiters 区分括号层级；indent-bars 显示
;;; 缩进引导线；Olivetti 提供居中写作；minibuffer-frame 将输入区放入独立 frame。
;;; 这些设置只改变显示方式，不改变文件内容。
;; 配置 Emacs 边缘区域 (fringe: 左右两侧留白与指示符区域)
(use-package fringe
  :ensure nil                                                  ; 内置包
  :custom
  (fringe-mode '(16 . 16))                                     ; 设置左右边缘宽度均为 16 像素
  (indicate-buffer-boundaries nil)                             ; 不在边缘显示 Buffer 顶部/底部边界标记
  (overflow-newline-into-fringe nil)                           ; 禁止换行符延伸至边缘区
  :config
  (setq-default fringes-outside-margins t)                     ; 将边缘区放置在 Margin 区域外侧
  (setf (cdr (assq 'truncation fringe-indicator-alist)) '(nil nil))) ; 隐藏文本超长截断时的箭头指示符

;; 载入自定义的边缘缩放扩展，确保高分屏/缩放时 fringe 正常按比例放缩
(use-package nn-fringe-scale
  :ensure nil
  :demand t                                                    ; 立即强行加载
  :config (nn-fringe-scale-mode 1))                            ; 开启边缘缩放模式

;; 配置 Emacs 内置的 Simple HTML Renderer (shr，用于 eww/elfeed 等)
(use-package shr
  :ensure nil                                                  ; 内置包
  :custom
  (shr-use-fonts t)                                            ; 允许使用富文本字体
  (shr-width 80)                                               ; HTML 排版折行宽度上限为 80 字符
  (shr-indentation 2)                                          ; HTML 元素默认缩进 2 空格
  (shr-bullet "• ")                                            ; 列表符号格式
  (shr-cookie-policy nil)                                      ; 默认禁用 cookie
  (shr-href-highlight t)                                       ; 高亮超链接
  (shr-image-animate t)                                        ; 允许动图 (GIF) 播放
  (shr-inhibit-images t)                                       ; 默认禁止自动加载图片（提速）
  (shr-table-corners ?┼)                                       ; 细线绘制表格四角
  (shr-table-horizontal-line ?─)                               ; 细线绘制表格横线
  (shr-table-vertical-line ?│)                                 ; 细线绘制表格竖线
  (shr-color-visible-luminance-min 60)                         ; 确保渲染的文字对比度亮度至少为 60
  (shr-color-visible-distance-min 5))                          ; 确保前后景颜色距离至少为 5，保证文本清晰可读

;; 配置 Tooltip 提示框
(use-package tooltip
  :ensure nil                                                  ; 内置包
  :custom (tooltip-resize-echo-area t))                        ; 当 Tooltip 内容过长时允许调整 Echo Area 尺寸

;; 配置内置的动态行号显示 (display-line-numbers)
(use-package display-line-numbers
  :ensure nil                                                  ; 内置包
  :hook
  (prog-mode text-mode conf-mode)                              ; 在代码、文本、配置文件模式下开启行号
  ((org-mode markdown-mode markdown-ts-mode) . (lambda () (display-line-numbers-mode -1))) ; 在文档写作模式下显式关闭行号
  :custom
  (display-line-numbers-grow-only t)                           ; 行号区域宽度只增不减（防止因为行数增加导致界面抖动）
  (display-line-numbers-width 3)                               ; 默认行号保留 3 字符宽度
  (display-line-numbers-widen t))                              ; 宽屏时自动适应

;; 配置括号匹配高亮 (show-paren-mode)
(use-package paren
  :ensure nil                                                  ; 内置包
  :hook (prog-mode . show-paren-mode)                          ; 在编程模式下开启括号匹配
  :custom
  (show-paren-delay 0.1)                                       ; 光标移动到括号后延迟 0.1 秒触发高亮
  (show-paren-highlight-openparen t)                           ; 高亮对应的左括号
  (show-paren-when-point-inside-paren t)                       ; 当光标处于括号内部时也触发高亮
  (show-paren-when-point-in-periphery t)                       ; 当光标在括号边缘时也触发高亮
  (show-paren-style 'parenthesis)                              ; 仅高亮括号本身而非整个括号内的区域
  (show-paren-context-when-offscreen 'overlay)                 ; 当匹配的另一半括号超出屏幕时，在顶部用 Overlay 弹窗显示上下文
  (blink-matching-paren-highlight-offscreen t)                 ; 闪烁显示屏幕外的匹配括号
  :config
  ;; 修改超屏括号上下文预览的样式：移除边框并缩小字号
  (define-advice show-paren--show-context-in-overlay (:after (_text) no-box)
    (when show-paren--context-overlay
      (overlay-put show-paren--context-overlay
                   'face '(:inherit default :box nil :height 0.9)))))

;; 配置空白字符高亮与清理 (whitespace)
(use-package whitespace
  :ensure nil                                                  ; 内置包
  :hook
  (before-save . delete-trailing-whitespace)                   ; 保存文件前强制清除行尾多余空格
  (emacs-lisp-mode                                             ; 在以下代码/配置模式下开启 whitespace-mode
   simpc-mode c-mode c++-mode
   js-mode js-json-mode json-ts-mode
   typescript-ts-mode tsx-ts-mode
   web-mode sh-mode powershell-mode
   makefile-mode makefile-gmake-mode)
  :custom
  (whitespace-line-column nil)                                 ; 不使用特定列限定
  (whitespace-style '(face indentation tabs tab-mark spaces space-mark)) ; 显式高亮空格、缩进和 Tab 标记
  (whitespace-display-mappings                                 ; 自定义 Tab 和空格的替代显示符号（Tab 显示为 →，空格显示为 ·）
   '((tab-mark ?\t [?→ ?\t])
     (space-mark ?\  [?·] [?.])))
  :config
  ;; HACK: 修复在多行 overlay 渲染时空白符替代标记引发的乱码问题
  (set-face-attribute 'nobreak-space nil :underline nil)
  (define-advice overlay-put (:filter-args (args) nn-bypass-whitespace-display)
    (if-let* ((prop (nth 1 args))
              (val (nth 2 args))
              ((eq prop 'display))
              ((stringp val))
              ((string-search " " val)))
        `(,(car args) display ,(string-replace " " "\u00a0" val))
      args))
  ;; HACK: 禁止在 child frame（如补全弹窗、浮动窗口）中启用 whitespace 标记，避免视觉干扰
  (defun my-whitespace--in-parent-frame-p () (null (frame-parameter nil 'parent-frame)))
  (add-function :before-while whitespace-enable-predicate #'my-whitespace--in-parent-frame-p))

;; 配置代码缩进引导线 (indent-bars)
(use-package indent-bars
  :hook
  (python-mode                                                 ; 针对严格依赖缩进的模式启用
   python-ts-mode
   yaml-mode yaml-ts-mode)
  :custom
  (indent-bars-display-on-blank-lines nil)                     ; 不在空行上绘制缩进线
  (indent-bars-highlight-current-depth nil)                  ; 不特殊高亮当前层级的缩进线
  (indent-bars-width-frac 0.2)                                 ; 缩进线的线宽比例为 0.2
  (indent-bars-color '(highlight :face-bg t :blend 0.2))       ; 使用混合 20% 高亮色的背景做为缩进线颜色
  (indent-bars-zigzag nil)                                     ; 不使用锯齿线
  (indent-bars-pattern "|"))                                  ; 使用纯点阵竖线 "|"

;; 配置彩虹括号高亮 (rainbow-delimiters)
(use-package rainbow-delimiters
  :hook prog-mode)                                             ; 在所有编程模式下按嵌套层级自动为括号匹配不同颜色

;; 配置写作与专注模式排版 (olivetti)
(use-package olivetti
  :hook
  (gnus-article-mode                                           ; 在邮件、新闻、文档模式下开启居中专注排版
   eww-mode org-mode markdown-ts-mode)
  :custom (olivetti-mode-on-hook nil))                         ; 开启时不额外执行其他钩子

;; 配置独立 Minibuffer Frame
(use-package minibuffer-frame
  :hook window-setup)                                          ; Emacs 窗口初始化完成后自动加载，将 minibuffer 独立为单独 frame

;; 配置 Git 仓库引入的第三方拾色器组件 (color-picker)
(use-package color-picker
  :vc (:url "https://github.com/zHaOdANiuu/color-picker.el" :rev :newest) ; 直接使用内置 VC 从 GitHub 远程安装最新版本
  :commands color-picker                                       ; 按需延迟加载命令
  :custom (color-picker-scale 2.0))                            ; 拾色器窗口放缩比例为 2.0

;; 配置代码颜色值高亮与交互模式 (colorful-mode)
(use-package colorful-mode
  :hook (prog-mode . colorful-mode)                            ; 编程模式默认开启颜色文本高亮
  :custom
  (colorful-use-prefix t)                                      ; 在颜色代码前插入预览前缀
  (colorful-only-strings 'only-prog)                           ; 在编程模式下仅高亮字符串内部的颜色代码（避免误判代码变量）
  :config
  (add-to-list 'global-colorful-modes 'helpful-mode)           ; 在 helpful 帮助文档 Buffer 中也启用高亮

  (with-eval-after-load 'web-mode
    (add-hook 'web-mode (lambda () (setq-local colorful-only-strings nil)))) ; 在 HTML/CSS 相关的 web-mode 中允许在所有区域识别颜色

  (when (display-graphic-p)                                    ; 仅在 GUI 图形界面下生效
    (require 'svg)

    ;; 根据 COLOR 动态生成内联 SVG 方块图标供前景预览
    (defun my-colorful--svg-img (color)
      (let* ((sz (frame-char-width))
             (svg (svg-create sz sz)))
        (svg-node svg 'rect
                  :x 1 :y 1 :width  (- sz 2) :height (- sz 2)
                  :fill color :stroke "#ffffff" :stroke-width "1.5")
        (svg-image svg :ascent 'center)))

    ;; 绑定 SVG 方块图标的鼠标点击事件（点击色块弹出拾色器，选择完颜色后直接替换缓冲区文本）
    (defvar-keymap my-colorful--color-picker-map
      "<mouse-1>"
      (lambda (event)
        (interactive "e")
        (let* ((pos (event-start event))
               (xy  (posn-x-y pos))
               (ov  (colorful--find-overlay (posn-point pos))))
          (when ov
            (color-picker
             :style 'simple :display 'frame
             :x (car xy) :y (cdr xy)
             :ok (lambda (picked)
                   (with-current-buffer (overlay-buffer ov)
                     (delete-region (overlay-start ov) (overlay-end ov))
                     (insert picked)))) ))))

    ;; 覆盖默认高亮逻辑：在颜色代码前插入可点击的 SVG 方块色块
    (defun colorful--colorize-match (color beg end kind face map)
      "Overlay match with a face from BEG to END.
The background uses COLOR color value.  The foreground is obtained
from `readable-foreground-color'."
      (let ((ov (make-overlay beg end)))
        (overlay-put ov 'colorful--overlay t)
        (overlay-put ov 'colorful--color-kind kind)
        (overlay-put ov 'colorful--color color)
        (overlay-put ov 'evaporate t)
        (overlay-put ov
                     'before-string
                     (propertize
                      " "
                      'display (my-colorful--svg-img color)
                      'keymap my-colorful--color-picker-map
                      'pointer 'hand))
        (overlay-put ov 'face nil)))))

;; 配置第三方 Material 风格文件图标包 (material-icon)
(use-package material-icon
  :vc (:url "https://github.com/zHaOdANiuu/material-icon.el" :rev :newest) ; 从远程 GitHub 自动拉取最新的图标库
  :hook
  (dired-mode . material-icon-dired-icons-mode)                ; 为 Dired 文件管理器添加文件/目录图标
  (ibuffer-mode . material-icon-ibuffer-icons-mode)            ; 为 iBuffer 缓冲区列表添加图标
  :init
  (setq material-icon-size 22)                                 ; 设置 Material 图标像素大小为 22
  (with-eval-after-load 'speedbar
    (material-icon-speedbar-icons-mode 1)))                    ; 加载 speedbar 时自动开启图标支持

;; 配置 Nerd 图标核心库 (nerd-icons)
(use-package nerd-icons
  :commands
  (nerd-icons-octicon
   nerd-icons-faicon
   nerd-icons-flicon
   nerd-icons-wicon
   nerd-icons-mdicon
   nerd-icons-codicon
   nerd-icons-devicon
   nerd-icons-ipsicon
   nerd-icons-pomicon
   nerd-icons-powerline))                                       ; 声明常用图标生成命令（按需懒加载）

;; 配置 Corfu 补全弹窗的 Nerd-Icons 图标增强 (nerd-icons-corfu)
(use-package nerd-icons-corfu
  :if (eq nn-completion-style 'corfu)                          ; 仅当系统的补全框架选用了 corfu 时加载
  :after corfu
  :init
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter) ; 挂载图标渲染器到 Corfu 的边框格式化列表
  (setq
   nerd-icons-corfu-mapping                                    ; 配置 Corfu 补全提示（如类、函数、变量、关键词等）对应的图标与颜色样式
   `((array :style "cod" :icon "symbol_array" :face nerd-icons-lblue)
     (boolean :style "cod" :icon "symbol_boolean" :face nerd-icons-lcyan)
     (class :style "cod" :icon "symbol_class" :face nerd-icons-lorange)
     (color :style "cod" :icon "symbol_color" :face nerd-icons-lorange)
     (command :style "cod" :icon "terminal" :face nerd-icons-purple)
     (constant :style "cod" :icon "symbol_constant" :face nerd-icons-lsilver)
     (constructor :style "cod" :icon "symbol_method" :face nerd-icons-purple)
     (enummember :style "cod" :icon "symbol_enum_member" :face nerd-icons-lblue)
     (enum-member :style "cod" :icon "symbol_enum_member" :face nerd-icons-lblue)
     (enum :style "cod" :icon "symbol_enum" :face nerd-icons-lyellow)
     (event :style "cod" :icon "symbol_event" :face nerd-icons-lorange)
     (field :style "cod" :icon "symbol_field" :face nerd-icons-lblue)
     (file :style "cod" :icon "file" :face nerd-icons-lsilver)
     (folder :style "cod" :icon "folder" :face nerd-icons-lyellow)
     (interface :style "cod" :icon "symbol_interface" :face nerd-icons-lcyan)
     (keyword :style "cod" :icon "symbol_keyword" :face nerd-icons-lblue)
     (macro :style "cod" :icon "symbol_misc" :face nerd-icons-pink)
     (magic :style "cod" :icon "wand" :face nerd-icons-purple)
     (method :style "cod" :icon "symbol_method" :face nerd-icons-purple)
     (function :style "cod" :icon "symbol_method" :face nerd-icons-purple)
     (module :style "cod" :icon "json" :face nerd-icons-lyellow)
     (numeric :style "cod" :icon "symbol_numeric" :face nerd-icons-lcyan)
     (operator :style "cod" :icon "symbol_operator" :face nerd-icons-lblue)
     (param :style "cod" :icon "symbol_parameter" :face nerd-icons-lsilver)
     (property :style "cod" :icon "symbol_property" :face nerd-icons-lblue)
     (reference :style "cod" :icon "references" :face nerd-icons-lblue)
     (snippet :style "cod" :icon "symbol_snippet" :face nerd-icons-lgreen)
     (string :style "cod" :icon "symbol_string" :face nerd-icons-lmaroon)
     (struct :style "cod" :icon "symbol_structure" :face nerd-icons-lorange)
     (text :style "cod" :icon "text_size" :face nerd-icons-lsilver)
     (typeparameter :style "cod" :icon "list_unordered" :face nerd-icons-lcyan)
     (type-parameter :style "cod" :icon "list_unordered" :face nerd-icons-lcyan)
     (unit :style "cod" :icon "symbol_ruler" :face nerd-icons-lsilver)
     (value :style "cod" :icon "symbol_field" :face nerd-icons-lblue)
     (variable :style "cod" :icon "symbol_variable" :face nerd-icons-lblue))))
     
(provide 'init-display)
