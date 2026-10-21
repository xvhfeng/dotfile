;;; init-input-method.el --- Manual macOS input-source switching -*- lexical-binding: t; -*-

(require 'seq)

(declare-function sis--init-ism "sis" ())
(declare-function sis--get "sis" ())
(defvar sis-do-get)
(defvar sis-do-set)

(defconst my/sis-english-source "com.apple.keylayout.ABC"
  "手动切换时使用的 macOS 英文输入源 ID。")

(defconst my/sis-other-source "com.sogou.inputmethod.pinyin"
  "手动切换时默认使用的中文输入源 ID。")

(defun my/sis-unique-input-sources (sources)
  "返回 SOURCES 中顺序不变、且已去重的有效输入法 ID 列表。"
  (delete-dups (seq-filter #'stringp (copy-sequence sources))))

(defcustom my/sis-chinese-sources
  (my/sis-unique-input-sources
   '("com.sogou.inputmethod.pinyin"
     "com.tencent.inputmethod.wetype.pinyin"
     "im.rime.inputmethod.Squirrel.Hans"
     "com.apple.inputmethod.SCIM.ITABC"))
  "手动查询或切换时识别为中文的 macOS 输入源 ID。"
  :type '(repeat string)
  :group 'convenience)

;; 中文说明：Custom 文件可能保存过重复 ID，规范化后再交给 SIS。
(setq my/sis-chinese-sources
      (my/sis-unique-input-sources my/sis-chinese-sources))

(defvar my/sis-last-chinese-source my/sis-other-source
  "最近一次手动查询时发现的中文输入源。")

(defvar my/sis--raw-do-get nil
  "SIS 原始的 macOS 输入源读取函数。")

(defvar my/sis--raw-do-set nil
  "SIS 原始的 macOS 输入源设置函数。")

(defun my/sis-chinese-source-p (source)
  "当 SOURCE 属于已配置的中文输入源时返回非 nil。"
  (and (stringp source) (member source my/sis-chinese-sources)))

(defun my/sis--canonicalize-input-source (source)
  "将中文 SOURCE 映射为 SIS 的统一中文输入源。"
  (if (my/sis-chinese-source-p source)
      (progn
        (setq my/sis-last-chinese-source source)
        my/sis-other-source)
    source))

(defun my/sis--expand-input-source (source)
  "将 SIS 的中文 SOURCE 展开为最近手动查询到的中文输入源。"
  (if (equal source my/sis-other-source)
      (if (my/sis-chinese-source-p my/sis-last-chinese-source)
          my/sis-last-chinese-source
        my/sis-other-source)
    source))

(defun my/sis--get-input-source ()
  "仅在用户调用 SIS 查询或切换命令时读取当前输入源。"
  (my/sis--canonicalize-input-source (funcall my/sis--raw-do-get)))

(defun my/sis--set-input-source (source)
  "由 SIS 手动命令设置 SOURCE，并保留最近使用的中文输入源。"
  (funcall my/sis--raw-do-set (my/sis--expand-input-source source)))

(defun my/sis-enable-multiple-chinese-sources ()
  "让 SIS 的手动命令识别和恢复多个中文输入源。"
  (unless (and (functionp my/sis--raw-do-get)
               (functionp my/sis--raw-do-set))
    (setq my/sis--raw-do-get sis-do-get
          my/sis--raw-do-set sis-do-set))
  (when (and (functionp my/sis--raw-do-get)
             (functionp my/sis--raw-do-set))
    (setq sis-do-get #'my/sis--get-input-source
          sis-do-set #'my/sis--set-input-source)))

(defun my/sis-switch ()
  "查询当前输入源后，在英文与中文之间手动切换。"
  (interactive)
  ;; 中文说明：关闭 SIS 自动刷新后，先同步其状态，避免外部切换导致方向相反。
  (sis--get)
  (sis-switch))

(use-package sis
  :straight (:host github :repo "laishulu/emacs-smart-input-source")
  :demand t
  :init
  ;; 中文说明：前缀键不再触发 SIS 自动切换。
  (setq sis-prefix-override-keys nil)
  :config
  ;; 中文说明：重载配置时清理旧版安装的自动钩子、advice 和全局模式。
  (remove-hook 'pre-command-hook 'my/sis-english-before-modified-command)
  (remove-hook 'post-self-insert-hook 'my/sis-track-self-insert-state)
  (remove-hook 'sis-change-hook 'my/sis-refresh-shift-state-after-source-change)
  (advice-remove 'sis--set-english 'my/sis-reset-shift-state)
  (advice-remove 'sis--set-other 'my/sis-reset-shift-state)
  (when (bound-and-true-p sis-global-respect-mode)
    (sis-global-respect-mode -1))
  (when (bound-and-true-p sis-auto-refresh-mode)
    (sis-auto-refresh-mode -1))

  (when (eq system-type 'darwin)
    (let ((macism (executable-find "macism")))
      (if macism
          (progn
            (sis-ism-lazyman-config
             my/sis-english-source my/sis-other-source 'macism)
            ;; 中文说明：GUI Emacs 的 PATH 可能不同，使用已经验证的绝对路径。
            (setq sis-external-ism macism)
            (sis--init-ism)
            (my/sis-enable-multiple-chinese-sources))
        ;; 中文说明：当前 Emacs 无原生切换接口；缺少 macism 时手动命令不可用。
        (setq sis-do-get nil
              sis-do-set nil)))))

;; 手动入口保留在原有的工具菜单中。
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    my-leader-map
    "x i" "输入源"))

(with-eval-after-load 'general
  (my-leader-def
    "x i e" '("切换到英文" . sis-set-english)
    "x i c" '("切换到中文" . sis-set-other)
    "x i t" '("切换输入源" . my/sis-switch)
    "x i s" '("显示输入源" . sis-get)))

(provide 'init-input-method)

;; 手动输入源命令：C-c x i e/c/t/s。没有按键、输入或缓冲区切换时的自动检测与切换。
;;; init-input-method.el ends here
