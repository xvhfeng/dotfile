;;; -*- lexical-binding: t -*-

;;; 中文导读：调试模块。自定义鼠标拖动 frame，并使用 Dape 通过 DAP 协议连接
;;; GDB/LLDB 等调试器。F5 启动/继续，S-F5 退出，F9 切换断点，F10 单步越过，
;;; F11 单步进入，S-F11 单步跳出，C-F5 强制结束调试会话。
;; 定义变量：用于保存悬浮工具栏 Frame 的引用对象
(defvar my-dape-toolbar-frame nil)
;; 定义变量：用于保存悬浮工具栏 Buffer 的引用对象
(defvar my-dape-toolbar-buf nil)

;; 定义常量列表：配置工具栏上各个按钮的“图标名称”、“对应的 dape 调试命令”、“悬停提示(Tooltip)”、“图标颜色 Face”
(defconst my-dape-toolbar-buttons
  '(("nf-cod-debug_continue"  dape-continue "Continue"  nerd-icons-lblue)
    ("nf-cod-debug_step_over" dape-next     "Step Over" nerd-icons-lblue)
    ("nf-cod-debug_step_into" dape-step-in  "Step Into" nerd-icons-lblue)
    ("nf-cod-debug_step_out"  dape-step-out "Step Out"  nerd-icons-lblue)
    ("nf-cod-debug_restart"   dape-restart  "Restart"   nerd-icons-lgreen)
    ("nf-cod-debug_stop"      dape-quit     "Quit"      nerd-icons-red)))

;; 创建 Dape 调试工具栏缓冲区，并为按钮设置鼠标点击 keymap。
(defun my-dape-toolbar-buf-create ()
  (interactive)
  ;; 创建或获取名为 "*NN Dape Toolbar*" 的缓冲区
  (setq my-dape-toolbar-buf (get-buffer-create "*NN Dape Toolbar*"))
  (with-current-buffer my-dape-toolbar-buf
    (erase-buffer)
    (insert " ")
    ;; 插入一个拖拽柄图标（gripper），并绑定鼠标左键按下来触发自定义的窗口拖拽函数 nn-drag-frame
    (insert-text-button
     (nerd-icons-codicon "nf-cod-gripper" :face 'nerd-icons-dsilver)
     'mouse-face 'highlight
     'keymap (let ((m (make-sparse-keymap)))
               (define-key m [down-mouse-1] #'nn-drag-frame)
               m))
    ;; 循环遍历按钮配置列表，生成每一个调试功能按钮
    (dolist (btn my-dape-toolbar-buttons)
      (let ((icon (nth 0 btn))
            (func (nth 1 btn))
            (tooltip (nth 2 btn))
            (face (nth 3 btn)))
        (insert "  ")
        ;; 插入具有点击交互能力的文本按钮
        (insert-text-button
         (nerd-icons-codicon icon :face face)
         'mouse-face 'highlight
         'help-echo tooltip
         'action `(lambda (_) (call-interactively ',func)))))
    ;; 将该 Buffer 内的光标指针样式全域设置为普通箭头 pointer
    (put-text-property (point-min) (point-max) 'pointer 'arrow)))

