;;; -*- lexical-binding: t -*-

;;; 中文导读：核心编辑增强。electric-pair 自动补括号，EditorConfig 读取项目规范，
;;; Apheleia 异步格式化，hideshow/savefold 与 outline 折叠结构，symbol-overlay
;;; 高亮并跳转同名符号，multiple-cursors 多光标编辑，Viper 提供 Vi 风格状态。
;;; S-RET 切换折叠，C-c [/ ] 展开全部/按层收起，F1 格式化；M-n/M-p 跳转同名
;;; 符号、M-r 重命名；C->/C-< 加下/上一个多光标，C-c C-< 标记全部，ESC 退出。
;;; Viper 中 gd 找引用，SPC c a 执行代码操作，SPC s g/f 搜索/找文件，C-w h/j/k/l
;;; 切换窗口，] b/[ b 切换缓冲区。
;; 配置 Find File At Point (ffap: 自动识别光标处的 URL 或文件路径并打开)
(use-package ffap
  :ensure nil                                                  ; 内置包
  :custom
  (ffap-machine-p-known 'accept)                               ; 将已知机器名直接当作合法网络路径处理
  (ffap-machine-p-unknown 'accept))                            ; 将未知机器名也直接当作合法网络路径处理（跳过漫长的 ping/DNS 查询）

;; 配置段落与句尾识别规则 (paragraphs)
(use-package paragraphs
  :ensure nil                                                  ; 内置包
  :custom
  (sentence-end-double-space nil)                              ; 禁用美式“句尾必须双空格”的传统 Emacs 识别规则
  (sentence-end "\\([   ]\\|  \\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*")) ; 用正则表达式匹配单空格或标点符号作为句尾判断

;; 配置自动成对补全括号/引号 (electric-pair-mode)
(use-package elec-pair
  :ensure nil                                                  ; 内置包
  :hook (nn-first-input . electric-pair-mode)                  ; 用户首次键盘输入时延迟开启成对匹配模式
  :custom
  (electric-pair-open-newline-between-pairs t)                 ; 在匹配的大括号 {} 中按回车时，自动插入缩进换行
  (electric-pair-inhibit-predicate 'electric-pair-conservative-inhibit)) ; 在紧挨着单词或特定上下文时不自动补全右括号

;; 配置子词/驼峰命名导航 (subword-mode / superword-mode)
(use-package subword
  :ensure nil                                                  ; 内置包
  :hook
  (java-mode                                                   ; 在这些强驼峰命名语言中开启 subword-mode (按 CamelCase 划分按词跳转)
   js-mode typescript-ts-mode tsx-ts-mode
   csharp-mode c++-mode simpc-mode go-mode)
  ((c-mode python-mode rust-mode) . superword-mode))           ; 在这些蛇形命名(snake_case)语言中开启 superword-mode (将带有下划线的整体视为一个词)

;; 配置选择替换行为 (delete-selection-mode)
(use-package delsel
  :ensure nil                                                  ; 内置包
  :hook (nn-first-input . delete-selection-mode))              ; 首次输入时开启：选中文本后打字直接替换选中区域（现代编辑器习惯）

;; 配置大文件/长行文件优化保护 (so-long)
(use-package so-long
  :ensure nil                                                  ; 内置包
  :hook (nn-first-file . global-so-long-mode)                  ; 首次打开文件时全局启用长行保护模式
  :custom (so-long-threshold 5000)                             ; 当某一行字符数超过 5000 时触发防护机制
  :config
  (add-to-list 'so-long-target-modes 'conf-mode)               ; 防护目标加入配置模式
  (add-to-list 'so-long-target-modes 'text-mode)               ; 防护目标加入文本模式
  (add-to-list 'so-long-variable-overrides '(font-lock-maximum-decoration . 1)) ; 触发时降低语法高亮精细度
  (add-to-list 'so-long-variable-overrides '(save-place-alist . nil))           ; 禁用光标位置记录
  (cl-callf2 delq 'font-lock-mode so-long-minor-modes)         ; 不彻底关闭 font-lock
  (cl-callf2 delq 'display-line-numbers-mode so-long-minor-modes) ; 不彻底关闭行号显示
  (setf (alist-get 'buffer-read-only so-long-variable-overrides nil t) nil) ; 触发防护时保持文件处于可编辑状态
  (setq so-long-function #'turn-on-so-long-minor-modes
        so-long-revert-function #'turn-off-so-long-minor-modes))

;; 配置代码折叠持久化 (hideshow-savefold)
(use-package hideshow-savefold
  :ensure nil
  :hook prog-mode                                              ; 在编程模式下启用
  :custom (hideshow-savefold-directory (concat nn-directory "hideshow-savefold"))) ; 将文件折叠状态记录保存在全局 nn 目录下

;; 配置编程代码折叠 (hideshow)
(use-package hideshow
  :ensure nil                                                  ; 内置包
  :bind
  (:map hs-minor-mode-map
   ("S-<return>" . hs-toggle-hiding)                           ; Shift+Enter: 切换当前代码块的折叠/展开
   ("C-c [" . hs-show-all)                                     ; C-c [: 展开 Buffer 内的所有折叠
   ("C-c ]" . my-hs-hide-level))                               ; C-c ]: 折叠到指定层级
  :hook
  (prog-mode . hs-minor-mode)                                  ; 所有编程模式开启 hideshow
  ((js-json-mode                                               ; 在 JSON/Python/YAML 等依赖缩进的模式中开启基于缩进的折叠
    json-ts-mode
    python-mode python-ts-mode
    yaml-ts-mode sh-mode)
   . hs-indentation-mode)
  ((powershell-mode                                            ; C 风格语言调整代码块结尾位置校准
    simpc-mode c-mode c++-mode
    js-mode typescript-ts-mode tsx-ts-mode)
   . (lambda () (setq-local hs-adjust-block-end-function (lambda (p) (1- (line-beginning-position))))))
  :custom
  (hs-allow-nesting t)                                         ; 允许嵌套折叠
  (hs-hide-comments-when-hiding-all nil)                       ; 执行“折叠所有”时不自动隐藏注释
  (hs-set-up-overlay #'my-hs-set-up-overlay)                   ; 自定义折叠后的视觉 Overlay 显示样式
  :custom-face (hs-ellipsis ((t :inherit shadow)))             ; 设置折叠省略号的 Face 继承 shadow 灰字样式
  :config
  ;; 读取折叠层级，并用 hideshow 隐藏当前层级以下的代码块
  (defun my-hs-hide-level ()
    (interactive)
    (hs-hide-level 0))

  ;; 为 hideshow 折叠区域设置自定义的省略号字符 (使用 nn-fold-string 定义的字符串)
  (defun my-hs-set-up-overlay (ov)
    (when (eq 'code (overlay-get ov 'hs))
      (overlay-put ov 'face 'hs-ellipsis)
      (overlay-put ov 'display nn-fold-string)))

  ;; 为不同 Major Mode 定义匹配大括号与注释的代码块起始/结束正则表达式
  (setq hs-special-modes-alist
        '((c++-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (c-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (simpc-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (js-ts-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (js-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (typescript-ts-mode "\\s(" "\\s)" "/[*/]" nil nil)
          (web-mode "<!--\\|<[^/>]*[^/]>"
                    "-->\\|</[^/>]*[^/]>"
                    "<!--" sgml-skip-tag-forward nil)
          (t))))

;; 配置文本/大纲折叠 (outline-minor-mode)
(use-package outline
  :ensure nil                                                  ; 内置包
  :bind
  (:map outline-minor-mode-map
   ("S-<return>" . outline-toggle-children)                    ; Shift+Enter: 展开/折叠子节点
   ("C-c [" . outline-show-all)                                ; C-c [: 显示全部正文与节点
   ("C-c ]" . outline-hide-body))                              ; C-c ]: 隐藏所有正文，仅保留标题大纲
  :hook
  (text-mode . outline-minor-mode)                             ; 在文本模式开启
  (conf-mode . outline-minor-mode)                             ; 在配置模式开启
  (outline-minor-mode . my-outline-set-buffer-local-ellipsis)  ; 启用时设置自定义的 Buffer 局部折叠省略号
  :config
  ;; 为当前 Outline 缓冲区设置局部折叠省略号显示（使其也使用 nn-fold-string 样式）
  (defun my-outline-set-buffer-local-ellipsis ()
    (let* ((display-table (or buffer-display-table (make-display-table)))
           (face-offset (* (face-id 'shadow) (ash 1 22)))
           (value (vconcat (mapcar (lambda (c)
                                     (+ face-offset c))
                                   (string-trim-right nn-fold-string)))))
      (set-display-table-slot display-table 'selective-display value)
      (setq buffer-display-table display-table))))

;; 配置统一编辑规范 (editorconfig)
(use-package editorconfig
  :ensure nil                                                  ; 内置包
  :hook nn-first-file                                          ; 打开首个文件时挂载
  :custom
  (editorconfig-trim-whitespaces-mode t)                       ; 保存时按照 .editorconfig 规则清理行尾多余空白
  (editorconfig-get-properties-function #'editorconfig-get-properties))

;; 配置异步代码格式化工具 (apheleia)
(use-package apheleia
  :bind ("<f1>" . apheleia-format-buffer)                      ; F1: 手动触发当前 Buffer 的格式化
  :hook (apheleia-inhibit-functions . my-apheleia-inhibit-p)   ; 挂载格式化抑制条件判断
  :custom (apheleia-log-only-errors t)                         ; 仅在格式化出错时记录日志
  :config
  (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))        ; sh-mode 使用 shfmt 格式化
  (add-to-list 'apheleia-mode-alist '(simpc-mode . clang-format)) ; C/C++ 使用 clang-format
  (add-to-list 'apheleia-mode-alist '(cuda-mode . clang-format))  ; CUDA 使用 clang-format
  (add-to-list 'apheleia-mode-alist '(protobuf-mode . clang-format)) ; Protobuf 使用 clang-format

  ;; 配置 JS/TS/Web 相关语言的格式化器统一使用系统的 prettier 命令
  (dolist (formatter
           '(prettier prettier-css prettier-html prettier-javascript
             prettier-json prettier-scss prettier-svelte
             prettier-typescript prettier-yaml))
    (setf (alist-get formatter apheleia-formatters)
          '("prettier" "--stdin-filepath"
            (or (apheleia-formatters-local-buffer-file-name)
                (apheleia-formatters-mode-extension)
                ".js")))))

;; 配置当前光标下相同的符号高亮 (symbol-overlay)
(use-package symbol-overlay
  :bind
  ("M-n" . symbol-overlay-jump-next)                           ; Alt+n: 跳转到下一个相同高亮符号
  ("M-p" . symbol-overlay-jump-prev)                           ; Alt+p: 跳转到上一个相同高亮符号
  ("M-r" . symbol-overlay-rename)                              ; Alt+r: 交互式重命名当前高亮的符号
  :hook (prog-mode yaml-mode yaml-ts-mode)                     ; 在编程和 YAML 模式下启用
  :custom (symbol-overlay-idle-time 0.5))                      ; 光标停止移动 0.5 秒后自动高亮当前光标下的符号

;; 配置多光标编辑 (multiple-cursors)
(use-package multiple-cursors
  :bind
  (("C->" . mc/mark-next-like-this)                            ; Ctrl+>: 在下一个匹配处添加光标
   ("C-<" . mc/mark-previous-like-this)                        ; Ctrl+<: 在上一个匹配处添加光标
   ("C-c C-<" . mc/mark-all-like-this)                         ; C-c C-<: 选中当前 Buffer 所有匹配处并添加光标
   ("C-M->" . mc/skip-to-next-like-this)                       ; Ctrl+Alt+>: 跳过当前匹配并寻找下一个
   ("C-M-<" . mc/skip-to-previous-like-this)                   ; Ctrl+Alt+<: 跳过当前匹配并寻找上一个
   :map mc/keymap
   ("M-S-w" . my-mc/copy)                                      ; Alt+Shift+W: 多光标复制
   ("C-S-w" . my-mc/cat)                                       ; Ctrl+Shift+W: 多光标剪切
   ("C-;" . mc/vertical-align-with-space)                      ; Ctrl+;: 将所有多光标在垂直方向用空格对齐
   ("<escape>" . multiple-cursors-mode))                       ; ESC: 退出多光标模式
  :init (multiple-cursors-mode t)
  :custom
  (mc/always-run-for-all t)                                   ; 未知的命令无需二次确认，直接应用于所有光标
  (mc/list-file (concat nn-directory ".mc-lists.el"))          ; 多光标命令白名单/黑名单存储路径
  :config
  (add-to-list 'mc--defaultcmds-to-run-once #'swiper-mc)       ; 搜索时只运行一次 swiper-mc

  ;; 取得 BEG 到 END 的文本，并保留该行缩进供多光标复制使用
  (defun my-mc/get-line-with-indent (beg end)
    (save-excursion
      (goto-char beg)
      (concat (buffer-substring-no-properties (line-beginning-position) beg)
              (buffer-substring-no-properties beg end))))

  ;; 按多光标顺序收集每个光标所在行或选区的文本
  (defun my-mc/lines-get ()
    (let ((pairs
           `(,`(,(region-beginning) ,(region-end)
                ,(my-mc/get-line-with-indent
                  (region-beginning) (region-end))))))
      (mc/for-each-fake-cursor
       cursor
       (let* ((pt (marker-position (overlay-get cursor 'point)))
              (mk (marker-position (overlay-get cursor 'mark)))
              (beg (min pt mk))
              (end (max pt mk)))
         (push `(,beg ,end ,(my-mc/get-line-with-indent beg end))
               pairs)))
      (sort pairs (lambda (a b) (< (nth 0 a) (nth 0 b))))))

  ;; 将多个光标处收集到的文本复制为一组 kill-ring 内容
  (defun my-mc/copy ()
    (interactive)
    (kill-new (string-join (mapcar (lambda (r) (nth 2 r)) (my-mc/lines-get)) "\n"))
    (mc/keyboard-quit)
    (multiple-cursors-mode -1))

  ;; 把多光标收集的多段文本拼接后写入 kill-ring，并删除选中选区（即多光标剪切）
  (defun my-mc/cat ()
    (interactive)
    (let ((pairs (my-mc/lines-get)))
      (kill-new (string-join (mapcar (lambda (r) (nth 2 r)) pairs) "\n"))
      (dolist (r (reverse pairs))
        (delete-region (nth 0 r) (nth 1 r)))
      (mc/keyboard-quit)
      (multiple-cursors-mode -1))))

;; 配置内置 Vim 模拟器 (viper-mode)
(use-package viper
  :ensure nil                                                  ; 内置包
  :if nn-vim-mode                                              ; 仅在全局变量 nn-vim-mode 为真时开启
  :bind
  (:map viper-vi-global-user-map
   ;; 跳转与 LSP 快捷键映射
   ("gd" . xref-find-references)                               ; gd: 查找引用
   ("SPC c a" . eglot-code-actions)                            ; SPC c a: 触发 Eglot (LSP) Code Action 修复菜单
   ("SPC s g" . project-find-regexp)                           ; SPC s g: 在项目中正则搜索字符串
   ("SPC s f" . project-find-file)                             ; SPC s f: 在项目中搜索文件名
   ;; 窗口分屏与管理快捷键映射 (模拟 Vim C-w 前缀)
   ("C-w s" . viper-window-split-horizontally)                 ; C-w s: 水平分屏
   ("C-w v" . viper-window-split-vertically)                   ; C-w v: 垂直分屏
   ("C-w c" . viper-window-close)                              ; C-w c: 关闭当前窗口
   ("C-w o" . viper-window-maximize)                           ; C-w o: 最大化当前窗口
   ;; 窗口方向导航快捷键 (模拟 Vim C-w hjkl)
   ("C-w h" . windmove-left)                                   ; C-w h: 光标切到左边窗口
   ("C-w l" . windmove-right)                                  ; C-w l: 光标切到右边窗口
   ("C-w k" . windmove-up)                                     ; C-w k: 光标切到上边窗口
   ("C-w j" . windmove-down)                                   ; C-w j: 光标切到下边窗口
   ;; 格式化与拼写检查
   ("==" . indent-region)                                      ; ==: 重新缩进选中区域
   ("z=" . ispell-word)                                        ; z=: 矫正当前单词拼写
   ;; 缓冲区切换
   ("] b" . next-buffer)                                       ; ] b: 切换到下一个 Buffer
   ("[ b" . previous-buffer)                                   ; [ b: 切换到上一个 Buffer
   ("b l" . switch-to-buffer)                                  ; b l: 弹出 Buffer 列表
   ("SPC SPC" . switch-to-buffer))                             ; 空格+空格: 快速切换 Buffer
  :init
  (setq viper-inhibit-startup-message t                        ; 隐藏 Viper 启动提示
        viper-expert-level 5)                                  ; 设置 Viper 专家级别为 5（最高级，完全以 Vim 快捷键行为为主）
  :config
  (when (eq system-type 'windows-nt)
    ;; 当处于 Windows 环境且进入 Normal 模式时，自动关闭 Windows 系统输入法（IME），避免打字出现中文干扰
    (add-hook 'viper-vi-state-hook (lambda () (w32-set-ime-open-status nil)))))

(provide 'init-editor)
