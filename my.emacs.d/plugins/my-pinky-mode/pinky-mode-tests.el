;;; pinky-mode-tests.el --- Tests for local Pinky mode -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'pinky-mode)

(ert-deftest pinky-mode-uses-vim-motion-bindings ()
  (dolist (binding '(("h" . backward-char)
                     ("j" . next-line)
                     ("k" . previous-line)
                     ("l" . forward-char)
                     ("w" . forward-word)
                     ("W" . pinky-forward-WORD)
                     ("b" . backward-word)
                     ("B" . pinky-backward-WORD)
                     ("e" . pinky-forward-word-end)
                     ("E" . pinky-forward-WORD-end)
                     ("." . pinky-repeat-last-edit)
                     ("dd" . pinky-delete-line)
                     ("dw" . pinky-delete-word)
                     ("diw" . pinky-delete-inner-word)
                     ("daw" . pinky-delete-a-word)
                     ("diW" . pinky-delete-inner-WORD)
                     ("daW" . pinky-delete-a-WORD)
                     ("d$" . pinky-delete-line-end)
                     ("dG" . pinky-delete-buffer-end)
                     ("cc" . pinky-change-line)
                     ("cw" . pinky-change-word)
                     ("ciw" . pinky-change-inner-word)
                     ("caw" . pinky-change-a-word)
                     ("ciW" . pinky-change-inner-WORD)
                     ("caW" . pinky-change-a-WORD)
                     ("c$" . pinky-change-line-end)
                     ("cG" . pinky-change-buffer-end)
                     ("s" . pinky-substitute-char)
                     ("x" . pinky-delete-char)
                     ("r" . pinky-replace-char)
                     ("R" . pinky-replace-mode-start)
                     ("u" . undo-only)
                     ("C-r" . undo-redo)
                     ("gg" . beginning-of-buffer)
                     ("ge" . pinky-backward-word-end)
                     ("gE" . pinky-backward-WORD-end)
                     ("g_" . pinky-last-nonblank)
                     ("G" . end-of-buffer)
                     ("(" . backward-sentence)
                     (")" . forward-sentence)
                     ("{" . backward-paragraph)
                     ("}" . forward-paragraph)
                     ("H" . pinky-window-top)
                     ("M" . pinky-window-middle)
                     ("L" . pinky-window-bottom)
                     ("C-d" . pinky-scroll-half-page-down)
                     ("zz" . pinky-recenter-middle)
                     ("zt" . pinky-recenter-top)
                     ("zb" . pinky-recenter-bottom)
                     ("z." . pinky-recenter-middle)
                     ("z RET" . pinky-recenter-top)
                     ("z-" . pinky-recenter-bottom)
                     ("za" . pinky-fold-toggle)
                     ("zo" . pinky-fold-open)
                     ("zc" . pinky-fold-close)
                     ("zR" . pinky-fold-open-all)
                     ("zM" . pinky-fold-close-all)
                     ("zd" . pinky-fold-delete)
                     ("/" . pinky-search-forward)
                     ("?" . pinky-search-backward)
                     ("n" . pinky-search-next)
                     ("N" . pinky-search-previous)))
    (should (eq (lookup-key pinky-mode-map (kbd (car binding)))
                (cdr binding)))))

