;;; init-filemanage-test.el --- Tests for Neotree configuration -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'neotree)

(load (expand-file-name "user-lisp/init-filemanage.el"
                        user-emacs-directory)
      nil t)

(ert-deftest nn-neotree-graphical-theme-renders-with-installed-icons ()
  (cl-letf (((symbol-function 'display-graphic-p)
             (lambda (&optional _frame) t)))
    (load (expand-file-name "user-lisp/init-filemanage.el"
                            user-emacs-directory)
          nil t)
    (should (eq neo-theme 'nerd-icons))
    (with-temp-buffer
      (nn-neotree-setup-buffer)
      (should (equal nerd-icons-font-family
                     "JetBrainsMono Nerd Font Mono"))
      (neo-buffer--insert-fold-symbol 'close user-emacs-directory)
      (should (> (buffer-size) 0)))))

(ert-deftest nn-neotree-lists-files ()
  (let ((neo-theme 'nerd-icons))
    (save-window-excursion
      (unwind-protect
          (progn
            (neotree-dir user-emacs-directory)
            (with-current-buffer neo-buffer-name
              (should (derived-mode-p 'neotree-mode))
              (should (string-match-p "init\\.el" (buffer-string)))
              (should (string-match-p "user-lisp" (buffer-string)))))
        (when (get-buffer neo-buffer-name)
          (kill-buffer neo-buffer-name))))))

(ert-deftest nn-neotree-enter-works-from-line-indentation ()
  (let ((neo-theme 'arrow))
    (save-window-excursion
      (unwind-protect
          (progn
            (neotree-dir user-emacs-directory)
            (with-current-buffer neo-buffer-name
              (goto-char (point-min))
              (search-forward "user-lisp")
              (beginning-of-line)
              (let ((directory (expand-file-name "user-lisp"
                                                 user-emacs-directory)))
                (should-not (neo-buffer--expanded-node-p directory))
                (nn-neotree-enter)
                (should (neo-buffer--expanded-node-p directory)))))
        (when (get-buffer neo-buffer-name)
          (kill-buffer neo-buffer-name))))))

(ert-deftest nn-neotree-window-can-be-resized ()
  (let ((neo-theme 'arrow)
        (neo-window-width 25))
    (save-window-excursion
      (unwind-protect
          (progn
            (neotree-dir user-emacs-directory)
            (let ((old-width (window-width
                              (get-buffer-window neo-buffer-name))))
              (nn-neotree-enlarge)
              (should (> (window-width (get-buffer-window neo-buffer-name))
                         old-width))))
        (when (get-buffer neo-buffer-name)
          (kill-buffer neo-buffer-name))))))

(ert-deftest nn-neotree-backspace-selects-parent-node ()
  (let ((neo-theme 'arrow))
    (save-window-excursion
      (unwind-protect
          (progn
            (neotree-dir user-emacs-directory)
            (neotree-find (expand-file-name "user-lisp/init-filemanage.el"
                                            user-emacs-directory))
            (with-current-buffer neo-buffer-name
              (call-interactively
               (key-binding (kbd "<backspace>")))
              (should (equal (neo-buffer--get-filename-current-line)
                             (expand-file-name "user-lisp"
                                               user-emacs-directory)))))
        (when (get-buffer neo-buffer-name)
          (kill-buffer neo-buffer-name))))))

(provide 'init-filemanage-test)
;;; init-filemanage-test.el ends here
