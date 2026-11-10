;;; init-commenter.el --- Evil Nerd Commenter commands -*- lexical-binding: t; -*-

;; Evil Nerd Commenter provides consistent line, paragraph, copy, and kill
;; commenting commands across programming and text modes.

(defun my-current-line-html-p (paragraph-region)
  (let* ((line (buffer-substring-no-properties (line-beginning-position)
                                               (line-end-position)))
         (re (format "^[ \t]*\\(%s\\)?[ \t]*</?[a-zA-Z]+"
                     (regexp-quote (evilnc-html-comment-start)))))
    ;; current paragraph does contain html tag
    (if (and (>= (point) (car paragraph-region))
             (string-match-p re line))
        t)))

(defun my-evilnc-comment-or-uncomment-paragraphs (&optional num)
  "Comment or uncomment NUM paragraphs which might contain html tags."
  (interactive "p")
  (unless (featurep 'evil-nerd-commenter) (require 'evil-nerd-commenter))
  (let* ((paragraph-region (evilnc--get-one-paragraph-region))
         (html-p (or (save-excursion
                       (sgml-skip-tag-backward 1)
                       (my-current-line-html-p paragraph-region))
                     (save-excursion
                       (sgml-skip-tag-forward 1)
                       (my-current-line-html-p paragraph-region)))))
    (if html-p (evilnc-comment-or-uncomment-html-paragraphs num)
      (evilnc-comment-or-uncomment-paragraphs num))))



;; Register autoloads before the package is first invoked so global bindings
;; and the code-workbench menu remain valid during deferred package loading.
(dolist (command '(evilnc-comment-or-uncomment-lines
                   evilnc-comment-or-uncomment-paragraphs
                   evilnc-comment-or-uncomment-to-the-line
                   evilnc-copy-and-comment-lines
                   evilnc-kill-and-comment-lines
                   evilnc-quick-comment-or-uncomment-to-the-line
                   evilnc-comment-and-kill-ring-save
                   evilnc-comment-or-uncomment-html-tag
                   evilnc-copy-to-line
                   evilnc-kill-to-line
                   evilnc-comment-box))
  (autoload command "evil-nerd-commenter" nil t))

(use-package evil-nerd-commenter
  :straight (:host github :repo "redguardtoo/evil-nerd-commenter")
  :defer t)

;; `M-;' is the primary, mode-independent toggle for the current line(s).
(keymap-global-set "M-;" #'evilnc-comment-or-uncomment-lines)

(defun my/evilnc-copy-and-comment-lines (&optional num)
  "Copy the current line or region to the kill ring, then comment its source.

The package command also inserts an uncommented copy below the source.  This
wrapper preserves that behavior and additionally makes the original text
available to ordinary paste commands." 
  (interactive "p")
  (require 'evil-nerd-commenter)
  (let ((text (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (buffer-substring-no-properties
                 (line-beginning-position) (line-end-position)))))
    (evilnc-copy-and-comment-lines num)
    (kill-new text)))

(provide 'init-commenter)
;;; init-commenter.el ends here
