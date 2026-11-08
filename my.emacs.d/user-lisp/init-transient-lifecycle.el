;;; init-transient-lifecycle.el --- Safe custom Transient lifecycle -*- lexical-binding: t; -*-

;; 所有自定义 Transient 的根菜单在切换时必须先同步结束旧会话；但父子菜单的
;; 栈由 Transient 自己维护，不能在子菜单进入或返回时被强行清空。

(require 'transient)

(defvar transient--buffer)
(defvar transient--prefix)
(defvar transient--stack)
(defvar transient-current-command)
(defvar transient--original-window)

(defvar my/transient--force-closing nil
  "Non-nil while `my/transient-force-close' is cleaning up a menu.")

;; A below-selected window always consumes layout space from the current
;; editor.  Unlike an overlay/popup, it guarantees that visible text ends
;; exactly above the Transient menu.
(setq transient-display-buffer-action
      '(display-buffer-below-selected
        (window-height . 0.28)
        (dedicated . t)
        (inhibit-same-window . t)
        (window-parameters . ((no-other-window . t)))))
(defvar-local my/transient-viewport-padding nil
  "Display-only end padding used while an active Transient protects point.")

(defun my/transient--clear-viewport-padding ()
  "Remove temporary end padding from the original editing buffer."
  (when (overlayp my/transient-viewport-padding)
    (delete-overlay my/transient-viewport-padding))
  (setq my/transient-viewport-padding nil))

(defun my/transient-ensure-origin-point-visible (&rest _)
  "Keep the original editing point clear of a newly shown side-window menu.

This runs only for an active interactive Transient.  It never changes point
or mark; if the available editing area became too small, it scrolls the
original window while preserving the user's selection."
  (when (and (transient-active-prefix)
             (window-live-p transient--original-window))
    (let* ((window transient--original-window)
           (buffer (window-buffer window)))
      (with-current-buffer buffer
        (let* ((point (window-point window))
               (safety (+ scroll-margin 2))
               (remaining (count-lines point (point-max))))
          ;; Near EOF, add virtual lines so Emacs can still scroll the point
          ;; above the bottom side window.  This never inserts file contents.
          (when (< remaining safety)
            (my/transient--clear-viewport-padding)
            (setq my/transient-viewport-padding
                  (make-overlay (point-max) (point-max) buffer nil t))
            (overlay-put my/transient-viewport-padding 'after-string
                         (make-string (+ (window-body-height window) safety) ?\n)))
          (when (or (not (pos-visible-in-window-p point window))
                    (< (count-screen-lines point (window-end window t) nil window)
                       safety))
            (with-selected-window window
              (save-mark-and-excursion
                (goto-char point)
                ;; Keep point in the upper third, leaving ample text above
                ;; the bottom Transient side window.
                (recenter (max safety (/ (window-body-height window) 3)))))))))))

(defun my/transient-managed-prefix-p (prefix)
  "Return non-nil when PREFIX is a lifecycle-managed custom Transient."
  (and (symbolp prefix)
       (string-match-p "\\`\\(?:my/\\|diffnav-emacs-\\)" (symbol-name prefix))))

(defun my/transient-force-close (&optional reason)
  "Synchronously and completely close the active Transient session.

REASON is forwarded to Transient's emergency-exit diagnostic path.  This
function intentionally clears a root menu and its stack; callers must not use
it while entering or returning from a child menu."
  (interactive)
  (let ((my/transient--force-closing t))
    (when (or transient--prefix (transient-active-prefix))
      (transient--emergency-exit (or reason :my-force-close)))
    ;; An interrupted setup can leave only the stack behind.  It is safe to
    ;; discard such a stack only after no active prefix remains.
    (unless (or transient--prefix (transient-active-prefix))
      (setq transient--stack nil)
      (when-let ((buffer (and (boundp 'transient--buffer)
                              transient--buffer))
                 (window (and (buffer-live-p buffer)
                              (get-buffer-window buffer 0))))
        (quit-window nil window)))))

(defun my/transient-open (prefix &optional args)
  "Open managed root PREFIX after synchronously closing another root menu.

ARGS are passed to PREFIX when non-nil.  Native parent-to-child transitions
must invoke Transient directly; doing so preserves its return stack."
  (interactive)
  (unless (commandp prefix)
    (user-error "%S 不是可调用的 Transient 菜单" prefix))
  (when (and (transient-active-prefix)
             (not (eq prefix (oref (transient-active-prefix) command))))
    (my/transient-force-close :my-transient-open))
  (if args
      (apply prefix args)
    (call-interactively prefix)))

(defun my/transient--setup-managed-root (original &optional name layout edit &rest params)
  "Close a stale managed root before ORIGINAL sets up NAME.

`transient-current-command' is non-nil while Transient enters a child prefix;
that path deliberately bypasses forced cleanup so parent menus remain intact."
  (when (and name
             (my/transient-managed-prefix-p name)
             (not my/transient--force-closing)
             (transient-active-prefix)
             (not transient-current-command))
    (my/transient-force-close :managed-root-switch))
  (apply original name layout edit params))

(defun my/transient--finalize-after-last-exit ()
  "Perform idempotent cleanup after the final Transient exit only.

This hook is intentionally attached to `transient-post-exit-hook', not
`transient-exit-hook': the latter also runs while a child menu returns to its
parent, when clearing the stack would be incorrect."
  (my/transient-force-close :post-exit))

(defun my/transient--cleanup-origin-viewport ()
  "Remove display-only padding once the final Transient has exited."
  (when (window-live-p transient--original-window)
    (with-current-buffer (window-buffer transient--original-window)
      (my/transient--clear-viewport-padding))) )

(unless (advice-member-p #'my/transient--setup-managed-root #'transient-setup)
  (advice-add #'transient-setup :around #'my/transient--setup-managed-root))
(add-hook 'transient-post-exit-hook #'my/transient--finalize-after-last-exit)
(add-hook 'transient-post-exit-hook #'my/transient--cleanup-origin-viewport)

(provide 'init-transient-lifecycle)
;;; init-transient-lifecycle.el ends here