(ert-deftest pinky-mode-keymap-can-be-rebuilt-after-hot-reload ()
  (define-key pinky-mode-map (kbd "W") nil)
  (define-key pinky-mode-map (kbd "gg") nil)
  (should-not (lookup-key pinky-mode-map (kbd "W")))
  (should-not (lookup-key pinky-mode-map (kbd "gg")))
  (pinky-mode-setup-keymap)
  (should (eq (lookup-key pinky-mode-map (kbd "W"))
              #'pinky-forward-WORD))
  (should (eq (lookup-key pinky-mode-map (kbd "gg"))
              #'beginning-of-buffer)))

(ert-deftest pinky-mode-does-not-use-window-number ()
  (should-not (featurep 'window-number))
  (should (eq (lookup-key pinky-mode-map (kbd "0"))
              #'move-beginning-of-line))
  (dolist (number (number-sequence 1 9))
    (should-not (lookup-key pinky-mode-map (kbd (number-to-string number)))))
  (dolist (number (number-sequence 0 9))
    (should-not (lookup-key pinky-mode-map (kbd (format "C-%d" number))))))

(ert-deftest pinky-mode-does-not-change-cursor-color ()
  "Toggling Pinky must leave the theme-owned cursor color untouched."
  (unwind-protect
      (cl-letf (((symbol-function 'set-cursor-color)
                 (lambda (&rest _)
                   (ert-fail "Pinky changed the cursor color"))))
        (pinky-mode-activate)
        (pinky-mode-deactivate))
    (pinky-mode -1)))

(ert-deftest pinky-mode-temporarily-replaces-and-restores-mode-name ()
  "PinkyMode replaces the visible mode name and restores the exact old value."
  (with-temp-buffer
    (emacs-lisp-mode)
    (let ((original mode-name))
      (unwind-protect
          (progn
            (pinky-mode-activate)
            (should (equal mode-name "PinkyMode"))
            (pinky-mode-deactivate)
            (should (equal mode-name original))
            (should-not (local-variable-p 'pinky--saved-mode-name)))
        (pinky-mode -1)))))

(ert-deftest pinky-mode-updates-buffers-that-change-major-mode ()
  "Buffers changing major mode while Pinky is active stay labelled."
  (unwind-protect
      (progn
        (pinky-mode-activate)
        (with-temp-buffer
          (text-mode)
          (should (equal mode-name "PinkyMode"))))
    (pinky-mode -1)))

(ert-deftest pinky-mode-repeats-character-find-in-both-directions ()
  (with-temp-buffer
    (insert "a d x d\n")
    (goto-char (point-min))
    (pinky--find-char ?d 1 nil)
    (should (= (point) 3))
    (pinky-repeat-find)
    (should (= (point) 7))
    (pinky-repeat-find-reverse)
    (should (= (point) 3))))

(ert-deftest pinky-mode-WORD-end-motions-follow-vim-boundaries ()
  (with-temp-buffer
    (insert "one two-three four")
    (goto-char 3) ; last character of "one"
    (pinky-forward-WORD-end)
    (should (= (char-after) ?e)) ; last character of "two-three"
    (pinky-forward-WORD-end)
    (should (= (char-after) ?r)) ; last character of "four"
    (pinky-backward-WORD-end)
    (should (= (char-after) ?e))))

(ert-deftest pinky-mode-previous-word-end-skips-current-word ()
  (with-temp-buffer
    (insert "one two three")
    (goto-char 6) ; inside "two"
    (pinky-backward-word-end)
    (should (= (char-after) ?e))))

(ert-deftest pinky-mode-delete-line-and-dot-repeat ()
  (with-temp-buffer
    (insert "one\ntwo\nthree\n")
    (goto-char (point-min))
    (setq pinky-last-edit nil)
    (pinky-delete-line)
    (should (equal (buffer-string) "two\nthree\n"))
    (pinky-repeat-last-edit)
    (should (equal (buffer-string) "three\n"))))

(ert-deftest pinky-mode-line-boundary-operators-execute-as-real-keys ()
  (with-temp-buffer
    (insert "abcdef\n")
    (goto-char 3)
    (switch-to-buffer (current-buffer))
    (unwind-protect
        (progn
          (pinky-mode 1)
          (execute-kbd-macro (kbd "d $"))
          (should (equal (buffer-string) "ab\n")))
      (pinky-mode -1)))
  (with-temp-buffer
    (insert "abcdef\n")
    (goto-char 5)
    (switch-to-buffer (current-buffer))
    (unwind-protect
        (progn
          (pinky-mode 1)
          (execute-kbd-macro (kbd "c 0"))
          (should (equal (buffer-string) "ef\n"))
          (should pinky-insert-state-mode))
      (when pinky-insert-state-mode
        (pinky-insert-state-mode -1))
      (pinky-mode -1))))

(ert-deftest pinky-mode-all-delete-and-change-sequences-run ()
  (dolist (keys '("d d" "d w" "d W" "d b" "d B" "d e" "d E"
                  "d 0" "d ^" "d $" "d g g" "d G" "d {" "d }"
                  "d i w" "d i W" "d a w" "d a W"
                  "c c" "c w" "c W" "c b" "c B" "c e" "c E"
                  "c 0" "c ^" "c $" "c g g" "c G" "c {" "c }"
                  "c i w" "c i W" "c a w" "c a W"))
    (with-temp-buffer
      (insert "alpha beta-gamma\n\ndelta epsilon-zeta\n\neta theta\n")
      (goto-char (point-min))
      (search-forward "epsilon")
      (backward-char 3)
      (switch-to-buffer (current-buffer))
      (unwind-protect
          (progn
            (pinky-mode 1)
            (ert-info ((format "Failed operator sequence: %s" keys))
              (should
               (condition-case nil
                   (progn (execute-kbd-macro (kbd keys)) t)
                 (error nil)))))
        (when pinky-insert-state-mode
          (pinky-insert-state-mode -1))
        (pinky-mode -1)))))

(ert-deftest pinky-mode-replace-char-and-dot-repeat ()
  (with-temp-buffer
    (insert "abcd")
    (goto-char (point-min))
    (setq pinky-last-edit nil)
    (pinky-replace-char ?X 2)
    (should (equal (buffer-string) "XXcd"))
    (goto-char 3)
    (pinky-repeat-last-edit)
    (should (equal (buffer-string) "XXXX"))))

(ert-deftest pinky-mode-word-text-objects-use-complete-word ()
  (with-temp-buffer
    (insert "one two three")
    (goto-char 6) ; inside "two"
    (pinky-delete-inner-word)
    (should (equal (buffer-string) "one  three")))
  (with-temp-buffer
    (insert "one two three")
    (goto-char 6)
    (pinky-delete-a-word)
    (should (equal (buffer-string) "one three")))
  (with-temp-buffer
    (insert "one two-three four")
    (goto-char 7) ; inside the WORD "two-three"
    (pinky-delete-inner-WORD)
    (should (equal (buffer-string) "one  four"))))

(ert-deftest pinky-mode-change-keeps-mode-open-during-insertion ()
  (with-temp-buffer
    (insert "one two three")
    (goto-char 6)
    (unwind-protect
        (progn
          (pinky-mode 1)
          (setq pinky-last-edit nil)
          (pinky-change-inner-word)
          (should pinky-mode)
          (should pinky-insert-state-mode)
          (should (eq (key-binding (kbd "h")) #'self-insert-command))
          (should (equal (buffer-string) "one  three"))
          (pinky-finish-insert-state)
          (should pinky-mode)
          (should-not pinky-insert-state-mode)
          (should (eq (key-binding (kbd "h")) #'backward-char)))
      (when pinky-insert-state-mode
        (pinky-insert-state-mode -1))
      (pinky-mode -1))))

(ert-deftest pinky-mode-replace-state-keeps-navigation-mode-active ()
  (with-temp-buffer
    (unwind-protect
        (progn
          (pinky-mode 1)
          (pinky-replace-mode-start)
          (should pinky-mode)
          (should pinky-replace-mode)
          (should overwrite-mode)
          (should (eq (key-binding (kbd "h")) #'self-insert-command))
          (pinky-replace-mode-finish)
          (should pinky-mode)
          (should-not pinky-replace-mode)
          (should-not overwrite-mode)
          (should (eq (key-binding (kbd "h")) #'backward-char)))
      (when pinky-replace-mode
        (pinky-replace-mode -1))
      (pinky-mode -1))))

(ert-deftest pinky-mode-search-repeat-follows-last-direction ()
  (let (called)
    (cl-letf (((symbol-function 'isearch-repeat-forward)
               (lambda () (interactive) (setq called 'forward)))
              ((symbol-function 'isearch-repeat-backward)
               (lambda () (interactive) (setq called 'backward))))
      (setq pinky-last-search-direction -1)
      (pinky-search-next)
      (should (eq called 'backward))
      (pinky-search-previous)
      (should (eq called 'forward)))))

(provide 'pinky-mode-tests)
;;; pinky-mode-tests.el ends here
