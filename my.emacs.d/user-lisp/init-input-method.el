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

(defcustom my/sis-keep-input-source-commands
  '(next-line previous-line
    forward-char backward-char right-char left-char
    forward-word backward-word
    move-beginning-of-line move-end-of-line beginning-of-line end-of-line
    beginning-of-buffer end-of-buffer
    forward-paragraph backward-paragraph
    forward-sentence backward-sentence
    forward-sexp backward-sexp up-list backward-up-list down-list
    beginning-of-defun end-of-defun
    scroll-up-command scroll-down-command scroll-up scroll-down
    recenter-top-bottom
    other-window windmove-left windmove-right windmove-up windmove-down
    next-buffer previous-buffer
    goto-char goto-line
    next-error previous-error
    flymake-goto-next-error flymake-goto-prev-error
    xref-go-back xref-go-forward
    outline-next-visible-heading outline-previous-visible-heading
    outline-up-heading
    dired-next-line dired-previous-line
    vertico-next vertico-previous vertico-next-group vertico-previous-group
    avy-goto-char avy-goto-char-timer avy-goto-line avy-goto-word-1
    avy-goto-symbol-1
    org-next-visible-heading org-previous-visible-heading
    org-forward-heading-same-level org-backward-heading-same-level
    org-up-heading-safe
    my-scroll-half-screen-up my-scroll-half-screen-down
    my/vimish-fold-next my/vimish-fold-previous)
  "Commands that should keep the current input state.

These commands only move the point, window, or selection.  They remain usable
while a Chinese input method is active, without switching either the input
source or the Chinese input method's internal Chinese/English state."
  :type '(repeat function)
  :group 'convenience)

