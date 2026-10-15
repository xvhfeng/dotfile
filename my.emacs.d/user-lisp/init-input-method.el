;;; init-input-method.el --- Smart macOS input-source switching -*- lexical-binding: t; -*-

(require 'seq)

(declare-function sis--init-ism "sis" ())
(defvar sis-do-get)
(defvar sis-do-set)

(defconst my/sis-english-source "com.apple.keylayout.ABC"
  "macOS input-source id used for English commands.")

(defconst my/sis-other-source "com.tencent.inputmethod.wetype.pinyin"
  "Canonical macOS input-source id used for Chinese text input.")

(defcustom my/sis-chinese-sources
  '("com.tencent.inputmethod.wetype.pinyin"
    "im.rime.inputmethod.Squirrel.Hans"
    "com.apple.inputmethod.SCIM.ITABC")
  "macOS input-source ids that SIS should recognize as Chinese.

The list currently covers WeType Pinyin, Squirrel Simplified Chinese and the
built-in macOS Pinyin input source enabled or recently used on this machine."
  :type '(repeat string)
  :group 'convenience)

(defvar my/sis-last-chinese-source my/sis-other-source
  "Most recently observed Chinese input source.")

(defvar my/sis--raw-do-get nil
  "Original SIS function used to read the macOS input source.")

(defvar my/sis--raw-do-set nil
  "Original SIS function used to set the macOS input source.")

(defcustom my/sis-command-modifiers '(control meta alt)
  "Modifiers that make the next Emacs command switch to English."
  :type '(repeat symbol)
  :group 'convenience)

(defconst my/sis-unmodified-command-events '(?\r return)
  "Unmodified key events that must not trigger an input-source switch.
Character RET is encoded as 13, so `event-modifiers' reports it as C-m even
when the user pressed Enter without a modifier.  The symbolic `return' event
is listed as documentation and for consistency across GUI builds.")

(defun my/sis-modified-command-p (&optional keys)
  "Return non-nil when KEYS contains a configured command modifier.
When KEYS is nil, inspect the key sequence of the current command."
  (seq-some
   (lambda (event)
     (unless (memq event my/sis-unmodified-command-events)
       (seq-some (lambda (modifier)
                   (memq modifier my/sis-command-modifiers))
                 (event-modifiers event))))
   (or keys (this-command-keys-vector))))

(defun my/sis-english-before-modified-command ()
  "Switch to English before a Ctrl/Alt/Meta command is executed."
  (when (my/sis-modified-command-p)
    (sis-set-english)))

(defun my/sis-chinese-source-p (source)
  "Return non-nil when SOURCE is one of the configured Chinese sources."
  (and (stringp source) (member source my/sis-chinese-sources)))

(defun my/sis--canonicalize-input-source (source)
  "Map any configured Chinese SOURCE to the canonical SIS other source.

Remember the concrete Chinese source so restoring Chinese input returns to the
input method that was actually in use."
  (if (my/sis-chinese-source-p source)
      (progn
        (setq my/sis-last-chinese-source source)
        my/sis-other-source)
    source))

(defun my/sis--expand-input-source (source)
  "Expand canonical Chinese SOURCE to the most recently used Chinese source."
  (if (equal source my/sis-other-source)
      (if (my/sis-chinese-source-p my/sis-last-chinese-source)
          my/sis-last-chinese-source
        my/sis-other-source)
    source))

(defun my/sis--get-input-source ()
  "Read and normalize the current input source for SIS."
  (my/sis--canonicalize-input-source (funcall my/sis--raw-do-get)))

(defun my/sis--set-input-source (source)
  "Set SOURCE through SIS while preserving the selected Chinese input method."
  (funcall my/sis--raw-do-set (my/sis--expand-input-source source)))

(defun my/sis-enable-multiple-chinese-sources ()
  "Teach SIS to recognize and restore every configured Chinese input source."
  (unless (and (functionp my/sis--raw-do-get)
               (functionp my/sis--raw-do-set))
    (setq my/sis--raw-do-get sis-do-get
          my/sis--raw-do-set sis-do-set))
  (when (and (functionp my/sis--raw-do-get)
             (functionp my/sis--raw-do-set))
    (setq sis-do-get #'my/sis--get-input-source
          sis-do-set #'my/sis--set-input-source)))

(use-package sis
  :straight (:host github :repo "laishulu/emacs-smart-input-source")
  :demand t
  :init
  ;; SIS handles ordinary Emacs prefix maps.  The pre-command hook below also
  ;; covers single-key commands such as C-n and M-x.
  (setq sis-prefix-override-keys
        '("C-c" "C-x" "C-h" "C-t" "M-g" "M-s"))
  :config
  (when (eq system-type 'darwin)
    (sis-ism-lazyman-config
     my/sis-english-source
     my/sis-other-source
     'macism)
    ;; `sis-ism-lazyman-config' sets the manager name to "macism".  Replace it
    ;; afterwards with an absolute path so GUI Emacs does not depend on PATH.
    (setq sis-external-ism
          (or (executable-find "macism") "/opt/homebrew/bin/macism"))
    ;; Initialize the original macOS reader/setter first, then wrap them so all
    ;; configured Chinese input sources are treated as SIS's `other' language.
    (sis--init-ism)
    (my/sis-enable-multiple-chinese-sources))

  (add-hook 'pre-command-hook #'my/sis-english-before-modified-command)
  (sis-global-respect-mode 1))

;; Keep input-source commands inside the existing Tools / System hierarchy.
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    my-leader-map
    "x i" "Input source"))

(with-eval-after-load 'general
  (my-leader-def
    "x i e" '("switch to English" . sis-set-english)
    "x i c" '("switch to Chinese" . sis-set-other)
    "x i t" '("toggle input source" . sis-switch)
    "x i s" '("show input source" . sis-get)))

(provide 'init-input-method)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - macOS 下按含 Ctrl、Alt 或 Meta 的命令键前，自动切换到 ABC 英文输入源。
;; - `C-c x i e/c/t/s'：切到英文/中文、切换输入源、显示当前输入源。
;; - 依赖外部 `macism' 命令；默认英文 ID 为 ABC。
;; - 微信输入法拼音、鼠须管简体和 macOS 自带拼音都会被识别为中文；临时切换
;;   到英文后，会恢复到最近实际使用的中文输入法。
;; - 若增加其他中文输入法，用 `macism' 查询 ID 后加入
;;   `my/sis-chinese-sources'，不需要替换现有项目。
;; - 普通文本输入不会被强制切换；只有执行配置的修饰键命令时才切到英文。
;; - 单独按 Enter/RET 不切换输入源；M-RET、C-RET 等明确带修饰键的命令仍会切换。
;;; init-input-method.el ends here
