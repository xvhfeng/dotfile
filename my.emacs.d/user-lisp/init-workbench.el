;;; init-workbench.el --- Transient 个人工作台与临时窗口管理 -*- lexical-binding: t; -*-

;; 本模块不替换既有快捷键；它把常用命令汇总到一个可发现的菜单，适合不希望
;; 记忆大量按键的使用方式。所有菜单项仍然调用现有模块提供的原始命令。

(require 'transient)

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
(dolist (command '(consult-recent-file consult-buffer consult-ripgrep consult-line
                  consult-imenu))
  (autoload command "consult" nil t))
(dolist (command '(magit-status magit-file-dispatch))
  (autoload command "magit" nil t))
(autoload 'treemacs "treemacs" nil t)
(autoload 'flymake-show-buffer-diagnostics "flymake" nil t)
(autoload 'org-capture "org-capture" nil t)
(autoload 'org-agenda "org-agenda" nil t)

(defconst my/workbench-popper-reference-buffers
  '("\\*Help\\*"
    "\\*Warnings\\*"
    "\\*Compile-Log\\*"
    "\\*compilation\\*"
    "\\*Flymake diagnostics.*\\*"
    "\\*Messages\\*"
    "\\*grep\\*"
    occur-mode
    compilation-mode
    help-mode)
  "由工作台交给 Popper 管理的短生命周期 Buffer 规则。")

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
  ;; use-package 的 :commands 会先安装自动加载定义；优先调用它，确保
  ;; straight.el 已构建但尚未加入 load-path 的场景也能正确按需加载 Popper。
  (condition-case err
      (cond
       ((fboundp 'popper-toggle-latest)
        (call-interactively #'popper-toggle-latest))
       ((require 'popper nil t)
        (call-interactively #'popper-toggle-latest))
       (t
        (message "Popper 尚未安装或加载；其他工作台功能不受影响。")))
    ;; 没有任何可显示的弹窗时，Popper 的不同版本可能发出 user-error 或
    ;; 普通 error；统一转换为提示，避免工作台菜单因临时窗口为空而中断。
    (error
     (message "%s" (error-message-string err)))))

(transient-define-prefix my/workbench-menu ()
  "打开个人工作台：将高频操作组织为可见菜单。"
  ;; 固定每列的最小宽度，让各分组标题和子菜单左边缘一致，并在列间保留留白。
  :column-widths '(22 22 22 22 22 22)
  ;; 标题预留与“按键 + 空格”相同的宽度，使子菜单的中文描述从标题正下方开始。
  [["   文件与搜索"
    ("f" "打开文件" find-file)
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
    ("c" "编译" compile)]
   ["   编辑与跳转"
    ("e" "批量编辑符号" my/workbench-edit-occurrences)
    ("x" "扩展选区" my/workbench-expand-selection)
    ("X" "收缩选区" my/workbench-contract-selection)
    ("u" "可视撤销树" my/workbench-visual-undo)
    ("j" "快速跳转" my/workbench-quick-jump)]
   ["   项目与 Git"
    ("p" "切换项目" project-switch-project)
    ("g" "Git 状态" magit-status)
    ("G" "当前文件 Git 操作" magit-file-dispatch)
    ("t" "文件树" treemacs)]
   ["   窗口与笔记"
    ("w" "切换窗口" other-window)
    ("m" "最大化当前窗口" delete-other-windows)
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

;; 只增加一个全局入口；Which-Key 会将其作为 C-c 菜单中的可见项目展示。
(define-key my-leader-map (kbd "SPC") #'my/workbench)
(with-eval-after-load 'which-key
  ;; 将命令名替换为中文菜单说明，用户在 C-c 提示中即可发现工作台。
  (which-key-add-keymap-based-replacements
   my-leader-map "SPC" "个人工作台"))

;; Popper 仅处理短生命周期的帮助、诊断和编译类 Buffer；不把源码、Treemacs、
;; Magit Status 等主工作 Buffer 归为弹窗，从而避免改变既有布局。
(setq popper-reference-buffers my/workbench-popper-reference-buffers
      ;; 沿用已有 display-buffer/window 配置，避免 Popper 擅自覆盖布局。
      popper-display-control nil
      ;; 按项目隔离临时窗口；普通帮助 Buffer 则按目录分组，避免报错。
      popper-group-function #'my/workbench-popper-group)

;; Popper 已安装在 straight 的本地构建目录；这里只注册自动加载，不在启动时
;; 触发网络访问或克隆。若用户将来删除该包，工作台命令会安全提示而非报错。
(let ((popper-build-directory
       (expand-file-name "straight/build/popper/" user-emacs-directory)))
  (when (file-directory-p popper-build-directory)
    (add-to-list 'load-path popper-build-directory)
    (autoload 'popper-toggle-latest "popper" nil t)))

(with-eval-after-load 'popper
  ;; 仅在 Popper 真正加载后开启，避免启动阶段创建额外窗口。
  ;; 不启用 popper-echo-mode，避免它关闭用户可能已使用的 tab-line 模式。
  (popper-mode 1))

(provide 'init-workbench)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c SPC' 打开工作台；无需记住菜单内按键，直接查看 Transient 提示即可。
;; - 文件、搜索、代码、编辑、Git、窗口和 Org 操作均复用既有命令及其原有快捷键。
;; - “编辑与跳转”提供 Iedit、语义选区、撤销树和 Avy；现有短键仍可直接使用。
;; - “帮助与发现”可查询按键、查看当前按键表或模式帮助，适合遗忘快捷键时使用。
;; - 选择“临时窗口”后，Popper 显示或隐藏最近的帮助、编译或诊断类 Buffer。
;; - Popper 首次按需加载；无法安装时只给出提示，不阻断编辑、LSP 或 Flymake。
;;; init-workbench.el ends here