(defcustom my/sis-try-shift-before-system-english t
  "Whether command input should try the Chinese input method's Shift toggle.

When non-nil, a modified non-navigation command first sends one isolated Shift
key.  If sending Shift fails, fall back to the system English input source."
  :type 'boolean
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

(defun my/sis-chinese-source-p (source)
  "Return non-nil when SOURCE is one of the configured Chinese sources."
  (and (stringp source) (member source my/sis-chinese-sources)))

(defvar my/sis--shift-english-source nil
  "Chinese input source whose internal English state was enabled by Shift.")

(defun my/sis-current-raw-source ()
  "Return the concrete current macOS input source, or nil if unavailable."
  (when (functionp my/sis--raw-do-get)
    (ignore-errors (funcall my/sis--raw-do-get))))

(defun my/sis-reset-shift-state (&rest _)
  "Forget the cached internal English state of a Chinese input method."
  (setq my/sis--shift-english-source nil))

(defun my/sis-keep-input-source-command-p (&optional command)
  "Return non-nil when COMMAND should not change the current input state.

In addition to `my/sis-keep-input-source-commands', a command may opt in by
setting its `my/sis-keep-input-source' symbol property to non-nil."
  (let ((command (or command this-command)))
    (or (memq command my/sis-keep-input-source-commands)
        (and (symbolp command)
             (get command 'my/sis-keep-input-source)))))

(defun my/sis-send-shift-toggle ()
  "Send one isolated left Shift key through macOS System Events.
Return non-nil only when the event was sent successfully."
  (let ((osascript (executable-find "osascript")))
    (and osascript
         (condition-case nil
             (zerop
              (process-file
               osascript nil nil nil
               "-e" "tell application \"System Events\" to key code 56"))
           (error nil)))))

(defun my/sis-switch-command-input-to-english ()
  "Make command input English, preferring the IME's Shift toggle.

macOS exposes the selected input source but not the Chinese input method's
internal Chinese/English state.  A successfully sent Shift is therefore
cached for the current concrete Chinese source.  If Shift cannot be sent,
switch to the system English source through SIS."
  (let ((source (my/sis-current-raw-source)))
    (cond
     ((null source)
      (my/sis-reset-shift-state)
      (sis-set-english))
     ((not (my/sis-chinese-source-p source))
      (my/sis-reset-shift-state))
     ((equal source my/sis--shift-english-source)
      t)
     ((and my/sis-try-shift-before-system-english
           (my/sis-send-shift-toggle))
      (setq my/sis--shift-english-source source))
     (t
      (my/sis-reset-shift-state)
      (sis-set-english)))))

(defun my/sis-english-before-modified-command ()
  "Prepare English for modified commands except pure navigation commands."
  (when (and (my/sis-modified-command-p)
             (not (my/sis-keep-input-source-command-p)))
    (my/sis-switch-command-input-to-english)))

(defun my/sis-refresh-shift-state-after-source-change ()
  "Clear cached Shift state after changing to another input source."
  (unless (equal (my/sis-current-raw-source)
                 my/sis--shift-english-source)
    (my/sis-reset-shift-state)))

(defun my/sis-track-self-insert-state ()
  "Infer the Chinese input method's internal state after text insertion."
  (let ((source (my/sis-current-raw-source)))
    (when (and (characterp last-command-event)
               (my/sis-chinese-source-p source))
      (if (> last-command-event 127)
          (my/sis-reset-shift-state)
        ;; An ASCII insertion while the Chinese source remains selected means
        ;; its internal English state is active (usually selected by Shift).
        (setq my/sis--shift-english-source source)))))

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
  ;; Do not let SIS force prefix keys directly to the system English source.
  ;; Our pre-command hook can distinguish navigation from commands that need
  ;; English, and can therefore apply the Shift-first policy consistently.
  (setq sis-prefix-override-keys nil)
  :config
  ;; Reloading this file must also uninstall prefix translations left by the
  ;; previous configuration before `sis-prefix-override-keys' became nil.
  (when (bound-and-true-p sis-global-respect-mode)
    (sis-global-respect-mode -1))

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
    (advice-add 'sis--set-english :before #'my/sis-reset-shift-state)
    (advice-add 'sis--set-other :before #'my/sis-reset-shift-state)
    (add-hook 'pre-command-hook #'my/sis-english-before-modified-command)
    (add-hook 'post-self-insert-hook #'my/sis-track-self-insert-state)
    (add-hook 'sis-change-hook #'my/sis-refresh-shift-state-after-source-change)
    (sis-global-respect-mode 1)))

;; Keep input-source commands inside the existing Tools / System hierarchy.
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    my-leader-map
    "x i" "输入源"))

(with-eval-after-load 'general
  (my-leader-def
    "x i e" '("切换到英文" . sis-set-english)
    "x i c" '("切换到中文" . sis-set-other)
    "x i t" '("切换输入源" . sis-switch)
    "x i s" '("显示输入源" . sis-get)))

(provide 'init-input-method)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-n'、`C-p'、`M-f' 等只负责定位/滚动/选择的命令保持当前中文状态，
;;   不再触发输入法切换；完整列表见 `my/sis-keep-input-source-commands'。
;; - 其他含 Ctrl、Alt 或 Meta 的命令会先向当前中文输入法发送一次 Shift，
;;   使用输入法自身的中英文切换；发送失败时才回退到 ABC 系统英文输入源。
;; - Shift 由 macOS System Events 发送；第一次使用时系统可能要求为 Emacs 开启
;;   “系统设置 -> 隐私与安全性 -> 辅助功能”权限。无权限时会自动走 ABC 兜底。
;; - macOS 无法报告搜狗/微信/鼠须管内部的中英文状态，因此配置会缓存成功的
;;   Shift 切换，避免连续命令反复切换；输入中文或显式切换输入源时自动重置。
;; - `C-c x i e/c/t/s'：切到英文/中文、切换输入源、显示当前输入源。
;; - 依赖外部 `macism' 命令；默认英文 ID 为 ABC。
;; - 搜狗拼音、微信输入法拼音、鼠须管简体和 macOS 自带拼音都会被识别为中文；
;;   临时切换到英文后，会恢复到最近实际使用的中文输入法。
;; - 若增加其他中文输入法，用 `macism' 查询 ID 后加入
;;   `my/sis-chinese-sources'，不需要替换现有项目。
;; - 普通文本输入不会被强制切换；只有非定位类的修饰键命令才准备英文状态。
;; - 单独按 Enter/RET 不切换输入源；M-RET、C-RET 等明确带修饰键的命令仍会切换。
;;; init-input-method.el ends here
