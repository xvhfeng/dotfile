;;; magit-board.el --- Persistent Magit repository board -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'tabulated-list)
(require 'subr-x)

(defvar magit-board-storage-file nil "Persistent project data file.")
(defvar magit-board-projects nil "Project records as plists with :name and :path.")
(defconst magit-board-buffer-name "*Magit Board*")

(defun magit-board--git-root (directory)
  "Return DIRECTORY's Git root, or signal a user error."
  (let ((root (locate-dominating-file (expand-file-name directory) ".git")))
    (unless root (user-error "%s 不是 Git 项目" directory))
    (file-truename root)))

(defun magit-board-load-projects ()
  "Load projects from `magit-board-storage-file'."
  (setq magit-board-projects
        (if (and magit-board-storage-file (file-exists-p magit-board-storage-file))
            (with-temp-buffer (insert-file-contents magit-board-storage-file) (read (current-buffer)))
          nil)))

(defun magit-board-save-projects ()
  "Persist `magit-board-projects'."
  (unless magit-board-storage-file (user-error "未配置 Magit Board 存储文件"))
  (make-directory (file-name-directory magit-board-storage-file) t)
  (with-temp-file magit-board-storage-file (prin1 magit-board-projects (current-buffer))))

(defun magit-board-current-project ()
  "Return the project record on the current Board row."
  (let ((id (tabulated-list-get-id)))
    (or (cl-find id magit-board-projects :key (lambda (p) (plist-get p :path)) :test #'equal)
        (user-error "当前行没有项目"))))

(defun magit-board-refresh ()
  "Refresh the Board table."
  (interactive)
  (setq tabulated-list-entries
        (mapcar (lambda (project)
                  (let ((path (plist-get project :path)))
                    (list path (vector (plist-get project :name) path))))
                magit-board-projects))
  (tabulated-list-print t))

(define-derived-mode magit-board-mode tabulated-list-mode "Magit-Board"
  "Read-only Git project board."
  (setq tabulated-list-format [("Name" 28 t) ("Path" 0 t)]
        tabulated-list-padding 2)
  (tabulated-list-init-header))

(defun magit-board-add-project (directory name)
  "Add Git DIRECTORY using NAME, defaulting to its basename."
  (interactive (list (read-directory-name "Git 目录: ") (read-string "Name: ")))
  (let* ((path (magit-board--git-root directory))
         (name (if (string-empty-p name) (file-name-nondirectory (directory-file-name path)) name)))
    (when (cl-find path magit-board-projects :key (lambda (p) (plist-get p :path)) :test #'equal)
      (user-error "项目已存在：%s" path))
    (push (list :name name :path path) magit-board-projects)
    (magit-board-save-projects) (magit-board-refresh)))

(defun magit-board-edit-project (directory)
  "Relocate the current project while retaining its name."
  (interactive (list (read-directory-name "新的 Git 目录: ")))
  (let ((project (magit-board-current-project)))
    (setf (plist-get project :path) (magit-board--git-root directory))
    (magit-board-save-projects) (magit-board-refresh)))

(defun magit-board-delete-project ()
  "Delete the project on the current row after confirmation."
  (interactive)
  (let ((project (magit-board-current-project)))
    (when (y-or-n-p (format "删除项目 %s？" (plist-get project :name)))
      (setq magit-board-projects (delq project magit-board-projects))
      (magit-board-save-projects) (magit-board-refresh))))

(defun magit-board-status ()
  "Open Magit Status for the current Board project."
  (interactive)
  (let ((default-directory (plist-get (magit-board-current-project) :path)))
    (magit-status-setup-buffer default-directory)))

(defun magit-board-log ()
  "Open Magit Log for the current Board project."
  (interactive)
  (let ((default-directory (plist-get (magit-board-current-project) :path)))
    (magit-log-current)))

(dolist (binding '(("j" . next-line) ("k" . previous-line)
                   ("a" . magit-board-add-project) ("m" . magit-board-edit-project)
                   ("d" . magit-board-delete-project) ("RET" . magit-board-status)
                   ("<return>" . magit-board-status) ("l" . magit-board-log)
                   ("g" . magit-board-refresh) ("q" . quit-window)
                   ("?" . describe-mode)))
  (define-key magit-board-mode-map (kbd (car binding)) (cdr binding)))

(defun magit-board-open ()
  "Display the Magit Board."
  (interactive)
  (magit-board-load-projects)
  (let ((buffer (get-buffer-create magit-board-buffer-name)))
    (with-current-buffer buffer (magit-board-mode) (magit-board-refresh))
    (pop-to-buffer buffer)))

(provide 'magit-board)
