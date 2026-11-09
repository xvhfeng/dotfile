;;; init-window-tests.el --- Tests for window navigation -*- lexical-binding: t; -*-

(require 'ert)
(add-to-list 'load-path (file-name-directory load-file-name))

;; Load the navigation helpers without loading third-party packages.
(defmacro use-package (_name &rest args)
  (when (eq _name 'hydra)
    `(progn ,(plist-get args :config))))

(defmacro defhydra (name &rest _heads)
  `(defun ,(intern (concat (symbol-name name) "/body")) ()
     (interactive)))
(load (expand-file-name "init-window.el" (file-name-directory load-file-name))
      nil nil t)

(defmacro my/window-test-with-treemacs-layout (&rest body)
  "Run BODY with a left side window and two vertically stacked editor windows."
  (declare (indent 0) (debug t))
  `(save-window-excursion
     (delete-other-windows)
     (switch-to-buffer (get-buffer-create " *window-test-top*"))
     (let ((bottom (split-window-below)))
       (with-selected-window bottom
         (switch-to-buffer (get-buffer-create " *window-test-bottom*")))
       (let ((tree (display-buffer-in-side-window
                    (get-buffer-create " *window-test-treemacs*")
                    '((side . left)))))
         ,@body))))

(ert-deftest my/window-select-wrap-leaves-treemacs-side-window-vertically ()
  "Vertical navigation from a full-height side window enters the editor area."
  (my/window-test-with-treemacs-layout
    (select-window tree)
    (my/window-select-down)
    (should (eq (selected-window) bottom))
    (select-window tree)
    (my/window-select-up)
    (should (eq (selected-window)
                (get-buffer-window " *window-test-top*")))))

(ert-deftest my/window-menu-is-a-hydra ()
  "C-w starts the persistent window Hydra rather than a Transient prefix."
  (should (eq (key-binding (kbd "C-w")) #'hydra-window-menu/body))
  (should (fboundp 'hydra-window-menu/body))
  (should-not (fboundp 'my/window-menu))
  (should-not (fboundp 'my/window-menu-open)))

;;; init-window-tests.el ends here
