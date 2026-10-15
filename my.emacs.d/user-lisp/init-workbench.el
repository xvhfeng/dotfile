;;; init-workbench.el --- Transient 个人工作台与临时窗口管理 -*- lexical-binding: t; -*-

;; 本模块不替换既有快捷键；它把常用命令汇总到一个可发现的菜单，适合不希望
;; 记忆大量按键的使用方式。所有菜单项仍然调用现有模块提供的原始命令。

(require 'transient)

;; 独立启动本文件时也保留 C-c 用户前缀；正常启动时该变量已由
;; init-keybindings.el 指向同一个 Emacs 原生 keymap。
(defvar my-leader-map mode-specific-map
  "以 C-c 开始的全局用户命令 keymap。")

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
  [["文件与搜索"
    ("f" "打开文件" find-file)
    ("r" "最近文件" consult-recent-file)
    ("b" "切换 Buffer" consult-buffer)
    ("s" "项目搜索" consult-ripgrep)
    ("l" "当前文件搜索" consult-line)]
   ["代码"
    ("i" "符号列表" consult-imenu)
    ("o" "侧栏大纲" my/workbench-show-outline)
    ("d" "当前诊断" flymake-show-buffer-diagnostics)
    ("a" "代码动作" my/workbench-code-actions)
    ("c" "编译" compile)]
   ["项目与 Git"
    ("p" "切换项目" project-switch-project)
    ("g" "Git 状态" magit-status)
    ("G" "当前文件 Git 操作" magit-file-dispatch)
    ("t" "文件树" treemacs)]
   ["窗口与笔记"
    ("w" "切换窗口" other-window)
    ("m" "最大化当前窗口" delete-other-windows)
    ("q" "临时窗口" my/workbench-toggle-popup)
    ("n" "新建笔记" org-capture)
    ("A" "日程" org-agenda)]])

(defun my/workbench ()
  "打开个人工作台菜单。"
  (interactive)
  (my/workbench-menu))

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
;; - 文件、搜索、代码、Git、窗口和 Org 操作均复用既有命令及其原有快捷键。
;; - 选择“临时窗口”后，Popper 显示或隐藏最近的帮助、编译或诊断类 Buffer。
;; - Popper 首次按需加载；无法安装时只给出提示，不阻断编辑、LSP 或 Flymake。
;;; init-workbench.el ends here
