;;; init-input-method.el --- Smart macOS input-source switching -*- lexical-binding: t; -*-

(require 'seq)

(defconst my/sis-english-source "com.apple.keylayout.ABC"
  "macOS input-source id used for English commands.")

(defconst my/sis-other-source "com.tencent.inputmethod.wetype.pinyin"
  "macOS input-source id used for Chinese text input.")

(defcustom my/sis-command-modifiers '(control meta alt)
  "Modifiers that make the next Emacs command switch to English."
  :type '(repeat symbol)
  :group 'convenience)

(defun my/sis-modified-command-p (&optional keys)
  "Return non-nil when KEYS contains a configured command modifier.
When KEYS is nil, inspect the key sequence of the current command."
  (seq-some
   (lambda (event)
     (seq-some (lambda (modifier)
                 (memq modifier my/sis-command-modifiers))
               (event-modifiers event)))
   (or keys (this-command-keys-vector))))

(defun my/sis-english-before-modified-command ()
  "Switch to English before a Ctrl/Alt/Meta command is executed."
  (when (my/sis-modified-command-p)
    (sis-set-english)))

(use-package sis
  :straight (:host github :repo "laishulu/emacs-smart-input-source")
  :demand t
  :init
  ;; SIS handles ordinary Emacs prefix maps.  The pre-command hook below also
  ;; covers single-key commands such as C-n and M-x.
  (setq sis-prefix-override-keys
        '("C-c" "C-x" "C-h" "C-z" "C-t" "M-g" "M-s"))
  :config
  (when (eq system-type 'darwin)
    (sis-ism-lazyman-config
     my/sis-english-source
     my/sis-other-source
     'macism)
    ;; `sis-ism-lazyman-config' sets the manager name to "macism".  Replace it
    ;; afterwards with an absolute path so GUI Emacs does not depend on PATH.
    (setq sis-external-ism
          (or (executable-find "macism") "/opt/homebrew/bin/macism")))

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
;; - `C-z x i e/c/t/s'：切到英文/中文、切换输入源、显示当前输入源。
;; - 依赖外部 `macism' 命令；默认英文 ID 为 ABC，中文 ID 为微信输入法拼音。
;; - 若使用其他输入法，用 `macism' 查询 ID 后修改 `my/sis-other-source'。
;; - 普通文本输入不会被强制切换；只有执行配置的修饰键命令时才切到英文。
;;; init-input-method.el ends here
