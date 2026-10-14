;;; init-mail.el --- IMAP/SMTP mail with Gnus and Message -*- lexical-binding: t; -*-

(require 'seq)
(require 'subr-x)

(defgroup my-mail nil
  "Provider-neutral mail settings for Gnus and smtpmail."
  :group 'mail)

(defcustom my/mail-address nil
  "Email address used in the From header."
  :type '(choice (const :tag "Not configured" nil) string)
  :group 'my-mail)

(defcustom my/mail-full-name user-full-name
  "Full name used in outgoing messages."
  :type 'string
  :group 'my-mail)

(defcustom my/mail-user nil
  "IMAP/SMTP login name; nil means use `my/mail-address'."
  :type '(choice (const :tag "Use email address" nil) string)
  :group 'my-mail)

(defcustom my/mail-imap-server nil
  "IMAP server hostname, for example imap.example.com."
  :type '(choice (const :tag "Not configured" nil) string)
  :group 'my-mail)

(defcustom my/mail-imap-port 993
  "TLS IMAP server port."
  :type 'integer
  :group 'my-mail)

(defcustom my/mail-smtp-server nil
  "SMTP server hostname, for example smtp.example.com."
  :type '(choice (const :tag "Not configured" nil) string)
  :group 'my-mail)

(defcustom my/mail-smtp-port 587
  "SMTP submission port."
  :type 'integer
  :group 'my-mail)

(defcustom my/mail-smtp-stream-type 'starttls
  "TLS mode used to send mail.
Use `starttls' with port 587 or `ssl' with port 465."
  :type '(choice (const starttls) (const ssl))
  :group 'my-mail)

(defcustom my/mail-account-name "personal"
  "Short internal name used for the Gnus IMAP account."
  :type 'string
  :group 'my-mail)

(defconst my/mail-runtime-directory (my/runtime-file "mail/")
  "Directory for Gnus state, cache and draft files.")

(defun my/mail--nonempty-string-p (value)
  "Return non-nil when VALUE is a nonempty string."
  (and (stringp value) (not (string-empty-p value))))

(defun my/mail-missing-settings ()
  "Return names of required account settings that are still empty."
  (delq nil
        (list (unless (my/mail--nonempty-string-p my/mail-address)
                'my/mail-address)
              (unless (my/mail--nonempty-string-p my/mail-imap-server)
                'my/mail-imap-server)
              (unless (my/mail--nonempty-string-p my/mail-smtp-server)
                'my/mail-smtp-server))))

(defun my/mail-configure-account (&optional quiet)
  "Apply account settings to Gnus and smtpmail.
When QUIET is non-nil, do not print a success message."
  (interactive)
  (if-let ((missing (my/mail-missing-settings)))
      (user-error "Mail is not configured; set %s with M-x customize-group RET my-mail"
                  (mapconcat #'symbol-name missing ", "))
    (let ((login (or my/mail-user my/mail-address)))
      (make-directory my/mail-runtime-directory t)
      (setq user-mail-address my/mail-address
            user-full-name my/mail-full-name
            mail-user-agent 'message-user-agent
            read-mail-command #'my/mail-open
            message-send-mail-function #'smtpmail-send-it
            send-mail-function #'smtpmail-send-it
            smtpmail-smtp-server my/mail-smtp-server
            smtpmail-smtp-service my/mail-smtp-port
            smtpmail-stream-type my/mail-smtp-stream-type
            smtpmail-smtp-user login
            gnus-select-method
            `(nnimap ,my/mail-account-name
                     (nnimap-address ,my/mail-imap-server)
                     (nnimap-server-port ,my/mail-imap-port)
                     (nnimap-stream ssl)
                     (nnimap-user ,login)))
      (unless quiet
        (message "Mail account %s configured for %s"
                 my/mail-account-name my/mail-address)))))

(defun my/mail-open ()
  "Validate the account and open Gnus."
  (interactive)
  (my/mail-configure-account t)
  (gnus))

(defun my/mail-compose ()
  "Validate the account and compose a new message."
  (interactive)
  (my/mail-configure-account t)
  (compose-mail))

(defun my/mail-customize ()
  "Open the account settings form."
  (interactive)
  (customize-group 'my-mail))

(use-package auth-source
  :straight nil
  :config
  ;; Prefer an encrypted authinfo file and never save a prompted password as
  ;; plaintext.  Existing auth-source backends are preserved.
  (add-to-list 'auth-sources (expand-file-name "~/.authinfo.gpg"))
  (setq auth-source-save-behavior nil
        password-cache-expiry 3600))

(use-package gnus
  :straight nil
  :commands gnus
  :custom
  (gnus-startup-file (expand-file-name "newsrc" my/mail-runtime-directory))
  (gnus-directory (expand-file-name "news/" my/mail-runtime-directory))
  (gnus-cache-directory (expand-file-name "cache/" my/mail-runtime-directory))
  (gnus-use-cache t)
  (gnus-use-full-window nil)
  (gnus-read-active-file 'some)
  (gnus-fetch-old-headers nil)
  (gnus-summary-thread-gathering-function #'gnus-gather-threads-by-references)
  (gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date)))

(use-package message
  :straight nil
  :custom
  (message-directory (expand-file-name "messages/" my/mail-runtime-directory))
  (message-auto-save-directory
   (expand-file-name "drafts/" my/mail-runtime-directory))
  (message-kill-buffer-on-exit t)
  (message-sendmail-envelope-from 'header)
  (mail-specify-envelope-from t))

(use-package smtpmail
  :straight nil
  :custom
  (smtpmail-debug-info nil)
  (smtpmail-debug-verb nil))

(use-package mm-decode
  :straight nil
  :custom
  (mm-text-html-renderer 'shr)
  (mm-discouraged-alternatives '("text/html" "text/richtext")))

(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements my-leader-map "m" "Mail"))

(with-eval-after-load 'general
  (my-leader-def
    "m m" '("open mail" . my/mail-open)
    "m c" '("compose mail" . my/mail-compose)
    "m a" '("mail account settings" . my/mail-customize))

  (general-define-key
   :keymaps 'gnus-group-mode-map
   "g" '("check new mail" . gnus-group-get-new-news)
   "RET" '("open group" . gnus-group-select-group)
   "q" '("quit Gnus" . gnus-group-exit))

  (general-define-key
   :keymaps 'gnus-summary-mode-map
   "RET" '("scroll article" . gnus-summary-scroll-up)
   "r" '("reply" . gnus-summary-reply)
   "R" '("reply with original" . gnus-summary-reply-with-original)
   "f" '("reply all" . gnus-summary-followup)
   "F" '("reply all with original" . gnus-summary-followup-with-original)
   "q" '("back to groups" . gnus-summary-exit))

  (general-define-key
   :keymaps 'message-mode-map
   "C-c C-c" '("send message" . message-send-and-exit)
   "C-c C-k" '("discard draft" . message-kill-buffer)
   "C-c C-a" '("attach file" . mml-attach-file)))

(provide 'init-mail)

;; ==========================================================================
;; 使用说明（全部为注释，不参与加载）
;; ==========================================================================
;; 1. 第一次使用先执行：
;;      M-x customize-group RET my-mail
;;    至少填写：邮箱地址、IMAP 服务器、SMTP 服务器。用户名默认等于邮箱地址。
;;    常见端口：IMAP SSL=993；SMTP STARTTLS=587；SMTP SSL=465。
;;
;; 2. 密码不要写进本文件。建立 ~/.authinfo.gpg，内容示例：
;;      machine imap.example.com login you@example.com password 应用专用密码 port 993
;;      machine smtp.example.com login you@example.com password 应用专用密码 port 587
;;    然后执行 M-x epa-file-enable，再保存该文件。GnuPG 会加密它。
;;    Gmail、QQ、163 等通常要求使用“应用专用密码/授权码”，不是网页登录密码。
;;
;; 3. 全局入口：
;;    - C-c m a       打开邮箱账号设置。
;;    - C-c m m       打开 Gnus 收件箱。
;;    - C-c m c       撰写新邮件。
;;
;; 4. Gnus 组列表（邮箱文件夹）快捷键：
;;    - g             检查新邮件。
;;    - RET           进入光标所在邮箱文件夹。
;;    - q             保存状态并退出 Gnus。
;;    - L             显示全部服务器组；u 订阅/取消订阅光标处组。
;;
;; 5. 邮件列表快捷键：
;;    - RET / SPC     阅读并向下滚动邮件。
;;    - r / R         回复发件人 / 回复并引用原文。
;;    - f / F         回复所有人 / 回复所有人并引用原文。
;;    - C-c C-f       转发邮件。
;;    - n / p         下一封 / 上一封邮件。
;;    - q             返回邮箱文件夹列表。
;;
;; 6. 写信窗口快捷键：
;;    - C-c C-a       添加附件。
;;    - C-c C-c       发送并关闭写信窗口。
;;    - C-c C-k       放弃当前草稿。
;;    - C-c C-f C-c   跳到抄送（Cc）字段。
;;    - C-c C-f C-b   跳到密送（Bcc）字段。
;;
;; 7. 常见服务器示例（实际值以服务商文档为准）：
;;    - Gmail: imap.gmail.com / smtp.gmail.com
;;    - QQ:    imap.qq.com    / smtp.qq.com
;;    - 163:   imap.163.com   / smtp.163.com
;;    邮件服务商若未开启 IMAP/SMTP，需先在网页版邮箱设置中启用。
;; ==========================================================================
;;; init-mail.el ends here
