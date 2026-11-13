;;; init-workbench.el --- Transient 个人工作台与临时窗口管理 -*- lexical-binding: t; -*-

;; 本模块不替换既有快捷键；它把常用命令汇总到一个可发现的菜单，适合不希望
;; 记忆大量按键的使用方式。所有菜单项仍然调用现有模块提供的原始命令。

(require 'transient)
(require 'init-transient-lifecycle)
(eval-when-compile
  ;; 让 `transient-define-prefix' 在受管字节编译期作为宏展开，避免菜单
  ;; 后缀命令被错误地当作变量求值。
  (require 'transient))
(require 'eldoc)
(require 'xref)

;; 这些内置模块按需加载；这里只声明延迟调用的接口供编译器检查。
(defvar ibuffer-use-other-window)
(defvar ibuffer-mode-map)
(declare-function ibuffer-current-buffer "ibuffer" (&optional noerror))
(declare-function ibuffer-visit-buffer "ibuffer" (&optional single))
(declare-function ibuffer-mouse-visit-buffer "ibuffer" (event))
(declare-function eglot-code-actions "eglot" ())

;; 所有 Transient 菜单使用物理 ESC 退出、BS 返回上一级；菜单自身显式
;; 定义的同名键仍可覆盖默认值，不改变原有 C-g 取消命令。
(keymap-set transient-base-map "<escape>" #'transient-quit-one)
(dolist (key '("DEL" "<backspace>" "<delete>"))
  (keymap-set transient-base-map key #'transient-quit-one))

(declare-function hydra-window-resize/body "init-window" ())

;; 独立启动本文件时也保留 C-c 用户前缀；正常启动时该变量已由
;; init-keybindings.el 指向同一个 Emacs 原生 keymap。
(defvar my-leader-map mode-specific-map
  "以 C-c 开始的全局用户命令 keymap。")

(defconst my/workbench-transient-display-buffer-action
  '((display-buffer-below-selected)
    ;; 六个功能分组横向排成一行；保留足够高度显示最长一列的所有子菜单。
    (window-height . 0.38)
    (dedicated . t)
    (inhibit-same-window . t)
    (window-parameters . ((no-other-window . t))))
  "个人工作台专用的宽阔底部 Transient 面板显示规则。")

(defconst my/transient-menu-help-entries
  '(("C-d"   "个人工作台"             "my/workbench-menu"                    "全局开关")
    ("M-c"   "代码工作台"             "my/code-workbench-menu"               "全局开关")
    ("C-w"   "窗口菜单"               "my/window-menu"                       "全局")
    ("M-3"   "Easy Kill 菜单"          "my/easy-kill-menu"                    "全局开关")
    ("C-,"   "多处编辑工作台"            "my/evil-multiedit-workbench/body"      "全局开关")
    ("C-t"   "Smartparens 菜单"         "my/smartparens-workbench/body"         "全局开关")
    ("M-g"   "跳转菜单（含 Avy）"       "goto-map"                           "全局跳转前缀")
    ("M-s"   "搜索与替换菜单"         "my/m-s-search-menu"                   "全局")
    ("C-t"   "Consult 导出结果菜单"   "my/consult-exported-results-menu"     "仅 Export/Collect 结果")
    ("C-c s m" "rg 搜索/替换菜单"     "my/rg-search-menu"                    "搜索前缀")
    ("C-c s a" "Anzu 替换菜单"        "my/anzu-menu"                         "搜索前缀")
    ("C-c c m" "合并冲突菜单"         "my/smerge-menu"                       "代码前缀")
    ("C-c g n" "Diffnav 操作菜单"     "diffnav-emacs-menu"                   "Git 前缀")
    ("C-c g b" "Diffnav 提交比较"     "diffnav-emacs-revision-menu"          "Git 前缀")
    ("C-c g F" "Diffnav 当前文件菜单" "diffnav-emacs-current-file-menu"      "Git 前缀")
    ("C-d j" "Avy 跳转菜单"           "my/avy-transient-menu"                "个人工作台")
    ("C-d =" "Easy Kill 菜单"         "my/easy-kill-menu"                    "个人工作台")
    ("C-d -" "可视书签菜单"           "my/workbench-bm-menu"                 "个人工作台")
    ("C-d p" "View Mode 菜单"         "my/view-mode-menu"                    "个人工作台")
    ("M-c n" "跳转与文档菜单"         "my/workbench-navigation-menu"         "代码工作台")
    ("M-c z" "代码折叠菜单"           "my/workbench-fold-menu"               "代码工作台")
    ("C-w r" "窗口尺寸菜单"           "hydra-window-resize/body"             "窗口菜单子菜单")
    ("C-t e" "Embrace 菜单"           "my/embrace-menu/body"                 "Smartparens 子菜单")
    ("无独立入口" "Consult 搜索历史"    "my/consult-search-history-menu"       "内部菜单")
    ("Pinky 激活时" "Pinky 键位提示"   "my/pinky-transient-menu"              "被动提示面板")
    ("Avy 跳转时" "Avy Dispatch 提示" "my/avy-dispatch-menu"                 "被动提示面板"))
  "自定义 Transient、Hydra 与被动提示面板的入口、名称、命令和适用范围。")

(defvar my/transient-menu-help-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") #'quit-window)
    (define-key map (kbd "<escape>") #'quit-window)
    map)
  "Keymap for `my/transient-menu-help-mode'.")

(define-derived-mode my/transient-menu-help-mode special-mode "Transient 菜单帮助"
  "显示所有自定义 Transient、Hydra 与被动提示面板的入口总览。"
  (setq-local truncate-lines t))

(defun my/transient-menu-help-buffer ()
  "Return a freshly rendered buffer that documents custom Transient menus."
  (let ((buffer (get-buffer-create "*Transient 菜单帮助*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (my/transient-menu-help-mode)
        (insert "自定义 Transient / Hydra 菜单总览\n\n")
        (insert (format "%-10s %-24s %-42s %s\n"
                        "入口" "菜单" "命令" "适用范围"))
        (insert (make-string 96 ?─) "\n")
        (dolist (entry my/transient-menu-help-entries)
          (pcase-let ((`(,key ,name ,command ,scope) entry))
            (insert (format "%-10s %-24s %-42s %s\n"
                            key name command scope))))
        (insert "\nPinky 与 Avy Dispatch 是被动提示面板，仅展示按键，不接管输入。\n")
        (insert "按 q 或 ESC 关闭本帮助。\n")
        (goto-char (point-min))))
    buffer))

(defun my/transient-menu-help ()
  "关闭当前 Transient 后打开自定义菜单入口帮助。"
  (interactive)
  (when (transient-active-prefix)
    (my/transient-force-close :transient-menu-help))
  (pop-to-buffer (my/transient-menu-help-buffer)))

;; Transient 会在打开菜单时校验每个后缀命令。为延迟加载的第三方包预先注册
;; 自动加载，确保 Scratch 等尚未访问过代码/搜索功能的 Buffer 也能打开菜单。
(dolist (command '(consult-find consult-recent-file consult-buffer consult-ripgrep
                   consult-line consult-outline))
  (autoload command "consult" nil t)
  ;; 兼容早期受管字节码中的 Transient 后缀：它们可能将裸命令符号编译为
  ;; 变量引用。函数和值命名空间独立，赋同名符号值不会影响命令调用。
  (unless (boundp command)
    (set command command)))
;; 中文说明：rg.el 的搜索命令按需加载，保证打开工作台不会提前启动
;; ripgrep 子进程；用户选择搜索项时才加载插件。
(dolist (command '(rg-project rg-dwim-current-file))
  (autoload command "rg" nil t)
  (unless (boundp command)
    (set command command)))
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
(autoload 'my/mark-indent-block "init-treesitter" nil t)
(autoload 'my/mark-indent-block-inner "init-treesitter" nil t)
(autoload 'my/apheleia-format-code "init-format" nil t)
(autoload 'my/format-selected-region "init-format" nil t)
(autoload 'my/format-current-indent-region "init-format" nil t)
(autoload 'my/format-current-function "init-format" nil t)
(autoload 'my/select-whole-buffer "init-format" nil t)
(autoload 'my/match-pair "init-mykey" nil t)
(autoload 'my-clean-extra-lines-and-comments "init-mykey" nil t)
(unless (fboundp 'my-evilnc-comment-or-uncomment-paragraphs)
  (autoload 'my-evilnc-comment-or-uncomment-paragraphs "init-commenter" nil t))
(unless (fboundp 'my/evilnc-copy-and-comment-lines)
  (autoload 'my/evilnc-copy-and-comment-lines "init-commenter" nil t))
(dolist (command '(evilnc-comment-or-uncomment-lines
                   evilnc-comment-or-uncomment-html-tag
                   evilnc-comment-or-uncomment-to-the-line
                   evilnc-quick-comment-or-uncomment-to-the-line
                   evilnc-comment-and-kill-ring-save
                   evilnc-copy-to-line
                   evilnc-kill-to-line
                   evilnc-comment-box))
  (unless (fboundp command)
    (autoload command "evil-nerd-commenter" nil t)))
(autoload 'my/toggle-mark-command "init-mykey" nil t)
(autoload 'my/dirvish-open "init-dirvish" nil t)
(autoload 'my/pinky-toggle "init-pinky" nil t)
(autoload 'my/cua-rectangle-toggle "init-edit" nil t)
(autoload 'my/easy-kill-menu "init-easykill" nil t)
(autoload 'my/view-mode-menu "init-edit" nil t)
(autoload 'diffnav-emacs-menu "diffnav-emacs" nil t)
(autoload 'hydra-window-resize/body "init-window" nil t)
(autoload 'zoom-window-zoom "zoom-window" nil t)
;; 中文说明：单独加载工作台时也能显示书签菜单，选中后再加载 bm。
(dolist (command '(bm-toggle bm-next bm-previous bm-show bm-show-all
                   bm-remove-all-current-buffer))
  (autoload command "bm" nil t))
(autoload 'my/bm-clear-all "init-bm" nil t)
(dolist (command '(treesit-fold-toggle treesit-fold-close-all treesit-fold-open-all))
  (autoload command "treesit-fold" nil t))
(dolist (command '(vimish-fold-toggle-all vimish-fold-unfold-all
                  vimish-fold-refold-all vimish-fold-next-fold
                  vimish-fold-previous-fold))
  (autoload command "vimish-fold" nil t))
(autoload 'my/vimish-fold-toggle-at-point "init-fold" nil t)
(autoload 'my/vimish-fold-insert-markers "init-fold" nil t)
(autoload 'my/vimish-fold-delete-markers "init-fold" nil t)
(autoload 'my/vimish-fold-toggle-buffer "init-fold" nil t)

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
  ;; GUI 下物理 <return> 已与 C-m 解耦；Ibuffer 原本只绑定 RET，需显式
  ;; 镜像到物理键，才能继续确认并在原编辑窗口打开选中的 Buffer。
  ;; (define-key ibuffer-mode-map (kbd "<return>")
              ;; #'my/ibuffer-visit-buffer-in-origin-window)
  (define-key ibuffer-mode-map [remap ibuffer-mouse-visit-buffer]
              #'my/ibuffer-mouse-visit-buffer-in-origin-window))

(defun my/workbench-popper-group ()
  "按项目分组 Popper；不在项目中时安全地回退到当前目录。"
  (require 'project)
  (if-let ((current-project (project-current nil)))
      (project-root current-project)
    default-directory))

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

(defun my/workbench-symbol-list ()
  "按需加载 Consult，并搜索当前 Buffer 的符号。"
  (interactive)
  (my/workbench-call-on-demand 'consult 'consult-imenu "符号列表"))

(defun my/workbench-outline-list ()
  "按需加载 Consult，并显示当前 Buffer 的标题或语言符号。"
  (interactive)
  (my/workbench-call-on-demand 'consult 'consult-outline "当前文件大纲"))

(defun my/workbench-imenu-list-toggle ()
  "按需加载并切换 Imenu List 侧栏。"
  (interactive)
  (my/workbench-call-on-demand 'imenu-list 'imenu-list-smart-toggle
                              "Imenu List 侧栏"))

;; 以下小命令是工作台的稳定入口；它们不改变各插件既有的全局短键。
(defun my/workbench-edit-occurrences ()
  "按需启动 Iedit，批量编辑当前符号的匹配项。"
  (interactive)
  (my/workbench-call-on-demand 'iedit 'iedit-mode "Iedit 批量编辑"))

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

(defun my/workbench-compile-current-buffer ()
  "保存并从当前文件所在目录执行既有 `compile-command'。

这不会改写项目的编译命令；只将编译的工作目录确定为当前 Buffer 对应文件的
目录，便于单文件或在子目录中的源码直接调用既有构建规则。"
  (interactive)
  (unless buffer-file-name
    (user-error "当前 Buffer 未访问文件，无法编译"))
  (when (buffer-modified-p)
    (save-buffer))
  (let ((default-directory (file-name-directory buffer-file-name)))
    (compile compile-command)))

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
    ("h" "光标处文档" eldoc)
    ("DEL" "返回个人工作台" transient-quit-one)
    ("C-d" "关闭个人工作台" transient-quit-all)]])

(transient-define-prefix my/workbench-fold-menu ()
  "打开代码结构折叠与手工折叠操作菜单。"
  [["   Tree-sitter 结构折叠"
    ("t" "切换当前结构折叠" treesit-fold-toggle)
    ("c" "折叠全部结构" treesit-fold-close-all)
    ("o" "展开全部结构" treesit-fold-open-all)]
   ["   手工折叠"
    ("i" "插入手工折叠标记" my/vimish-fold-insert-markers)
    ("d" "删除当前手工折叠标记" my/vimish-fold-delete-markers)
    ("f" "切换光标处手工折叠" my/vimish-fold-toggle-at-point)
    ("a" "整篇切换手工折叠" my/vimish-fold-toggle-buffer)
    ("u" "展开全部手工折叠" vimish-fold-unfold-all)
    ("r" "重新折叠全部手工折叠" vimish-fold-refold-all)
    ("n" "下一个手工折叠" vimish-fold-next-fold)
    ("p" "上一个手工折叠" vimish-fold-previous-fold)
    ("DEL" "返回个人工作台" transient-quit-one)
    ("C-d" "关闭个人工作台" transient-quit-all)]])

(transient-define-prefix my/workbench-bm-menu ()
  "打开 bm.el 可视书签菜单。"
  [["   可视书签"
    ("t" "设置/取消行书签" bm-toggle)
    ("n" "下一个书签" bm-next)
    ("p" "上一个书签" bm-previous)]
   ["   查看与整理"
    ("l" "当前文件书签" bm-show)
    ("a" "全部可视书签" bm-show-all)
    ("d" "清空当前文件书签" bm-remove-all-current-buffer)
    ("c" "清空所有可视书签" my/bm-clear-all)
    ("DEL" "返回个人工作台" transient-quit-one)
    ("C-d" "关闭个人工作台" transient-quit-all)]])

(transient-define-prefix my/code-workbench-menu ()
  "打开代码工作台：集中项目、版本控制、代码与诊断操作。"
  :column-widths '(20 20 20 20 20 20)
  [["   项目与版本控制"
    ("p" "切换项目" project-switch-project)
    ("g" "Git 状态" magit-status)
    ("b" "Magit 项目面板" magit-board-open)
    ;; Diffnav 使用终端 TUI 展示文件树与 diff，菜单提供不同范围的浏览操作。
    ("d" "Diffnav 改动浏览" diffnav-emacs-menu)
    ("m" "合并冲突" my/smerge-menu)
    ("f" "当前文件 Git 操作" magit-file-dispatch)]
   ["   格式化与编译"
    ("q" "格式化整个文件" my/apheleia-format-code)
    ("r" "格式化选中区域" my/format-selected-region)
    ("i" "格式化当前缩进区域" my/format-current-indent-region)
    ("u" "格式化当前函数" my/format-current-function)
    ("c" "编译当前 Buffer" my/workbench-compile-current-buffer)
    ("e" "编译" compile)]
   ["   大纲与代码结构"
    ("s" "符号列表" my/workbench-symbol-list)
    ("o" "当前文件大纲" my/workbench-outline-list)
    ("l" "切换 Imenu List 侧栏" my/workbench-imenu-list-toggle)
    ("n" "跳转与文档" my/workbench-navigation-menu)
    ("z" "代码折叠" my/workbench-fold-menu)]
   ["   代码块"
    ("j" "匹配跳转" evilmi-jump-items-native)
    ("v" "选中文本块" evilmi-select-items)
    ("k" "删除文本块" evilmi-delete-items)
    ("h" "高亮当前文本项" evilmi-highlight-items)]
   ["   代码注释"
    ("t" "注释/取消行或选区" evilnc-comment-or-uncomment-lines)
    ("P" "注释/取消当前段落" evilnc-comment-or-uncomment-paragraphs)
    ("H" "注释/取消 HTML 段落" my-evilnc-comment-or-uncomment-paragraphs)
    ("T" "注释/取消 HTML 标签" evilnc-comment-or-uncomment-html-tag)
    ("E" "注释/取消至指定行" evilnc-comment-or-uncomment-to-the-line)
    ("Q" "快速注释至指定行" evilnc-quick-comment-or-uncomment-to-the-line)
    ("Y" "复制、插入并注释" my/evilnc-copy-and-comment-lines)
    ("K" "注释并复制到 Kill Ring" evilnc-comment-and-kill-ring-save)
    ("C" "复制至指定行" evilnc-copy-to-line)
    ("D" "剪切至指定行" evilnc-kill-to-line)
    ("B" "注释框" evilnc-comment-box)
    ("M-;" "注释/取消行或选区" evilnc-comment-or-uncomment-lines)]
   ["   诊断"
    ("x" "当前诊断" flymake-show-buffer-diagnostics)
    ("y" "搜索诊断" my/workbench-project-diagnostics)
    ("a" "代码动作" my/workbench-code-actions)
    ("M-c" "关闭代码工作台" transient-quit-all)
    ("<escape>" "关闭代码工作台" transient-quit-one)]])

(transient-define-prefix my/workbench-menu ()
  "打开个人工作台：将高频操作组织为可见菜单。"
  ;; 中文说明：顶层入口全部使用单字符，先分配 26 个小写字母；功能数量超过
  ;; 小写字母容量时才使用大写字母，减少打开工作台后的连续按键次数。
  ;; 固定每列的最小宽度，让各分组标题和子菜单左边缘一致，并在列间保留留白。
  :column-widths '(22 22 22 22 22)
  ;; 标题预留与“按键 + 空格”相同的宽度，使子菜单的中文描述从标题正下方开始。
  [["   文件"
    ("f" "打开文件（可预览）" consult-find)
    ("r" "最近文件" consult-recent-file)
    ("b" "切换Buffer (含历史)" consult-buffer)
    ("k" "关闭当前 Buffer" kill-current-buffer)
    ("." "当前目录" my/workbench-current-directory)
    ("/" "打开终端" my/workbench-open-terminal)
    ("v" "从磁盘重新加载" revert-buffer)]
   ["   视图"
    ("t" "Treemacs" treemacs)
    ("n" "NeoTree" my/neotree-toggle)
    ("d" "Dirvish" my/dirvish-open)
    ("z" "Zoom Windows" zoom-window-zoom)
    ("p" "View Mode 菜单" my/view-mode-menu)]
   ["   编辑"
    ("j" "Avy 跳转菜单" my/avy-menu)
    ("c" "清理空行与空注释" my-clean-extra-lines-and-comments)
    ("e" "批量编辑符号" my/workbench-edit-occurrences)
    ("h" "匹配成对符号或标签" my/match-pair)
    ("=" "Easy Kill 菜单" my/easy-kill-menu)
    ("a" "可视撤销树" my/workbench-visual-undo)
    ("y" "KillRing历史" my/workbench-clipboard-history)
    ("-" "可视书签" my/workbench-bm-menu)
    ("," "切换 Pinky 模式" my/pinky-toggle)]
   ["   选择"
    ("s" "选择整个文件" my/select-whole-buffer)
    ("u" "向上选择行" my-choose-up-lines)
    ("w" "向下选择行" my-choose-down-lines)
    ("'" "矩形选区" my/cua-rectangle-toggle)
    ("m" "切换标记" my/toggle-mark-command)
    ("[" "选择当前缩进块" my/mark-indent-block)
    ("]" "选择缩进块内部" my/mark-indent-block-inner)]
   ["   笔记与帮助"
    ("l" "新建笔记" org-capture)
    ("g" "查看日程" org-agenda)
    ("?" "Transient 菜单帮助" my/transient-menu-help)
    (";" "上下文动作" my/workbench-context-actions)
    ("!" "当前按键表" describe-bindings)
    ;; 数字 0 易于在最后一列识别，也避免与大写字母 O 混淆。
    ("0" "当前模式帮助" describe-mode)
    ("DEL" "关闭个人工作台" transient-quit-one)
    ("C-d" "关闭个人工作台" transient-quit-all)
    ("<escape>" "关闭个人工作台" transient-quit-one)]])

(defun my/workbench ()
  "打开个人工作台菜单。"
  (interactive)
  ;; 仅影响本工作台，不改变 Magit 等其他 Transient 菜单的窗口布局。
  (let ((transient-display-buffer-action
         my/workbench-transient-display-buffer-action)
        ;; 中文全角字符与 Git 等半角文字混排时，按字符数计算列宽会错位；
        ;; 仅在工作台启用像素级对齐，保证每列标题与描述的实际显示位置一致。
        (transient-align-variable-pitch t))
    (my/transient-open #'my/workbench-menu)))

(defun my/code-workbench ()
  "打开代码工作台菜单。"
  (interactive)
  (let ((transient-display-buffer-action
         my/workbench-transient-display-buffer-action)
        (transient-align-variable-pitch t))
    (my/transient-open #'my/code-workbench-menu)))

(keymap-global-set "M-c" #'my/code-workbench)

(defun my/workbench-toggle ()
  "用 C-d 打开或关闭个人工作台。"
  (interactive)
  (if (transient-active-prefix
       '(my/workbench-menu my/workbench-navigation-menu
         my/workbench-fold-menu my/workbench-bm-menu))
      (my/transient-force-close :workbench-toggle)
    (my/workbench)))

(defvar-local my/workbench-toggle-override-active t
  "非 nil 时让 C-d 个人工作台入口优先于 major-mode keymap。")
(defvar my/workbench-toggle-override-map
  (make-sparse-keymap)
  "个人工作台 C-d 全局入口的高优先级 keymap。")
;; C-d 是全局入口；emulation map 保证 major mode（含 Scratch）不能抢占。
;; 保留 C-c SPC 语义入口，物理 ESC 则统一负责取消或退出。
(with-eval-after-load 'general
  (my-leader-def "SPC" '("个人工作台" . my/workbench))
  (general-define-key "C-d" '("切换个人工作台" . my/workbench-toggle))
  (general-define-key :keymaps 'my/workbench-toggle-override-map
                      "C-d" '("切换个人工作台" . my/workbench-toggle)))
(defvar my/workbench-toggle-emulation-alist
  `((my/workbench-toggle-override-active . ,my/workbench-toggle-override-map))
  "只提升个人工作台 C-d 入口的 emulation keymap alist。")
(add-to-list 'emulation-mode-map-alists 'my/workbench-toggle-emulation-alist)
(with-eval-after-load 'which-key
  ;; 将命令名替换为中文菜单说明，用户在 C-c 提示和按键查询中均可发现工作台。
  (which-key-add-keymap-based-replacements
   my-leader-map "SPC" "个人工作台")
  (which-key-add-keymap-based-replacements
   global-map "C-d" "切换个人工作台")
  (which-key-add-keymap-based-replacements
   global-map "M-c" "代码工作台")
  (which-key-add-keymap-based-replacements
   my/workbench-toggle-override-map "C-d" "切换个人工作台"))

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
  (my-leader-def
    "b p t" '("切换最近弹窗" . my/workbench-toggle-popup)
    "b p n" '("下一个弹窗" . popper-cycle)
    "b p k" '("关闭最近弹窗" . popper-kill-latest-popup)
    "b p m" '("切换弹窗状态" . popper-toggle-type)))

(provide 'init-workbench)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-d' 切换个人工作台，`C-c SPC' 是语义化入口；`ESC' 取消或退出。
;;   子菜单按 BS 返回上一级，根菜单按 BS 关闭；`M-j' 切换 Pinky。
;; - `M-c' 打开代码工作台，其中包含项目/Git、代码与诊断操作；在该菜单中再次
;;   按 `M-c' 关闭。Consult 导出结果 Buffer 的局部 C-t 菜单不受影响。
;; - 顶层菜单采用单字符键，优先使用小写；大写仅用于小写字母耗尽后的少数入口。
;; - “文件与视图”中按 `v' 从磁盘重新加载当前 Buffer；未保存的修改仍会要求确认。
;; - 文件、搜索、代码、编辑、Git、窗口和 Org 操作均复用既有命令及其原有快捷键。
;; - “代码与诊断”按 `q/Q/I/B' 格式化全文件/选区/缩进区域/当前函数。
;; - “编辑与跳转”按 `s' 选择整个文件。
;; - “编辑与跳转”还提供 Iedit、缩进/配对选择、撤销树、可视书签和 Avy。
;; - “文件与视图”中按 `k' 关闭当前 Buffer，按 `w' 切换 Zoom 窗口布局。
;; - “笔记与帮助”中按 `K/E/0' 查询按键、查看当前按键表或模式帮助。
;; - `C-x C-b' 或 `C-c b l' 在底部打开 Ibuffer；`C-c b e' 保留 Electric List。
;;   在 Ibuffer 中按 RET 或鼠标选择后，目标 Buffer 会回到原编辑窗口，弹窗关闭。
;; - `C-c b p t/n/k/m'：切换最近弹窗、轮换弹窗、关闭最近弹窗、切换当前
;;   Buffer 的弹窗身份。普通源码、Treemacs、Magit、Dired/Ranger 不会被接管。
;; - Popper 在启动完成后加载；无法安装时工作台会给出提示，不阻断其他功能。
;;; init-workbench.el ends here
