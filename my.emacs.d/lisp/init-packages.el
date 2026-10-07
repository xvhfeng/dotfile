;;; init-packages.el --- Deterministic package bootstrap -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'package)
(require 'package-vc)

(defvar nn-package-elpa-packages
  '(ace-window apheleia bufler calfw calfw-org citre colorful-mode
    corfu dape editorconfig emmet-mode ghostel indent-bars magit
    markdown-ts-mode multiple-cursors neotree nerd-icons nerd-icons-corfu
    olivetti org-modern posframe powershell rainbow-delimiters rg
    symbol-overlay telega web-mode wgrep yaml-ts-mode yasnippet)
  "ELPA packages required by this configuration.")

(defvar nn-package-vc-packages
  '((color-picker :url "https://github.com/zHaOdANiuu/color-picker.el")
    (material-icon :url "https://github.com/zHaOdANiuu/material-icon.el"))
  "VC packages required by this configuration.")

(defun nn-package-installed-p (package)
  "Return non-nil when PACKAGE is installed or built into Emacs."
  (or (package-installed-p package)
      (package-built-in-p package)))

(defun nn-package-clear-inherited-proxy ()
  "Use direct network access while bootstrapping packages.

The configuration's interactive proxy support is controlled separately by
`nn-proxy-enable'.  Clearing inherited shell proxy variables avoids a stale
local proxy preventing the first package installation."
  (dolist (variable '("HTTP_PROXY" "HTTPS_PROXY" "ALL_PROXY"
                      "http_proxy" "https_proxy" "all_proxy"))
    (setenv variable nil))
  (setq url-proxy-services nil))

(defun nn-package-discard-incomplete-vc-checkout (spec)
  "Remove the empty source checkout left by an interrupted VC installation.

Only a package directory containing no Emacs Lisp source file is removed;
existing usable checkouts are never touched."
  (let* ((package (car spec))
         (directory (expand-file-name (symbol-name package) package-user-dir))
         (sources (and (file-directory-p directory)
                       (directory-files directory nil "\\.el\\'" t))))
    (when (and (file-directory-p directory) (null sources))
      (message "Removing incomplete VC checkout: %s" directory)
      (delete-directory directory t))))

(defun nn-bootstrap-packages ()
  "Install all configured packages before loading feature modules.

Signal one error containing every failed package instead of continuing with a
partially initialized configuration."
  (package-initialize)
  (let* ((missing-elpa
          (cl-remove-if #'nn-package-installed-p nn-package-elpa-packages))
         (missing-vc
          (cl-remove-if (lambda (spec) (nn-package-installed-p (car spec)))
                        nn-package-vc-packages))
         (failures nil))
    (when missing-elpa
      (nn-package-clear-inherited-proxy)
      (condition-case err
          (package-refresh-contents)
        (error (push (cons 'package-archives err) failures)))
      (unless failures
        (dolist (package missing-elpa)
          (condition-case err
              (package-install package)
            (error (push (cons package err) failures))))))
    (when (and missing-vc (not failures))
      (dolist (spec missing-vc)
        (condition-case err
            (progn
              (nn-package-discard-incomplete-vc-checkout spec)
              (package-vc-install spec))
          (error (push (cons (car spec) err) failures)))))
    (if failures
        (error "Package bootstrap failed: %s"
               (mapconcat (lambda (failure)
                            (format "%s (%s)" (car failure)
                                    (error-message-string (cdr failure))))
                          (nreverse failures) "; "))
      nil)))

(defun nn-disable-truncation-fringe-indicator ()
  "Hide the truncation indicator when this Emacs provides one."
  (when-let ((entry (assq 'truncation fringe-indicator-alist)))
    (setcdr entry '(nil nil))))

(provide 'init-packages)
;;; init-packages.el ends here
