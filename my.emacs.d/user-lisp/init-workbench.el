;;; init-workbench.el --- Transient 个人工作台与临时窗口管理 -*- lexical-binding: t; -*-

;; 本模块不替换既有快捷键；它把常用命令汇总到一个可发现的菜单，适合不希望
;; 记忆大量按键的使用方式。所有菜单项仍然调用现有模块提供的原始命令。

(require 'transient)
(require 'eldoc)
(require 'xref)

(declare-function hydra-window-resize/body "init-window" ())

;; 独立启动本文件时也保留 C-c 用户前缀；正常启动时该变量已由
;; init-keybindings.el 指向同一个 Emacs 原生 keymap。
(defvar my-leader-map mode-specific-map
  "以 C-c 开始的全局用户命令 keymap。")

(defconst my/workbench-transient-display-buffer-action
  '((display-buffer-in-side-window)
    (side . bottom)
    (slot . 0)
    ;; 六个功能分组横向排成一行；保留足够高度显示最长一列的所有子菜单。
    (window-height . 0.38))
  "个人工作台专用的宽阔底部 Transient 面板显示规则。")

;; Transient 会在打开菜单时校验每个后缀命令。为延迟加载的第三方包预先注册
;; 自动加载，确保 Scratch 等尚未访问过代码/搜索功能的 Buffer 也能打开菜单。
(dolist (command '(consult-find consult-recent-file consult-buffer consult-ripgrep consult-line
                  consult-imenu))
  (autoload command "consult" nil t))
(dolist (command '(magit-status magit-file-dispatch))
  (autoload command "magit" nil t))
(autoload 'treemacs "treemacs" nil t)
(autoload 'flymake-show-buffer-diagnostics "flymake" nil t)
(autoload 'org-capture "org-capture" nil t)
(autoload 'org-agenda "org-agenda" nil t)
;; 中文说明：终端保持延迟加载，工作台在 Scratch 等 Buffer 中打开时不会提前加载
;; vterm 的原生模块；用户选择终端项后才创建 vterm。
(autoload 'vterm "vterm" nil t)
;; 中文说明：这三个命令分别来自后续加载的本地配置或本地插件；注册自动加载
;; 后，Scratch 或单独重载工作台时 Transient 也能先安全展示完整菜单。
(autoload 'my/smerge-menu "init-smerge" nil t)
(autoload 'my/avy-menu "init-avy" nil t)
(autoload 'diffnav-emacs-menu "diffnav-emacs" nil t)
(autoload 'hydra-window-resize/body "init-window" nil t)

(defconst my/workbench-popper-reference-buffers
  '("\\*Help\\*\\'"
    "\\*Warnings\\*\\'"
    "\\*Compile-Log\\*\\'"
    "\\*compilation\\*\\'"
    "\\*Flymake diagnostics.*\\*\\'"
    "\\*Messages\\*\\'"
    "\\*grep\\*\\'"
    "\\*Backtrace\\*\\'"
    "\\*Async Shell Command\\*\\'"
    "\\*Shell Command Output\\*\\'"
    "\\*Ibuffer\\*\\'"
    occur-mode
    compilation-mode
    help-mode
    helpful-mode
    apropos-mode
    Man-mode
    woman-mode
    xref--xref-buffer-mode
    flymake-diagnostics-buffer-mode
    debugger-mode
    backtrace-mode
    ibuffer-mode
    buffer-menu-mode)
  "由工作台交给 Popper 管理的短生命周期 Buffer 规则。")

(defconst my/workbench-buffer-list-display-rule
  '("\\*\\(?:Ibuffer\\|Buffer List\\)\\*\\'"
    (display-buffer-reuse-window display-buffer-in-side-window)
    (side . bottom)
    (slot . 0)
    (window-height . 0.33)
    (body-function . select-window)
    (preserve-size . (nil . t)))
  "Ibuffer 与普通 Buffer List 使用的稳定底部侧窗规则。")

;; Popper 负责识别、隐藏和召回；窗口位置仍由 Emacs 原生规则决定。这样只让
;; Buffer List 固定在底部，不会顺带改变 Help、编译、Magit 等既有布局。
(add-to-list 'display-buffer-alist my/workbench-buffer-list-display-rule)

(defvar-local my/ibuffer-origin-window nil
  "打开当前 Ibuffer 弹窗前选中的编辑窗口。")

(defun my/workbench-ibuffer ()
  "在底部打开 Ibuffer，并记住调用它的编辑窗口。"
  (interactive)
  (let ((origin-window
         (if (and (derived-mode-p 'ibuffer-mode)
                  (window-live-p my/ibuffer-origin-window))
             my/ibuffer-origin-window
           (selected-window))))
    (call-interactively #'ibuffer)
    (when (derived-mode-p 'ibuffer-mode)
      (setq-local my/ibuffer-origin-window origin-window))))

(defun my/ibuffer--visit-in-origin-window (target-buffer &optional single)
  "在来源窗口访问 TARGET-BUFFER，并关闭当前 Ibuffer 弹窗。
SINGLE 非空时继续保持 Ibuffer 原有的只保留一个窗口语义。"
  (let ((origin-window my/ibuffer-origin-window)
        (ibuffer-window (selected-window)))
    (quit-window nil ibuffer-window)
    (when (window-live-p origin-window)
      (select-window origin-window))
    (switch-to-buffer target-buffer)
    (when single
      (delete-other-windows))))

(defun my/ibuffer-visit-buffer-in-origin-window (&optional single)
  "从弹窗 Ibuffer 在原编辑窗口访问当前行的 Buffer。"
  (interactive "P")
  (if (window-live-p my/ibuffer-origin-window)
      (my/ibuffer--visit-in-origin-window (ibuffer-current-buffer t) single)
    ;; 从 M-x ibuffer 等普通入口打开时，没有来源记录，保持原生命令行为。
    (ibuffer-visit-buffer single)))

(defun my/ibuffer-mouse-visit-buffer-in-origin-window (event)
  "用鼠标从弹窗 Ibuffer 在原编辑窗口访问所选 Buffer。"
  (interactive "e")
  (if (window-live-p my/ibuffer-origin-window)
      (progn
        (mouse-set-point event)
        (my/ibuffer--visit-in-origin-window (ibuffer-current-buffer t)))
    (ibuffer-mouse-visit-buffer event)))

;; Ibuffer 默认复用当前源码窗口，绕过 display-buffer-alist。让它使用另一窗口后，
;; 上面的规则才能把列表稳定放到底部，同时保留源码窗口。
(with-eval-after-load 'ibuffer
  (setq ibuffer-use-other-window t)
  (define-key ibuffer-mode-map [remap ibuffer-visit-buffer]
              #'my/ibuffer-visit-buffer-in-origin-window)
  (define-key ibuffer-mode-map [remap ibuffer-mouse-visit-buffer]
              #'my/ibuffer-mouse-visit-buffer-in-origin-window))

(defun my/workbench-popper-group ()
  "按项目分组 Popper；不在项目中时安全地回退到当前目录。"
  (require 'project)
  (if-let ((current-project (project-current nil)))
      (project-root current-project)
    default-directory))

(defun my/workbench-show-outline ()
  "显示当前文件大纲；大纲模块不可用时只给出提示。"
  (interactive)
  (if (fboundp 'my/treemacs-show-current-file-outline)
      (call-interactively #'my/treemacs-show-current-file-outline)
    (message "代码大纲模块尚未加载；请完成 Emacs 启动后再试。")))

(defun my/workbench-code-actions ()
  "在 Eglot 正在管理当前代码 Buffer 时显示代码动作。"
  (interactive)
  (cond
   ((not (bound-and-true-p eglot-managed-mode))
    (message "当前 Buffer 未由 Eglot 管理，暂无代码动作。"))
   ((require 'eglot nil t)
    (call-interactively #'eglot-code-actions))
   (t
    (message "Eglot 尚未可用，无法执行代码动作。"))))

;; 工作台中的编辑命令都经过此包装器调用。这样 Transient 在 Scratch 等没有
;; 提前加载第三方包的 Buffer 中只会展示菜单；真正选择项目时才按需加载插件。
(defun my/workbench-call-on-demand (feature command description)
  "按需加载 FEATURE 后交互执行 COMMAND；不可用时说明 DESCRIPTION 的状态。"
  (interactive)
  (condition-case err
      (cond
       ((fboundp command)
        (call-interactively command))
       ((and (require feature nil t) (fboundp command))
        (call-interactively command))
       (t
        (message "%s尚未安装或加载；其他编辑功能不受影响。" description)))
    (error
     (message "%s暂时不可用：%s" description (error-message-string err)))))

;; 以下小命令是工作台的稳定入口；它们不改变各插件既有的全局短键。
(defun my/workbench-edit-occurrences ()
  "按需启动 Iedit，批量编辑当前符号的匹配项。"
  (interactive)
  (my/workbench-call-on-demand 'iedit 'iedit-mode "Iedit 批量编辑"))

(defun my/workbench-expand-selection ()
  "按语法结构扩展当前选区。"
  (interactive)
  (my/workbench-call-on-demand 'expand-region 'er/expand-region "语义选区扩展"))

(defun my/workbench-contract-selection ()
  "按语法结构缩小当前选区。"
  (interactive)
  (my/workbench-call-on-demand 'expand-region 'er/contract-region "语义选区收缩"))

(defun my/workbench-visual-undo ()
  "打开当前 Buffer 的可视化撤销树。"
  (interactive)
  (my/workbench-call-on-demand 'vundo 'vundo "可视化撤销树"))

(defun my/workbench-quick-jump ()
  "按需启动 Avy 字符跳转。"
  (interactive)
  (my/workbench-call-on-demand 'avy 'avy-goto-char-timer "Avy 快速跳转"))

(defun my/workbench-clipboard-history ()
  "打开 Consult 剪贴历史。"
  (interactive)
  (my/workbench-call-on-demand 'consult 'consult-yank-pop "剪贴历史"))

(defun my/workbench-current-directory ()
  "在 Dired 中打开当前文件所在目录。"
  (interactive)
  (my/workbench-call-on-demand 'dired-x 'dired-jump "当前目录"))

(defun my/workbench-open-terminal ()
  "在当前目录打开 Emacs 配置的 vterm 终端。"
  (interactive)
  ;; 中文说明：复用 init-eshell.el 已配置的 vterm，而非新建 shell/term，确保
  ;; 工作台终端拥有相同的 Bash、原生渲染、滚动历史和退出即关闭行为。
  (my/workbench-call-on-demand 'vterm 'vterm "vterm 终端"))

(defun my/workbench-context-actions ()
  "打开当前目标的 Embark 上下文动作菜单。"
  (interactive)
  (my/workbench-call-on-demand 'embark 'embark-act "上下文动作"))

(defun my/workbench-project-diagnostics ()
  "在补全界面中搜索当前 Buffer 的 Flymake 诊断。"
  (interactive)
  (my/workbench-call-on-demand 'consult 'consult-flymake "诊断搜索"))

(defun my/workbench-toggle-popup ()
  "显示或隐藏最近的 Popper 临时窗口。
若 Popper 尚未可用，只显示提示，不影响当前窗口布局或已有功能。"
  (interactive)
  (condition-case err
      (cond
       ((fboundp 'popper-toggle)
        (call-interactively #'popper-toggle))
       ((require 'popper nil t)
        (call-interactively #'popper-toggle))
       (t
        (message "Popper 尚未安装或加载；其他工作台功能不受影响。")))
    ;; 没有任何可显示的弹窗时，Popper 的不同版本可能发出 user-error 或
    ;; 普通 error；统一转换为提示，避免工作台菜单因临时窗口为空而中断。
    (error
     (message "%s" (error-message-string err)))))

(transient-define-prefix my/workbench-navigation-menu ()
  "打开基于 Eglot/Xref 的代码跳转与文档菜单。"
  [["   Xref 跳转"
    ("d" "跳转到定义" xref-find-definitions)
    ("r" "查找引用" xref-find-references)]
   ["   历史与文档"
    ("b" "返回跳转位置" xref-go-back)
    ("f" "前进跳转位置" xref-go-forward)
    ("h" "光标处文档" eldoc)]])

(transient-define-prefix my/workbench-menu ()
  "打开个人工作台：将高频操作组织为可见菜单。"
  ;; 固定每列的最小宽度，让各分组标题和子菜单左边缘一致，并在列间保留留白。
  :column-widths '(22 22 22 22 22 22)
  ;; 标题预留与“按键 + 空格”相同的宽度，使子菜单的中文描述从标题正下方开始。
  [["   文件与搜索"
    ("f" "打开文件（可预览）" consult-find)
    ("r" "最近文件" consult-recent-file)
    ("b" "切换 Buffer" consult-buffer)
    ("s" "项目搜索" consult-ripgrep)
    ("l" "当前文件搜索" consult-line)
    ("D" "当前目录" my/workbench-current-directory)
    ("y" "剪贴历史" my/workbench-clipboard-history)]
   ["   代码"
    ("i" "符号列表" consult-imenu)
    ("o" "侧栏大纲" my/workbench-show-outline)
    ("d" "当前诊断" flymake-show-buffer-diagnostics)
    ("!" "搜索诊断" my/workbench-project-diagnostics)
    ("a" "代码动作" my/workbench-code-actions)
    ("h" "跳转与文档" my/workbench-navigation-menu)
    ;; 合并冲突在独立 Transient 中操作，工作台只提供统一入口。
    ("M" "合并冲突" my/smerge-menu)
    ("c" "编译" compile)]
   ["   编辑与跳转"
    ("e" "批量编辑符号" my/workbench-edit-occurrences)
    ("x" "扩展选区" my/workbench-expand-selection)
    ("X" "收缩选区" my/workbench-contract-selection)
    ("u" "可视撤销树" my/workbench-visual-undo)
    ("j" "Avy 跳转菜单" my/avy-menu)]
   ["   项目与 Git"
    ("p" "切换项目" project-switch-project)
    ("g" "Git 状态" magit-status)
    ;; Diffnav 使用终端 TUI 展示文件树与 diff，菜单提供不同范围的浏览操作。
    ("v" "Diffnav 改动浏览" diffnav-emacs-menu)
    ("G" "当前文件 Git 操作" magit-file-dispatch)
    ("t" "文件树" treemacs)
    ("T" "打开终端" my/workbench-open-terminal)]
   ["   笔记与临时项"
    ("k" "关闭当前 Buffer" kill-current-buffer)
    ("q" "临时窗口" my/workbench-toggle-popup)
    ("n" "新建笔记" org-capture)
    ("A" "日程" org-agenda)]
   ["   帮助与发现"
    ("?" "查询按键" describe-key)
    ("." "上下文动作" my/workbench-context-actions)
    ("H" "当前按键表" describe-bindings)
    ("K" "当前模式帮助" describe-mode)]])

(defun my/workbench ()
  "打开个人工作台菜单。"
  (interactive)
  ;; 仅影响本工作台，不改变 Magit 等其他 Transient 菜单的窗口布局。
  (let ((transient-display-buffer-action
         my/workbench-transient-display-buffer-action)
        ;; 中文全角字符与 Git 等半角文字混排时，按字符数计算列宽会错位；
        ;; 仅在工作台启用像素级对齐，保证每列标题与描述的实际显示位置一致。
        (transient-align-variable-pitch t))
    (my/workbench-menu)))

;; 保留语义化的 C-c 工作台入口，同时提供更短的 C-z 全局直达键。
(define-key my-leader-map (kbd "SPC") #'my/workbench)
(with-eval-after-load 'which-key
  ;; 将命令名替换为中文菜单说明，用户在 C-c 提示和按键查询中均可发现工作台。
  (which-key-add-keymap-based-replacements
   my-leader-map "SPC" "个人工作台")
  (which-key-add-keymap-based-replacements
   global-map "C-z" "个人工作台"))

;; Popper 仅处理短生命周期的帮助、诊断、搜索、日志和 Buffer List；不把源码、
;; Treemacs、Magit Status、Dired/Ranger 或 Org Agenda 归为弹窗。
(use-package popper
  :straight t
  :commands (popper-toggle popper-cycle popper-toggle-type
                           popper-kill-latest-popup)
  :init
  (setq popper-reference-buffers my/workbench-popper-reference-buffers
        ;; 沿用已有 display-buffer/window 配置，避免 Popper 擅自覆盖布局。
        popper-display-control nil
        ;; 按项目隔离临时窗口；普通帮助 Buffer 则按目录分组，避免报错。
        popper-group-function #'my/workbench-popper-group)
  ;; 启动完成后再加载这个轻量窗口管理器；这样既能跟踪后续弹窗，也不阻塞
  ;; 关键启动路径。刻意不启用 popper-echo-mode，避免占用 tab-line/echo area。
  :hook (after-init . popper-mode))

(with-eval-after-load 'general
  ;; C-z 原本是 suspend-frame；图形 Emacs 中几乎不用，改为工作台直达键。
  (general-define-key
    "C-z" '("个人工作台" . my/workbench))
  (my-leader-def
    "b p t" '("切换最近弹窗" . my/workbench-toggle-popup)
    "b p n" '("下一个弹窗" . popper-cycle)
    "b p k" '("关闭最近弹窗" . popper-kill-latest-popup)
    "b p m" '("切换弹窗状态" . popper-toggle-type)))

(provide 'init-workbench)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-z' 直接打开个人工作台；`C-c SPC' 是保留的语义化菜单入口。
;; - 文件、搜索、代码、编辑、Git、窗口和 Org 操作均复用既有命令及其原有快捷键。
;; - “编辑与跳转”提供 Iedit、语义选区、撤销树和 Avy；现有短键仍可直接使用。
;; - “窗口与笔记”中按 `R' 进入窗口大小调整：`h/l' 缩小/放大宽度，`k/j'
;;   缩小/放大高度，`q' 或 Enter 退出；按 `k' 关闭当前 Buffer。
;; - “帮助与发现”可查询按键、查看当前按键表或模式帮助，适合遗忘快捷键时使用。
;; - 选择“临时窗口”后，Popper 显示或隐藏最近的帮助、编译或诊断类 Buffer。
;; - `C-x C-b' 或 `C-c b l' 在底部打开 Ibuffer；`C-c b e' 保留 Electric List。
;;   在 Ibuffer 中按 RET 或鼠标选择后，目标 Buffer 会回到原编辑窗口，弹窗关闭。
;; - `C-c b p t/n/k/m'：切换最近弹窗、轮换弹窗、关闭最近弹窗、切换当前
;;   Buffer 的弹窗身份。普通源码、Treemacs、Magit、Dired/Ranger 不会被接管。
;; - Popper 在启动完成后加载；无法安装时工作台会给出提示，不阻断其他功能。
;;; init-workbench.el ends here