;; 在调试开始时显示 Dape 工具栏窗口。
(defun my-dape-toolbar-create ()
  (interactive)
  (my-dape-toolbar-buf-create)
  ;; 创建一个悬浮子窗口 (Child-Frame) 用于放置工具栏
  (setq my-dape-toolbar-frame
        (make-frame
         `((parent-frame . ,(selected-frame))                  ; 绑定为当前主 Frame 的子窗口
           (undecorated . t) (z-group . above)                 ; 无边框装饰，且置顶显示
           (left . 0.5) (top . 0)                              ; 位于顶部水平居中的位置
           (min-width . 0) (min-height . 0)
           (width . 26) (height . 1)                           ; 宽 26 列，高 1 行
           (internal-border-width . 15) (border-width . 3)     ; 内外边距设置
           (left-fringe . 0) (right-fringe . 0)                ; 隐藏左右 fringe 边缘线
           (background-color . ,(face-background 'tooltip))    ; 背景色采用 Tooltip 的配色
           (cursor-type . nil) (minibuffer . nil)              ; 隐藏光标，禁用 minibuffer
           (no-focus-on-map . t) (no-other-window . t))))      ; 避免抢占输入焦点和窗口切换
  ;; 将工具栏 Buffer 渲染到该 Child-Frame 内
  (set-window-buffer (frame-root-window my-dape-toolbar-frame) my-dape-toolbar-buf)
  ;; 清除 child-frame 的边框继承样式
  (set-face-attribute 'child-frame-border my-dape-toolbar-frame :background nil :inherit nil))

;; 调试结束时关闭工具栏窗口并清理其缓冲区。
(defun my-dape-toolbar-close ()
  (interactive)
  (kill-buffer my-dape-toolbar-buf)
  (delete-frame my-dape-toolbar-frame))

;; 列出可附加的系统进程，并把所选进程 ID 交给 Dape。
(defun my-dape-select-process ()
  ;; 调用 Windows 系统命令 "tasklist /FO CSV /NH" 获取系统当前运行进程列表
  (let* ((lines (process-lines "tasklist" "/FO" "CSV" "/NH"))
         ;; 解析 CSV 输出，提取进程名和 PID 并构建成列表对 (名+PID . 数字PID)
         (table (mapcar (lambda (line)
                          (let* ((fields (split-string line "," t))
                                 (name (string-trim (car fields) "\"" "\""))
                                 (pid  (string-trim (cadr fields) "\"" "\"")))
                            (cons (format "%-30s  PID: %s" name pid)
                                  (string-to-number pid))))
                        lines))
         ;; 使用 completing-read 提供补全交互界面供用户选择目标进程
         (choice (completing-read "Selection PID: " table nil t)))
    ;; 返回选中的 PID 数字
    (cdr (assoc choice table))))

;; 配置并加载 dape 调试扩展包
(use-package dape
  :bind
  ("<f5>"    . dape)                   ; F5: 启动调试
  ("S-<f5>"  . dape-quit)              ; Shift+F5: 退出调试
  ("<f9>"    . dape-breakpoint-toggle) ; F9: 切换断点
  ("<f10>"   . dape-next)              ; F10: 单步跳过 (Step Over)
  ("<f11>"   . dape-step-in)           ; F11: 单步进入 (Step Into)
  ("S-<f11>" . dape-step-out)          ; Shift+F11: 单步跳出 (Step Out)
  ("C-<f5>"  . dape-kill)              ; Ctrl+F5: 杀掉调试进程
  :custom
  ;; 指定 Adapter 适配器存放路径
  (dape-adapter-dir (concat nn-directory "dape/adapters/"))
  ;; 指定默认断点保存文件路径
  (dape-default-breakpoints-file (concat nn-directory "dape/breakpoints.eld"))
  ;; 关闭行内变量提示 (Inlay Hints)
  (dape-inlay-hints nil)
  ;; 设置调试面板 Buffer 统一布局在窗口右侧
  (dape-buffer-window-arrangement 'right)
  :config
  ;; 确保 Adapter 存放目录存在
  (make-directory (concat nn-directory "dape/adapters/") t)
  ;; 在 Windows 平台下设置环境变量，强制使用原生 PDB 阅读器（以支持 LLDB 调试）
  (when (eq system-type 'windows-nt)
    (setenv "LLDB_USE_NATIVE_PDB_READER" "1"))

  ;; 挂载生命周期 Hook：调试开始时创建并显示浮动工具栏
  (add-hook 'dape-start-hook #'my-dape-toolbar-create)
  ;; 挂载生命周期 Hook：调试完全停止（dape-active-mode 为 nil）时自动关闭并销毁工具栏
  (add-hook 'dape-active-mode-hook (lambda () (unless dape-active-mode (my-dape-toolbar-close))))
  ;; 移除 dape 默认在 start 时会自动弹出 REPL 窗口的行为
  (remove-hook 'dape-start-hook #'dape-repl)
  ;; 在 dape-configs 中新增一种名为 gdb-attach 的调试模板，专门用于附加到现有的 C/C++ 进程
  (add-to-list 'dape-configs
               '(gdb-attach
                 modes (c-mode c-ts-mode c++-mode c++-ts-mode)
                 command "gdb"
                 command-args ("--interpreter=dap")
                 :request "attach"
                 :pid (my-dape-select-process))))

(provide 'init-debug)
