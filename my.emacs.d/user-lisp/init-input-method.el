;;; init-input-method.el --- Smart macOS input-source switching -*- lexical-binding: t; -*-

(require 'seq)

(declare-function sis--init-ism "sis" ())
(defvar sis-do-get)
(defvar sis-do-set)

(defconst my/sis-english-source "com.apple.keylayout.ABC"
  "macOS input-source id used for English commands.")

(defconst my/sis-other-source "com.sogou.inputmethod.pinyin"
  "当前机器默认用于中文输入的搜狗拼音 macOS input-source id。")

(defun my/sis-unique-input-sources (sources)
  "返回 SOURCES 中顺序不变、且已去重的有效输入法 ID 列表。"
  (delete-dups (seq-filter #'stringp (copy-sequence sources))))

(defcustom my/sis-chinese-sources
  (my/sis-unique-input-sources
   '("com.sogou.inputmethod.pinyin"
    "com.tencent.inputmethod.wetype.pinyin"
    "im.rime.inputmethod.Squirrel.Hans"
    "com.apple.inputmethod.SCIM.ITABC"))
  "macOS input-source ids that SIS should recognize as Chinese.

列表包含当前机器正在使用的搜狗拼音，以及微信输入法、鼠须管简体和
macOS 自带拼音；加载时会自动去重。"
  :type '(repeat string)
  :group 'convenience)

;; Custom 文件可能保存过旧列表；再次规范化可确保用户手动添加相同 ID 时不重复。
(setq my/sis-chinese-sources
      (my/sis-unique-input-sources my/sis-chinese-sources))

(defvar my/sis-last-chinese-source my/sis-other-source
  "Most recently observed Chinese input source.")

(defvar my/sis--raw-do-get nil
  "Original SIS function used to read the macOS input source.")

(defvar my/sis--raw-do-set nil
  "Original SIS function used to set the macOS input source.")

(defvar my/sis-macos-backend-available nil
  "非 nil 表示已找到可安全调用的 macism 输入法切换后端。")

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
    (let ((macism (executable-find "macism")))
      (if macism
          (progn
            (sis-ism-lazyman-config
             my/sis-english-source
             my/sis-other-source
             'macism)
            ;; 使用已验证存在的绝对路径，避免 GUI Emacs 的 PATH 差异。
            (setq sis-external-ism macism)
            ;; 先初始化原始读写函数，再包装多中文输入法的识别逻辑。
            (sis--init-ism)
            (my/sis-enable-multiple-chinese-sources)
            (setq my/sis-macos-backend-available t))
        ;; 当前 Emacs 构建没有 mac-select-input-source；无 macism 时绝不能
        ;; 回退到 emp，否则首次切换会调用未定义函数并产生运行时警告。
        (setq my/sis-macos-backend-available nil
              sis-do-get nil
              sis-do-set nil))))

  ;; 只有后端可用才接管按键和 Buffer 输入法状态，避免无后端时干扰编辑。
  (when my/sis-macos-backend-available
    (add-hook 'pre-command-hook #'my/sis-english-before-modified-command)
    (sis-global-respect-mode 1)))

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
;; - 搜狗拼音、微信输入法拼音、鼠须管简体和 macOS 自带拼音都会被识别为中文；
;;   临时切换到英文后，会恢复到最近实际使用的中文输入法。
;; - 若增加其他中文输入法，用 `macism' 查询 ID 后加入
;;   `my/sis-chinese-sources'，不需要替换现有项目。
;; - 普通文本输入不会被强制切换；只有执行配置的修饰键命令时才切到英文。
;; - 单独按 Enter/RET 不切换输入源；M-RET、C-RET 等明确带修饰键的命令仍会切换。
;;; init-input-method.el ends here
