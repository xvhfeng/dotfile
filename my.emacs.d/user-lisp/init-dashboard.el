;;; init-dashboard.el --- Startup dashboard -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'project)

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

(defun my/dashboard-goto-first-recent-file ()
  "Place point on the first recent-file entry in Dashboard."
  (when (fboundp 'dashboard-jump-to-recents)
    (dashboard-jump-to-recents)))

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
        dashboard-items '((recents . 15)
                          (bookmarks . 5)
                          (projects . 7)))
  :config
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook #'my/dashboard-goto-first-recent-file)
  ;; Treemacs keeps a separate project list; load it before Dashboard renders.
  (require 'treemacs)
  (add-hook 'project-find-functions #'my/dashboard-find-treemacs-project t)
  (add-hook 'treemacs-create-project-functions
            #'my/dashboard-remember-treemacs-project)
  (my/dashboard-sync-treemacs-projects))

(provide 'init-dashboard)
;;; init-dashboard.el ends here
