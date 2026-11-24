;;; init-dashboard.el --- Startup dashboard -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'project)

(declare-function my/treemacs--workspace-project-for-exact-path "init-lsp" (path))

(defvar my/dashboard-close-after-project-switch nil
  "Dashboard 的项目菜单完成状态清理后需要关闭的缓冲区。")

(defvar my/dashboard-project-switch-active nil
  "非 nil 表示当前通过 Dashboard 的 RET 菜单执行项目命令。")

(defun my/dashboard-project-at-point ()
  "返回 Dashboard 当前项目行的完整目录；其他位置给出明确错误。"
  (unless (and (derived-mode-p 'dashboard-mode)
               (eq (dashboard--current-section) 'projects))
    (user-error "请先将光标移到 Dashboard 的项目行"))
  ;; 项目显示路径可能被缩短；从 widget 的 dashboard-path 属性取真实目录。
  (let ((position (line-beginning-position))
        (end (line-end-position))
        path)
    (while (and (< position end) (not path))
      (setq path (get-text-property position 'dashboard-path)
            position (or (next-single-property-change
                          position 'dashboard-path nil end)
                         end)))
    (unless (stringp path)
      (user-error "请先将光标移到 Dashboard 的项目行"))
    (unless (and (file-directory-p path) (file-readable-p path))
      (user-error "项目目录不存在或不可读取：%s" path))
    path))

(defun my/dashboard-treemacs-project-name (path)
  "为 PATH 生成当前 Treemacs workspace 中不冲突的项目名。"
  (let* ((base (file-name-nondirectory (directory-file-name path)))
         (name base)
         (number 2)
         (projects (treemacs-workspace->projects (treemacs-current-workspace))))
    (while (cl-some (lambda (project)
                      (string= name (treemacs-project->name project)))
                    projects)
      (setq name (format "%s <%d>" base number)
            number (1+ number)))
    name))

(defun my/dashboard-open-project-in-treemacs ()
  "在 Treemacs 中显示 Dashboard 当前项目，并将光标移到项目根。"
  (interactive)
  (let* ((dashboard-window (selected-window))
         (dashboard-buffer (current-buffer))
         (path (my/dashboard-project-at-point))
         (root (treemacs-canonical-path (file-truename path)))
         (existing (my/treemacs--workspace-project-for-exact-path root)))
    ;; 先查所有 workspace，复用已登记项目；新项目交给现有重叠目录处理逻辑。
    (unless existing
      (pcase (treemacs-do-add-project-to-workspace
              root (my/dashboard-treemacs-project-name root))
        (`(success ,_))
        (result (user-error "Treemacs 无法加入项目 %s：%s" root result)))
      (setq existing (my/treemacs--workspace-project-for-exact-path root)))
    (unless existing
      (user-error "Treemacs 未找到项目：%s" root))
    (unless (eq (car existing) (treemacs-current-workspace))
      (treemacs-do-switch-workspace (car existing)))
    (treemacs-select-window)
    (unless (treemacs-goto-file-node root (cdr existing))
      (user-error "Treemacs 未能定位项目根：%s" root))
    ;; 成功进入项目后，将原 Dashboard 窗口换成项目目录的新空缓冲区。
    ;; 此时焦点仍留在 Treemacs，失败路径则保留 Dashboard 供重试。
    (when (window-live-p dashboard-window)
      (let ((replacement
             (generate-new-buffer
              (format "*project: %s*"
                      (file-name-nondirectory (directory-file-name root))))))
        (with-current-buffer replacement
          (setq default-directory (file-name-as-directory root))
          (fundamental-mode))
        (set-window-buffer dashboard-window replacement)))
    ;; `project-switch-project' 的 unwind-protect 还要访问来源缓冲区。
    (if (bound-and-true-p my/dashboard-project-switch-active)
        (setq my/dashboard-close-after-project-switch dashboard-buffer)
      (kill-buffer dashboard-buffer))))

(defun my/dashboard-insert-projects-with-help (list-size)
  "插入项目列表，并在列表正下方显示打开方式。"
  (dashboard-insert-projects list-size)
  (insert (propertize "    项目行：RET 常规打开 · t 在 Treemacs 中打开项目\n"
                      'face 'dashboard-footer-face)))

(defun my/dashboard-switch-project (dir)
  "通过 Dashboard 的项目菜单切换到 DIR，并提供 Treemacs 选项。"
  ;; project.el 的 Choose 菜单由此动态变量构成；只扩展 Dashboard 的 RET 入口。
  (let ((my/dashboard-project-switch-active t)
        (my/dashboard-close-after-project-switch nil)
        (project-switch-commands
         (append project-switch-commands
                 '((my/dashboard-open-project-in-treemacs
                    "在 Treemacs 中打开" ?t)))))
    (project-switch-project dir)
    (when (buffer-live-p my/dashboard-close-after-project-switch)
      (kill-buffer my/dashboard-close-after-project-switch))))

(defun my/dashboard-treemacs-project-roots ()
  "Return the directory roots from all Treemacs workspaces."
  (when (featurep 'treemacs-workspaces)
    (delete-dups
     (cl-loop for workspace in (treemacs-workspaces)
              append (cl-loop for item in (treemacs-workspace->projects workspace)
                              for path = (treemacs-project->path item)
                              when path
                              collect (file-name-as-directory
                                       (expand-file-name path)))))))

(defun my/dashboard-find-treemacs-project (dir)
  "Recognize DIR as part of a Treemacs project when no earlier finder does."
  (let ((directory (file-name-as-directory (expand-file-name dir)))
        (best-root nil))
    (dolist (root (my/dashboard-treemacs-project-roots))
      (when (and (string-prefix-p root directory)
                 (or (null best-root) (> (length root) (length best-root))))
        (setq best-root root)))
    (when best-root
      (cons 'transient best-root))))

(defun my/dashboard-remember-treemacs-project (item)
  "Register Treemacs ITEM with project.el for Dashboard's projects list."
  (let ((path (treemacs-project->path item)))
    (when (and path (file-directory-p path))
      (project-remember-project
       (cons 'transient (file-name-as-directory (expand-file-name path))))
      (when (get-buffer dashboard-buffer-name)
        (dashboard-insert-startupify-lists t)))))

(defun my/dashboard-sync-treemacs-projects ()
  "Register projects already saved in all Treemacs workspaces."
  (treemacs--maybe-load-workspaces)
  (dolist (workspace (treemacs-workspaces))
    (dolist (item (treemacs-workspace->projects workspace))
      (my/dashboard-remember-treemacs-project item))))

(defun my/dashboard-goto-first-project ()
  "默认定位到首个项目；无项目时定位到最近文件。"
  (cond (dashboard-projects-alist (dashboard-jump-to-projects))
        ((fboundp 'dashboard-jump-to-recents)
         (dashboard-jump-to-recents))))

(use-package dashboard
  :straight (:host github :repo "emacs-dashboard/dashboard")
  ;; `use-package-always-defer' is enabled globally; install startup hooks now.
  :demand t
  :init
  (setq dashboard-startup-banner
        (expand-file-name "image/dashboard.jpg" user-emacs-directory)
        dashboard-image-banner-max-width 300
        dashboard-image-banner-max-height 300
        dashboard-banner-logo-title "**-- Welcome to my turf! --**"
        dashboard-footer-messages '("AI/BIBI is cheap，show me the code！")
        dashboard-projects-backend 'project-el
        dashboard-projects-switch-function #'my/dashboard-switch-project
        dashboard-items '((projects . 10)
                          (recents . 15)
                          (bookmarks . 5)))
  :config
  ;; 用原项目 widget 的包装器把快捷键提示放在项目行旁边，避免页尾不可见。
  (setf (alist-get 'projects dashboard-item-generators)
        #'my/dashboard-insert-projects-with-help)
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook #'my/dashboard-goto-first-project)
  ;; Treemacs keeps a separate project list; load it before Dashboard renders.
  (require 'treemacs)
  (add-hook 'project-find-functions #'my/dashboard-find-treemacs-project t)
  (add-hook 'treemacs-create-project-functions
            #'my/dashboard-remember-treemacs-project)
  (my/dashboard-sync-treemacs-projects))

;; j/k 沿用 Dashboard 原生逐项移动；C-n/C-p 继续使用插件原有绑定。
;; t 只在 Dashboard 生效；项目分组原有 p/P 导航及 RET 打开保持原样。
(with-eval-after-load 'general
  (general-define-key :keymaps 'dashboard-mode-map
                      "j" '("下移" . dashboard-next-line)
                      "k" '("上移" . dashboard-previous-line)
                      "t" '("在 Treemacs 中打开项目" . my/dashboard-open-project-in-treemacs)))
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
   dashboard-mode-map
   "j" "下移"
   "k" "上移"
   "t" "在 Treemacs 中打开项目"))

(provide 'init-dashboard)
;;; init-dashboard.el ends here
