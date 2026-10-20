;;; pinky-mode.el --- Vim-style navigation without modifier keys -*- lexical-binding: t; -*-

;; Copyright (C) 2013-2014, Jay Conrod, all rights reserved.

;; Author: Jay Conrod <jayconrod@gmail.com>
;; Description: Navigate without holding meta keys.
;; Keywords: pinky key bindings navigation
;; Version: 1

;; This file is NOT part of GNU Emacs

;; License
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:

;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.

;; 2. Redistributions in binary form must reproduce the above
;;    copyright notice, this list of conditions and the following
;;    disclaimer in the documentation and/or other materials provided
;;    with the distribution.

;; 3. Neither the name of the copyright holder nor the names of its
;;    contributors may be used to endorse or promote products derived
;;    from this software without specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;; FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;; COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
;; INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
;; OF THE POSSIBILITY OF SUCH DAMAGE.


;;; Commentary:
;;
;; "Emacs Pinky" is a condition where you feel pain in one or both of
;; your pinky fingers from using Emacs. This is because Emacs requires
;; you to hold [Ctrl] to do anything other than inserting text. On
;; most keyboards, [Ctrl] is pressed with the pinky, so this causes a
;; lot of stress.
;;
;; What can you do about this though? Switch to Vim? You'll have to
;; learn a new set of key bindings and throw away all your
;; customizations! It will be awful!
;;
;; pinky-mode to the rescue! pinky-mode is a minor mode which lets you
;; use most common navigation commands without touching [Ctrl]. It is
;; inspired by command mode in Vim. Once activated, just use the letter
;; keys to navigate your buffer. For example, press n instead of C-n to
;; move to the next line. This lets you keep using your muscle memory!
;; See the full list of key bindings below. Press i to leave Pinky
;; mode and go back to inserting text.
;;
;; When pinky-mode is active, the cursor color will change, and
;; "Pinky" will be shown in the mode line. You can customize the cursor
;; color with M-x customize-group RET pinky RET.
;;
;;; Installation:
;;
;; Once the pinky-mode package is installed, add this to your .emacs:
;;
;;   (require 'pinky-mode)
;;
;; You will need to bind pinky-mode-activate to something you can
;; press easily. I use the key-chord package to bind this to "jk"
;; (press j and k at the same time). This is entirely up to you
;; though.
;;
;;   (require 'key-chord)
;;   (key-chord-mode 1)
;;   (key-chord-define-global "jk" 'pinky-mode-activate)
;;
;; To force yourself to learn pinky-mode, consider disabling the
;; normal key bindings for navigation.
;;
;;   (pinky-unbind-normal-keys)

;;; Code:

(defgroup pinky nil "Pinky mode group"
  :group 'editing)

(defcustom pinky-active-color "red"
  "The color of the point when pinky mode is active."
  :type 'color
  :group 'pinky)

;; TODO: it would be good to set the default to the normal cursor face
;; background color. I can't figure out the symbol of this though.
(defcustom pinky-inactive-color "black"
  "The color of the point when pinky mode is inactive."
  :type 'color
  :group 'pinky)

(defvar pinky-mode-in-minibuffer nil)

(defvar pinky-last-find nil
  "Last Vim-style character find as (CHAR DIRECTION TILL).")

(defvar pinky-last-search-direction 1
  "Direction of the last Pinky search: 1 forward or -1 backward.")

(defvar pinky-last-edit nil
  "Most recent Pinky editing command and its arguments.")

(defvar pinky--repeating-edit nil
  "Non-nil while `pinky-repeat-last-edit' is replaying an edit.")

(defun pinky-mode-activate ()
  (interactive)
  (pinky-mode t)
  (set-cursor-color pinky-active-color))

(defun pinky-mode-deactivate ()
  (interactive)
  (when (bound-and-true-p pinky-insert-state-mode)
    (pinky-insert-state-mode -1))
  (when (bound-and-true-p pinky-replace-mode)
    (pinky-replace-mode -1))
  (pinky-mode -1)
  (set-cursor-color pinky-inactive-color))

(defun pinky--remember-edit (command &rest arguments)
  "Remember COMMAND and ARGUMENTS for Vim-style dot repetition."
  (unless pinky--repeating-edit
    (setq pinky-last-edit (cons command arguments))))

(defun pinky-repeat-last-edit ()
  "Repeat the latest Pinky edit, like Vim `.'."
  (interactive)
  (if pinky-last-edit
      (let ((pinky--repeating-edit t))
        (apply (car pinky-last-edit) (cdr pinky-last-edit)))
    (user-error "No previous Pinky edit")))

(defun pinky--operator-region (motion inclusive)
  "Return the region selected by MOTION from point.

When INCLUSIVE is non-nil, include the character at the motion destination."
  (let ((origin (point))
        destination)
    (save-excursion
      ;; Motions do not share one Lisp signature.  For example,
      ;; `move-end-of-line' requires ARG even though `forward-word' does not.
      ;; Calling them interactively supplies their normal default arguments and
      ;; matches what the same motion does when invoked directly from Pinky.
      (call-interactively motion)
      (setq destination (point)))
    (when inclusive
      (if (< destination origin)
          (setq origin (min (point-max) (1+ origin)))
        (setq destination (min (point-max) (1+ destination)))))
    (cons (min origin destination) (max origin destination))))

(defun pinky--operate (motion inclusive change)
  "Kill text selected by MOTION, optionally INCLUSIVE.

When CHANGE is non-nil, leave Pinky mode after killing the text."
  (pcase-let ((`(,beg . ,end) (pinky--operator-region motion inclusive)))
    (unless (= beg end)
      (kill-region beg end)))
  (when change
    (pinky-enter-insert-state)))

(defun pinky--word-object-region (big around)
  "Return bounds of the word object at point.

When BIG is non-nil, use a whitespace-delimited Vim WORD.  Otherwise use an
Emacs word or symbol.  When AROUND is non-nil, include adjacent whitespace,
preferring whitespace after the object as Vim does."
  (save-excursion
    (let (beg end)
      (if big
          (progn
            (when (looking-at-p "[[:space:]]")
              (skip-chars-forward " \t\n\r"))
            (setq beg (point))
            (skip-chars-backward "^ \t\n\r")
            (setq beg (point))
            (skip-chars-forward "^ \t\n\r")
            (setq end (point)))
        (unless (bounds-of-thing-at-point 'word)
          (skip-syntax-forward "^w_"))
        (when-let ((bounds (bounds-of-thing-at-point 'word)))
          (setq beg (car bounds)
                end (cdr bounds))))
      (unless (and beg end (< beg end))
        (user-error "No word at point"))
      (when around
        (goto-char end)
        (let ((with-trailing (progn
                               (skip-chars-forward " \t\n\r")
                               (point))))
          (if (> with-trailing end)
              (setq end with-trailing)
            (goto-char beg)
            (skip-chars-backward " \t\n\r")
            (setq beg (point)))))
      (cons beg end))))

(defun pinky--operate-word-object (big around change)
  "Kill a Vim word object selected by BIG and AROUND.

When CHANGE is non-nil, leave Pinky mode after the operation."
  (pcase-let ((`(,beg . ,end) (pinky--word-object-region big around)))
    (kill-region beg end))
  (when change
    (pinky-enter-insert-state)))

(defmacro pinky-define-word-object-command (name big around change)
  "Define NAME as a Vim word-object command.

BIG selects WORD instead of word, AROUND includes adjacent whitespace, and
CHANGE controls whether the command returns to insertion afterward."
  `(defun ,name ()
     (interactive)
     (pinky--remember-edit #',name)
     (pinky--operate-word-object ,big ,around ,change)))

(defmacro pinky-define-operator-command (name motion inclusive change)
  "Define NAME as a Vim operator using MOTION.

INCLUSIVE controls whether the destination character is included, and CHANGE
controls whether the command returns to normal Emacs insertion afterward."
  `(defun ,name ()
     (interactive)
     (pinky--remember-edit #',name)
     (pinky--operate #',motion ,inclusive ,change)))

(pinky-define-operator-command pinky-delete-word forward-word nil nil)
(pinky-define-operator-command pinky-delete-WORD pinky-forward-WORD nil nil)
(pinky-define-operator-command pinky-delete-back-word backward-word nil nil)
(pinky-define-operator-command pinky-delete-back-WORD pinky-backward-WORD nil nil)
(pinky-define-operator-command pinky-delete-word-end pinky-forward-word-end t nil)
(pinky-define-operator-command pinky-delete-WORD-end pinky-forward-WORD-end t nil)
(pinky-define-operator-command pinky-delete-line-start move-beginning-of-line nil nil)
(pinky-define-operator-command pinky-delete-indentation back-to-indentation nil nil)
(pinky-define-operator-command pinky-delete-line-end move-end-of-line nil nil)
(pinky-define-operator-command pinky-delete-buffer-start beginning-of-buffer nil nil)
(pinky-define-operator-command pinky-delete-buffer-end end-of-buffer nil nil)
(pinky-define-operator-command pinky-delete-paragraph-backward backward-paragraph nil nil)
(pinky-define-operator-command pinky-delete-paragraph-forward forward-paragraph nil nil)

(pinky-define-operator-command pinky-change-word forward-word nil t)
(pinky-define-operator-command pinky-change-WORD pinky-forward-WORD nil t)
(pinky-define-operator-command pinky-change-back-word backward-word nil t)
(pinky-define-operator-command pinky-change-back-WORD pinky-backward-WORD nil t)
(pinky-define-operator-command pinky-change-word-end pinky-forward-word-end t t)
(pinky-define-operator-command pinky-change-WORD-end pinky-forward-WORD-end t t)
(pinky-define-operator-command pinky-change-line-start move-beginning-of-line nil t)
(pinky-define-operator-command pinky-change-indentation back-to-indentation nil t)
(pinky-define-operator-command pinky-change-line-end move-end-of-line nil t)
(pinky-define-operator-command pinky-change-buffer-start beginning-of-buffer nil t)
(pinky-define-operator-command pinky-change-buffer-end end-of-buffer nil t)
(pinky-define-operator-command pinky-change-paragraph-backward backward-paragraph nil t)
(pinky-define-operator-command pinky-change-paragraph-forward forward-paragraph nil t)

(pinky-define-word-object-command pinky-delete-inner-word nil nil nil)
(pinky-define-word-object-command pinky-delete-a-word nil t nil)
(pinky-define-word-object-command pinky-delete-inner-WORD t nil nil)
(pinky-define-word-object-command pinky-delete-a-WORD t t nil)
(pinky-define-word-object-command pinky-change-inner-word nil nil t)
(pinky-define-word-object-command pinky-change-a-word nil t t)
(pinky-define-word-object-command pinky-change-inner-WORD t nil t)
(pinky-define-word-object-command pinky-change-a-WORD t t t)

(defun pinky-delete-line ()
  "Kill the current line, including its newline, like Vim `dd'."
  (interactive)
  (pinky--remember-edit #'pinky-delete-line)
  (let ((beg (line-beginning-position))
        (end (save-excursion
               (if (= (forward-line 1) 0) (point) (point-max)))))
    (kill-region beg end)))

(defun pinky-change-line ()
  "Kill the current line's contents and enter Pinky insertion, like Vim `cc'."
  (interactive)
  (pinky--remember-edit #'pinky-change-line)
  (kill-region (line-beginning-position) (line-end-position))
  (pinky-enter-insert-state))

(defun pinky-delete-char (&optional count)
  "Kill COUNT characters forward, like Vim `x'."
  (interactive "p")
  (setq count (or count 1))
  (pinky--remember-edit #'pinky-delete-char count)
  (kill-region (point) (min (point-max) (+ (point) count))))

(defun pinky-substitute-char (&optional count)
  "Kill COUNT characters and enter Pinky insertion, like Vim `s'."
  (interactive "p")
  (setq count (or count 1))
  (pinky--remember-edit #'pinky-substitute-char count)
  (kill-region (point) (min (point-max) (+ (point) count)))
  (pinky-enter-insert-state))

(defun pinky-replace-char (character &optional count)
  "Replace COUNT characters with CHARACTER, like Vim `r'."
  (interactive (list (read-char "Replace with character: ")
                     (prefix-numeric-value current-prefix-arg)))
  (setq count (or count 1))
  (pinky--remember-edit #'pinky-replace-char character count)
  (let ((available (min count (- (line-end-position) (point)))))
    (when (zerop available)
      (user-error "No character to replace"))
    (atomic-change-group
      (delete-region (point) (+ (point) available))
      (insert (make-string available character))
      (backward-char available))))

(defvar-local pinky--saved-navigation-override nil
  "Previous buffer-local override for `pinky-mode', if any.")

(defvar-local pinky--navigation-suspended nil
  "Non-nil while this buffer temporarily accepts ordinary text input.")

(defun pinky--suspend-navigation ()
  "Temporarily suppress Pinky's navigation map in the current buffer."
  (unless pinky--navigation-suspended
    (setq pinky--saved-navigation-override
          (copy-tree (assq 'pinky-mode minor-mode-overriding-map-alist)))
    (setq-local minor-mode-overriding-map-alist
                (assq-delete-all 'pinky-mode minor-mode-overriding-map-alist))
    (push (cons 'pinky-mode (make-sparse-keymap))
          minor-mode-overriding-map-alist)
    (setq pinky--navigation-suspended t)))

(defun pinky--resume-navigation ()
  "Restore Pinky's navigation map in the current buffer."
  (when pinky--navigation-suspended
    (setq-local minor-mode-overriding-map-alist
                (assq-delete-all 'pinky-mode minor-mode-overriding-map-alist))
    (when pinky--saved-navigation-override
      (push pinky--saved-navigation-override
            minor-mode-overriding-map-alist))
    (setq pinky--saved-navigation-override nil
          pinky--navigation-suspended nil)))

(defvar pinky-insert-state-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<escape>") #'pinky-finish-insert-state)
    (define-key map (kbd "C-g") #'pinky-finish-insert-state)
    map)
  "Keymap used while a Pinky change command accepts inserted text.")

(define-minor-mode pinky-insert-state-mode
  "Temporarily accept normal text input while keeping Pinky mode active."
  :lighter " Pinky-Insert"
  :keymap pinky-insert-state-mode-map
  (if pinky-insert-state-mode
      (pinky--suspend-navigation)
    (pinky--resume-navigation)))

(defun pinky-enter-insert-state ()
  "Enter text input without closing Pinky or its passive menu."
  (interactive)
  (when (bound-and-true-p pinky-replace-mode)
    (pinky-replace-mode -1))
  (pinky-insert-state-mode 1))

(defun pinky-finish-insert-state ()
  "Return from Pinky insertion to Pinky navigation."
  (interactive)
  (pinky-insert-state-mode -1))

(defvar pinky-replace-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<escape>") #'pinky-replace-mode-finish)
    (define-key map (kbd "C-g") #'pinky-replace-mode-finish)
    map)
  "Keymap active while `pinky-replace-mode' is replacing text.")

(define-minor-mode pinky-replace-mode
  "Overwrite inserted characters until ESC or C-g, like Vim `R'."
  :lighter " Replace"
  :keymap pinky-replace-mode-map
  (if pinky-replace-mode
      (progn
        (pinky--suspend-navigation)
        (overwrite-mode 1))
    (overwrite-mode -1)
    (pinky--resume-navigation)))

(defun pinky-replace-mode-start ()
  "Begin Vim-style replacement without closing Pinky or its menu."
  (interactive)
  (when (bound-and-true-p pinky-insert-state-mode)
    (pinky-insert-state-mode -1))
  (pinky--suspend-navigation)
  (pinky-replace-mode 1))

(defun pinky-replace-mode-finish ()
  "Finish replace mode and return to Pinky navigation."
  (interactive)
  (pinky-replace-mode -1)
  (pinky--resume-navigation))

(defun pinky-forward-word-end ()
  "Move to the last character of the current or next word, like Vim `e'."
  (interactive)
  (let ((origin (point)))
    (forward-word 1)
    (unless (bobp)
      (backward-char 1))
    ;; At a word end, Vim's `e' advances to the end of the next word.
    (when (and (= (point) origin) (not (eobp)))
      (forward-char 1)
      (forward-word 1)
      (unless (bobp)
        (backward-char 1)))))

(defun pinky-forward-WORD ()
  "Move to the beginning of the next whitespace-delimited WORD, like Vim `W'."
  (interactive)
  (unless (eobp)
    (if (looking-at-p "[[:space:]]")
        (skip-chars-forward " \t\n\r")
      (skip-chars-forward "^ \t\n\r")
      (skip-chars-forward " \t\n\r"))))

(defun pinky-backward-WORD ()
  "Move to the beginning of the previous whitespace-delimited WORD, like Vim `B'."
  (interactive)
  (skip-chars-backward " \t\n\r")
  (skip-chars-backward "^ \t\n\r"))

(defun pinky-forward-WORD-end ()
  "Move to the end of the current or next whitespace-delimited WORD, like Vim `E'."
  (interactive)
  (let ((origin (point)))
    (when (looking-at-p "[[:space:]]")
      (skip-chars-forward " \t\n\r"))
    (skip-chars-forward "^ \t\n\r")
    (unless (bobp)
      (backward-char 1))
    ;; At a WORD end, Vim's `E' advances to the end of the next WORD.
    (when (and (= (point) origin) (not (eobp)))
      (forward-char 1)
      (skip-chars-forward " \t\n\r")
      (skip-chars-forward "^ \t\n\r")
      (unless (bobp)
        (backward-char 1)))))

(defun pinky-backward-word-end ()
  "Move to the end of the previous word, like Vim `ge'."
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'word))
         (inside-word (and bounds (> (point) (car bounds)))))
    (backward-word 1)
    ;; From inside a word, the first move only reaches that word's beginning.
    (when (and inside-word (not (bobp)))
      (backward-word 1))
    (forward-word 1)
    (unless (bobp)
      (backward-char 1))))

(defun pinky-backward-WORD-end ()
  "Move to the end of the previous whitespace-delimited WORD, like Vim `gE'."
  (interactive)
  (if (looking-at-p "[[:space:]]")
      (skip-chars-backward " \t\n\r")
    (skip-chars-backward "^ \t\n\r")
    (skip-chars-backward " \t\n\r"))
  (unless (bobp)
    (backward-char 1)))

(defun pinky-last-nonblank ()
  "Move to the last non-blank character on the line, like Vim `g_'."
  (interactive)
  (end-of-line)
  (skip-chars-backward " \t")
  (unless (bolp)
    (backward-char 1)))

(defun pinky--find-char (character direction till &optional preserve-last repeat)
  "Find CHARACTER on the current line in DIRECTION.

DIRECTION is 1 for forward and -1 for backward.  When TILL is non-nil,
stop immediately before the target when moving forward, or immediately after
it when moving backward.  PRESERVE-LAST keeps `pinky-last-find' unchanged.
REPEAT skips the occurrence used by the previous till-motion."
  (let ((origin (point))
        found)
    (if (> direction 0)
        (let ((line-end (line-end-position)))
          ;; Vim's forward find never selects the character already under point.
          ;; Repeating `t' must additionally step over its previous target.
          (forward-char (min (- line-end (point))
                             (if (and repeat till) 2 1)))
          (when (search-forward (char-to-string character) line-end t)
            (backward-char (if till 2 1))
            (setq found t)))
      ;; `T' leaves point after its target; step back once before a repeat so
      ;; search-backward cannot select that same target again.
      (when (and repeat till (> (point) (line-beginning-position)))
        (backward-char 1))
      (when (search-backward (char-to-string character) (line-beginning-position) t)
        (when till
          (forward-char 1))
        (setq found t)))
    (if found
        (unless preserve-last
          (setq pinky-last-find (list character direction till)))
      (goto-char origin)
      (user-error "Character %c not found on this line" character))))

(defun pinky-find-char-forward (character)
  "Find the next CHARACTER on this line, like Vim `f'."
  (interactive (list (read-char "Find character: ")))
  (pinky--find-char character 1 nil))

(defun pinky-find-char-backward (character)
  "Find the previous CHARACTER on this line, like Vim `F'."
  (interactive (list (read-char "Find character backward: ")))
  (pinky--find-char character -1 nil))

(defun pinky-till-char-forward (character)
  "Move just before the next CHARACTER on this line, like Vim `t'."
  (interactive (list (read-char "Till character: ")))
  (pinky--find-char character 1 t))

(defun pinky-till-char-backward (character)
  "Move just after the previous CHARACTER on this line, like Vim `T'."
  (interactive (list (read-char "Till character backward: ")))
  (pinky--find-char character -1 t))

(defun pinky-repeat-find ()
  "Repeat the latest `f', `F', `t', or `T' motion."
  (interactive)
  (if pinky-last-find
      (pcase-let ((`(,character ,direction ,till) pinky-last-find))
        (pinky--find-char character direction till nil t))
    (user-error "No previous character find")))

(defun pinky-repeat-find-reverse ()
  "Repeat the latest character find in the opposite direction."
  (interactive)
  (if pinky-last-find
      (pcase-let ((`(,character ,direction ,till) pinky-last-find))
        (pinky--find-char character (- direction) till t t))
    (user-error "No previous character find")))

(defun pinky-window-top ()
  "Move point to the top visible line, like Vim `H'."
  (interactive)
  (move-to-window-line 0))

(defun pinky-window-middle ()
  "Move point to the middle visible line, like Vim `M'."
  (interactive)
  (move-to-window-line nil))

(defun pinky-window-bottom ()
  "Move point to the bottom visible line, like Vim `L'."
  (interactive)
  (move-to-window-line -1))

(defun pinky-scroll-half-page-down ()
  "Scroll forward by half a window, like Vim `C-d'."
  (interactive)
  (scroll-up-command (max 1 (/ (window-body-height) 2))))

(defun pinky-scroll-half-page-up ()
  "Scroll backward by half a window, like Vim `C-u'."
  (interactive)
  (scroll-down-command (max 1 (/ (window-body-height) 2))))

(defun pinky-recenter-middle ()
  "Recenter point vertically, like Vim `zz'."
  (interactive)
  (recenter))

(defun pinky-recenter-top ()
  "Place point at the top of the window, like Vim `zt'."
  (interactive)
  (recenter 0))

(defun pinky-recenter-bottom ()
  "Place point at the bottom of the window, like Vim `zb'."
  (interactive)
  (recenter -1))

(defun pinky-fold-toggle ()
  "Toggle the fold at point, like Vim `za'."
  (interactive)
  (require 'hideshow)
  (unless hs-minor-mode
    (hs-minor-mode 1))
  (hs-toggle-hiding))

(defun pinky-fold-open ()
  "Open the fold at point, like Vim `zo'."
  (interactive)
  (require 'hideshow)
  (unless hs-minor-mode
    (hs-minor-mode 1))
  (hs-show-block))

(defun pinky-fold-close ()
  "Close the fold at point, like Vim `zc'."
  (interactive)
  (require 'hideshow)
  (unless hs-minor-mode
    (hs-minor-mode 1))
  (hs-hide-block))

(defun pinky-fold-open-all ()
  "Open all folds, like Vim `zR'."
  (interactive)
  (require 'hideshow)
  (unless hs-minor-mode
    (hs-minor-mode 1))
  (hs-show-all))

(defun pinky-fold-close-all ()
  "Close all folds, like Vim `zM'."
  (interactive)
  (require 'hideshow)
  (unless hs-minor-mode
    (hs-minor-mode 1))
  (hs-hide-all))

(defun pinky-fold-delete ()
  "Delete or clear the fold at point, like Vim `zd'."
  (interactive)
  (cond
   ((fboundp 'my/vimish-fold-delete-markers)
    (call-interactively #'my/vimish-fold-delete-markers))
   ((require 'hideshow nil t)
    (unless hs-minor-mode
      (hs-minor-mode 1))
    ;; Hideshow folds are overlays rather than persistent definitions;
    ;; showing the block removes the fold overlay at point.
    (hs-show-block))
   (t
    (user-error "No fold implementation is available"))))

(defun pinky-search-forward ()
  "Start a forward incremental search, like Vim `/'."
  (interactive)
  (setq pinky-last-search-direction 1)
  (call-interactively #'isearch-forward))

(defun pinky-search-backward ()
  "Start a backward incremental search, like Vim `?'."
  (interactive)
  (setq pinky-last-search-direction -1)
  (call-interactively #'isearch-backward))

(defun pinky-search-next ()
  "Repeat the latest search in its original direction, like Vim `n'."
  (interactive)
  (call-interactively
   (if (> pinky-last-search-direction 0)
       #'isearch-repeat-forward
     #'isearch-repeat-backward)))

(defun pinky-search-previous ()
  "Repeat the latest search in the opposite direction, like Vim `N'."
  (interactive)
  (call-interactively
   (if (> pinky-last-search-direction 0)
       #'isearch-repeat-backward
     #'isearch-repeat-forward)))

(defvar pinky-mode-map (make-keymap)
  "Keymap used by `pinky-mode'.")

(defun pinky-mode-setup-keymap ()
  "Rebuild `pinky-mode-map' with the complete Vim-style motion set.

This function intentionally mutates the existing keymap so reloading the
plugin updates an already running `pinky-mode' session."
  (setcdr pinky-mode-map nil)
  (let ((map pinky-mode-map)
        (goto-map (make-sparse-keymap))
        (recenter-map (make-sparse-keymap))
        (delete-map (make-sparse-keymap))
        (delete-goto-map (make-sparse-keymap))
        (delete-inner-map (make-sparse-keymap))
        (delete-around-map (make-sparse-keymap))
        (change-map (make-sparse-keymap))
        (change-goto-map (make-sparse-keymap))
        (change-inner-map (make-sparse-keymap))
        (change-around-map (make-sparse-keymap)))
    ;; Enter/leave command-style navigation.
    (define-key map "i" 'pinky-mode-deactivate)

    ;; Basic Vim character, line, and word motions.
    (define-key map "h" #'backward-char)
    (define-key map "j" #'next-line)
    (define-key map "k" #'previous-line)
    (define-key map "l" #'forward-char)
    (define-key map "w" #'forward-word)
    (define-key map "W" #'pinky-forward-WORD)
    (define-key map "b" #'backward-word)
    (define-key map "B" #'pinky-backward-WORD)
    (define-key map "e" #'pinky-forward-word-end)
    (define-key map "E" #'pinky-forward-WORD-end)
    (define-key map "0" #'move-beginning-of-line)
    (define-key map "^" #'back-to-indentation)
    (define-key map "$" #'move-end-of-line)
    (define-key map "." #'pinky-repeat-last-edit)

    ;; Precise horizontal motions within the current line.
    (define-key map "f" #'pinky-find-char-forward)
    (define-key map "F" #'pinky-find-char-backward)
    (define-key map "t" #'pinky-till-char-forward)
    (define-key map "T" #'pinky-till-char-backward)
    (define-key map ";" #'pinky-repeat-find)
    (define-key map "," #'pinky-repeat-find-reverse)

    ;; Vertical, paragraph, buffer, and visible-window motions.
    (define-key goto-map "g" #'beginning-of-buffer)
    (define-key goto-map "e" #'pinky-backward-word-end)
    (define-key goto-map "E" #'pinky-backward-WORD-end)
    (define-key goto-map "_" #'pinky-last-nonblank)
    (define-key map "g" goto-map)
    (define-key map "G" #'end-of-buffer)
    (define-key map "(" #'backward-sentence)
    (define-key map ")" #'forward-sentence)
    (define-key map "{" #'backward-paragraph)
    (define-key map "}" #'forward-paragraph)
    (define-key map "H" #'pinky-window-top)
    (define-key map "M" #'pinky-window-middle)
    (define-key map "L" #'pinky-window-bottom)

    ;; Screen and viewport scrolling.
    (define-key map (kbd "C-f") #'scroll-up-command)
    (define-key map (kbd "C-b") #'scroll-down-command)
    (define-key map (kbd "C-d") #'pinky-scroll-half-page-down)
    (define-key map (kbd "C-u") #'pinky-scroll-half-page-up)
    (define-key map (kbd "C-e") #'scroll-up-line)
    (define-key map (kbd "C-y") #'scroll-down-line)
    (define-key recenter-map "z" #'pinky-recenter-middle)
    (define-key recenter-map "t" #'pinky-recenter-top)
    (define-key recenter-map "b" #'pinky-recenter-bottom)
    (define-key recenter-map "." #'pinky-recenter-middle)
    (define-key recenter-map (kbd "RET") #'pinky-recenter-top)
    (define-key recenter-map "-" #'pinky-recenter-bottom)
    (define-key recenter-map "a" #'pinky-fold-toggle)
    (define-key recenter-map "o" #'pinky-fold-open)
    (define-key recenter-map "c" #'pinky-fold-close)
    (define-key recenter-map "R" #'pinky-fold-open-all)
    (define-key recenter-map "M" #'pinky-fold-close-all)
    (define-key recenter-map "d" #'pinky-fold-delete)
    (define-key map "z" recenter-map)

    ;; Vim-style forward/backward search and result repetition.
    (define-key map "/" #'pinky-search-forward)
    (define-key map "?" #'pinky-search-backward)
    (define-key map "n" #'pinky-search-next)
    (define-key map "N" #'pinky-search-previous)

    ;; Vim-style editing.  `d' and `c' are operator prefixes sharing the
    ;; navigation vocabulary above; `c', `s', and `R' return to text input.
    (dolist (binding `(("d" . pinky-delete-line)
                       ("w" . pinky-delete-word)
                       ("W" . pinky-delete-WORD)
                       ("b" . pinky-delete-back-word)
                       ("B" . pinky-delete-back-WORD)
                       ("e" . pinky-delete-word-end)
                       ("E" . pinky-delete-WORD-end)
                       ("0" . pinky-delete-line-start)
                       ("^" . pinky-delete-indentation)
                       ("$" . pinky-delete-line-end)
                       ("G" . pinky-delete-buffer-end)
                       ("{" . pinky-delete-paragraph-backward)
                       ("}" . pinky-delete-paragraph-forward)))
      (define-key delete-map (kbd (car binding)) (cdr binding)))
    (define-key delete-goto-map "g" #'pinky-delete-buffer-start)
    (define-key delete-map "g" delete-goto-map)
    (define-key delete-inner-map "w" #'pinky-delete-inner-word)
    (define-key delete-inner-map "W" #'pinky-delete-inner-WORD)
    (define-key delete-around-map "w" #'pinky-delete-a-word)
    (define-key delete-around-map "W" #'pinky-delete-a-WORD)
    (define-key delete-map "i" delete-inner-map)
    (define-key delete-map "a" delete-around-map)
    (define-key map "d" delete-map)

    (dolist (binding `(("c" . pinky-change-line)
                       ("w" . pinky-change-word)
                       ("W" . pinky-change-WORD)
                       ("b" . pinky-change-back-word)
                       ("B" . pinky-change-back-WORD)
                       ("e" . pinky-change-word-end)
                       ("E" . pinky-change-WORD-end)
                       ("0" . pinky-change-line-start)
                       ("^" . pinky-change-indentation)
                       ("$" . pinky-change-line-end)
                       ("G" . pinky-change-buffer-end)
                       ("{" . pinky-change-paragraph-backward)
                       ("}" . pinky-change-paragraph-forward)))
      (define-key change-map (kbd (car binding)) (cdr binding)))
    (define-key change-goto-map "g" #'pinky-change-buffer-start)
    (define-key change-map "g" change-goto-map)
    (define-key change-inner-map "w" #'pinky-change-inner-word)
    (define-key change-inner-map "W" #'pinky-change-inner-WORD)
    (define-key change-around-map "w" #'pinky-change-a-word)
    (define-key change-around-map "W" #'pinky-change-a-WORD)
    (define-key change-map "i" change-inner-map)
    (define-key change-map "a" change-around-map)
    (define-key map "c" change-map)

    (define-key map "D" #'pinky-delete-line-end)
    (define-key map "C" #'pinky-change-line-end)
    (define-key map "s" #'pinky-substitute-char)
    (define-key map "x" #'pinky-delete-char)
    (define-key map "r" #'pinky-replace-char)
    (define-key map "R" #'pinky-replace-mode-start)
    (define-key map "u" #'undo-only)
    (define-key map (kbd "C-r") #'undo-redo)))

(pinky-mode-setup-keymap)

(defun pinky-unbind-normal-keys ()
  "Unbinds the normal navigation keys to force you to save your pinkies!"
  (interactive)
  (global-unset-key (kbd "C-n"))
  (global-unset-key (kbd "C-p"))
  (global-unset-key (kbd "C-f"))
  (global-unset-key (kbd "C-b"))
  (global-unset-key (kbd "C-a"))
  (global-unset-key (kbd "C-e"))
  (global-unset-key (kbd "C-v"))
  (global-unset-key (kbd "M-v")))


(define-minor-mode pinky-mode
  "Navigate without holding meta keys"
  :lighter " Pinky" :global t :keymap pinky-mode-map)


(add-hook 'minibuffer-setup-hook (lambda nil
  (setq pinky-mode-in-minibuffer pinky-mode)
  (if pinky-mode (pinky-mode-deactivate))))

(add-hook 'minibuffer-exit-hook (lambda nil
  (if pinky-mode-in-minibuffer (pinky-mode-activate))))


(provide 'pinky-mode)

;;; pinky-mode.el ends here
