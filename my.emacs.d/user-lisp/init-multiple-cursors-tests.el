;;; init-multiple-cursors-tests.el --- Tests for Multiple Cursors startup -*- lexical-binding: t; -*-

(require 'ert)

(defconst my/multiple-cursors-test-directory
  (file-name-directory (or load-file-name buffer-file-name)))

(defun my/multiple-cursors-test-init-text ()
  "Return the contents of the user init file."
  (with-temp-buffer
    (insert-file-contents (expand-file-name "../init.el"
                                            my/multiple-cursors-test-directory))
    (buffer-string)))

(ert-deftest my/multiple-cursors-is-the-only-loaded-multiedit-backend ()
  "Startup enables Multiple Cursors instead of Evil Multiedit."
  (let ((init-text (my/multiple-cursors-test-init-text)))
    (should (string-match-p "^[[:space:]]*init-multiple-cursors$" init-text))
    (should-not (string-match-p "^[[:space:]]*init-evil-multiedit$" init-text))))

;;; init-multiple-cursors-tests.el ends here
