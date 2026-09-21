;;; -*- lexical-binding: t -*-

;;; 中文导读：网络、远程访问、资讯、邮件与聊天集合。Server 支持 emacsclient，
;;; NSM 保存网络安全决策，TRAMP 经 SSH 编辑远程文件，EWW 浏览网页，Newsticker
;;; 阅读 RSS，Message/SMTPMail/Gnus 负责邮件与新闻组，ERC/rcirc 连接 IRC，
;;; Telega 连接 Telegram，tree-widget 定制树形控件。C-c n 打开 RSS；Newsticker
;;; 中 C-x k 退出。邮件服务器和账户应配合 auth-source 存放密码，不要写入本文件。
;; 全局用户身份与 URL 缓存目录设定
(setq user-full-name "zhaodaniu"
      user-mail-address "zhaodaniu1@gmail.com"
      url-configuration-directory (concat nn-directory "url/"))

;; Emacs Server 配置：自定义套接字/认证文件存放路径
(use-package server
  :ensure nil
  :custom (server-auth-dir (concat nn-directory "server/")))

;; 网络安全管理器 (Network Security Manager) 配置
(use-package nsm
  :ensure nil
  :custom (nsm-settings-file (concat nn-directory "network-security.eld")))

;; Ecomplete: 自动补全数据库（常用于邮件地址记忆）
(use-package ecomplete
  :ensure nil
  :custom (ecomplete-database-file (concat nn-directory "ecompleterc")))

;; MIME 解码设置：默认使用 shr 引擎渲染 HTML 邮件文本
(use-package mm-decode
  :ensure nil
  :custom (mm-text-html-renderer 'shr))

;; TRAMP 远程编辑与文件传输配置
(use-package tramp
  :ensure nil
  :init
  ;; 自动保存与持久化缓存路径重定向
  (setq tramp-auto-save-directory (concat nn-directory "tramp/auto-save/")
        tramp-persistency-file-name (concat nn-directory "tramp/persistency.el"))
  :custom
  (remote-file-name-inhibit-cache 60)              ; 远程文件属性缓存过期时间 (60秒)
  (remote-file-name-inhibit-locks t)               ; 禁用远程文件锁 (极大提升性能)
  (remote-file-name-inhibit-auto-save-visited t)   ; 禁用访问中的远程文件自动保存
  (tramp-verbose 1)                                ; 降低日志详细度，减少开销
  (tramp-copy-size-limit (* 1024 1024))           ; 超过 1MB 自动调用外部 SCP/RSYNC 传输
  (tramp-use-scp-direct-remote-copying t)          ; 开启 SCP 直接远程复制
  (tramp-completion-reread-directory-timeout 60)   ; 目录补全刷新间隔
  :config
  ;; 非 Windows 系统下，默认使用 SSH 协议
  (unless (eq system-type 'windows-nt)
    (setq tramp-default-method "ssh"))
  ;; 针对 scp 协议启用远程直接异步进程支持
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process))

;; EWW 内置 Web 浏览器配置
(use-package eww
  :ensure nil
  :custom (eww-search-prefix "https://lite.duckduckgo.com/lite/?q=") ; 设置纯文本 DuckDuckGo 搜索
  :config
  (add-to-list 'eww-url-transformers #'eww-remove-tracking)          ; 移除跟踪参数

  ;; Advice: 手动调用 eww 时强制全屏展示 Buffer
  (define-advice eww (:around (fn &rest args) myeww-open-in-fullscreen)
    "Open EWW in fullscreen if called interactively."
    (if (called-interactively-p 'any)
        (let ((display-buffer-alist '(("\\*eww\\*" (display-buffer-full-frame)))))
          (apply fn args))
      (apply fn args)))

  ;; 函数：获取页面 Title 作为 Buffer 名，空则降级使用 URL
  (defun my-eww-page-title-or-url ()
    "Use page title as buffer name, fallback to URL."
    (let ((title (plist-get eww-data :title)))
      (format "*%s # eww*" (if (string-blank-p title)
                               (plist-get eww-data :url)
                             title))))

  ;; 兼容性处理：为渲染/后退/前进操作绑定自动重命名 Hook/Advice
  (if (boundp 'eww-auto-rename-buffer)
      (setq eww-auto-rename-buffer #'my-eww-page-title-or-url)
    (defun my-eww--rename-buffer-h (&rest _)
      (rename-buffer (my-eww-page-title-or-url)))
    (add-hook 'eww-after-render-hook #'my-eww--rename-buffer-h)
    (advice-add 'eww-back-url :after #'my-eww--rename-buffer-h)
    (advice-add 'eww-forward-url :after #'my-eww--rename-buffer-h)))

;; Tree-Widget 树状控件美化（替换图形图标为简洁文本符号）
(use-package tree-widget
  :ensure nil
  :custom (tree-widget-image-enable nil)           ; 禁用图片的 Tree Icon
  :config
  (define-widget 'tree-widget-open-icon 'tree-widget-icon
    "Icon for an expanded tree-widget node." :tag "▼ ")
  (define-widget 'tree-widget-close-icon 'tree-widget-icon
    "Icon for a collapsed tree-widget node." :tag "▶ ")
  (define-widget 'tree-widget-empty-icon 'tree-widget-icon
    "Icon for an expanded node with no child." :tag "▼ ")
  (define-widget 'tree-widget-leaf-icon 'tree-widget-icon
    "Icon for a leaf node." :tag "")
  (define-widget 'tree-widget-guide 'item
    "Vertical guide line." :tag " " :format "%t")
  (define-widget 'tree-widget-nohandle-guide 'item
    "Vertical guide line, no handle." :tag " " :format "%t")
  (define-widget 'tree-widget-end-guide 'item
    "End of a vertical guide line." :tag " " :format "%t")
  (define-widget 'tree-widget-no-guide 'item
    "Invisible vertical guide line." :tag "  " :format "%t")
  (define-widget 'tree-widget-handle 'item
    "Horizontal guide line." :tag "" :format "%t")
  (define-widget 'tree-widget-no-handle 'item
    "Invisible handle." :tag " " :format "%t"))

;; Newsticker RSS/Atom 新闻订阅器
(use-package newsticker
  :ensure nil
  :bind
  (("C-c n" . my-newsticker-show-news)
   :map newsticker-treeview-mode-map
   ("C-x k" . newsticker-treeview-quit))
  :hook (newsticker-start . nn-proxy-enable)        ; 启动抓取时开启代理
  :custom
  (newsticker-dir (concat nn-directory "newsticker/data/"))
  (newsticker-cache-filename (concat nn-directory "newsticker/cache.el"))
  (newsticker-retrieval-interval 0)                 ; 关闭定时自动抓取（仅手动刷新）
  (newsticker-retrieval-method (if (executable-find "wget") 'extern 'intern)) ; 优先使用外部 wget
  (newsticker-wget-arguments
   '("--quiet" "--no-hsts" "--output-document=-" "--append-output=/dev/null"))
  (newsticker-automatically-mark-items-as-old nil)  ; 不自动将新条目标为旧条目
  (newsticker-url-list-defaults nil)
  (newsticker-url-list                             ; 订阅的 RSS 列表
   '(("Xkcd" "https://xkcd.com/rss.xml")
     ("Sacha Chua" "https://sachachua.com/blog/category/emacs-news/feed/")
     ("Planet Emacslife" "https://planet.emacslife.com/atom.xml")
     ("Emacs TIL" "https://emacstil.com/feed.xml")
     ("60秒看世界" "https://60s.viki.moe/v2/60s/rss")))
  :config
  ;; 自定义打开命令：拦截并屏蔽 `newsticker-start` 的自动再次启动
  (defun my-newsticker-show-news ()
    (interactive)
    (require 'newsticker)
    (cl-letf (((symbol-function 'newsticker-start) #'ignore))
      (newsticker-show-news))))

;; Message 邮件草稿与撰写模式
(use-package message
  :ensure nil
  :hook (message-mode . auto-fill-mode)             ; 编辑邮件时自动折行
  :custom
  (message-kill-buffer-on-exit t)                   ; 发送完毕后直接关闭 Buffer
  (message-signature user-full-name)                ; 签名档使用用户名
  (message-mail-alias-type 'ecomplete)              ; 使用 ecomplete 进行收件人地址自动补全
  (message-send-mail-function #'message-use-send-mail-function))

;; SMTPmail 邮件发送客户端
(use-package smtpmail
  :ensure nil
  :custom
  (send-mail-function 'smtpmail-send-it)
  (smtpmail-debug-info t)                          ; 开启 SMTP 调试信息输出
  (smtpmail-debug-verb t)
  (smtpmail-smtp-server "smtp.gmail.com")           ; 默认使用 Gmail SMTP
  (smtpmail-smtp-service 465)                      ; 端口 465 (SSL)
  (smtpmail-stream-type 'ssl)                      ; 加密流类型为 SSL
  (smtpmail-smtp-user user-mail-address)
  :config
  ;; 提供快捷命令，随时在 QQ 邮箱与 Gmail 发信服务器间切换
  (defun my-switch-qq-mail ()
    (interactive)
    (setq smtpmail-smtp-server "smtp.qq.com"))

  (defun my-switch-google-mail ()
    (interactive)
    (setq smtpmail-smtp-server "smtp.gmail.com"))

  (my-switch-google-mail))

;; Gnus 新闻组与邮件阅读系统
(use-package gnus
  :ensure nil
  :custom
  (gnus-init-file (concat nn-directory ".gnus.el"))
  (gnus-startup-file (concat nn-directory ".newsrc"))
  (gnus-always-read-dribble-file t)
  (gnus-activate-level 3)
  (gnus-use-cache t)                               ; 启用缓存
  (gnus-use-scoring nil)                            ; 禁用打分系统（提升速度）
  (gnus-use-full-window nil)
  (gnus-suppress-duplicates t)                      ; 自动去重
  (gnus-novice-user nil)
  (gnus-expert-user t)                              ; 开启专家模式（减少弹窗询问）
  (gnus-interactive-exit 'quiet)
  (gnus-save-killed-list nil)
  (gnus-check-new-newsgroups nil)
  (gnus-save-newsrc-file nil)                       ; 禁用 .newsrc 的存取（不与外部新闻阅读器交互）
  (gnus-read-newsrc-file nil)
  (gnus-subscribe-newsgroup-method 'gnus-subscribe-zombies)
  (gnus-search-use-parsed-queries t)
  ;; 文章只显示核心标头
  (gnus-visible-headers
   (rx line-start
       (or "From" "Subject"
           "Mail-Followup-To"
           "Date" "To" "Cc"
           "Newsgroups" "User-Agent"
           "X-Mailer" "X-Newsreader")
       ":"))
  (gnus-article-sort-functions
   '((not gnus-article-sort-by-number)
     (not gnus-article-sort-by-date)))
  (gnus-article-browse-delete-temp t)
  (gnus-mime-display-multipart-related-as-mixed t)
  (gnus-asynchronous t)                             ; 开启异步预加载支持
  (gnus-use-header-prefetch t)
  (gnus-cache-enter-articles '(ticked dormant unread))
  (gnus-cache-remove-articles '(read))
  (gnus-cacheable-groups "^\\(nntp\\Vert{}nnimap\\)")
  :config
  ;; 定制窗口配置：Summary 与 Article 左右 5:5 比例水平分栏
  (with-eval-after-load 'gnus-win
    (setf (alist-get 'article gnus-buffer-configuration)
          '((horizontal 1.0 (summary 0.5 point) (article 1.0)))))

  (setq gnus-logo-colors '("#ff5591" "#c0c0c0")
        gnus-select-method '(nnnil "")             ; 主方法为空，使用二级源
        gnus-secondary-select-methods
        '((nntp "news.gmane.io")                    ; 二级源 1: Gmane 新闻组
          (nnimap "imap.gmail.com"                  ; 二级源 2: Gmail IMAP
                  (nnimap-expunge t)
                  (nnimap-server-port 993)
                  (nnimap-stream ssl)))))

;; Gnus 分组列表模式 (Group Mode) 样式美化
(use-package gnus-group
  :ensure nil
  :hook (gnus-group-mode . gnus-topic-mode)        ; 默认开启分组主题视图
  :custom
  (gnus-group-line-format "%M%m%S%L%p%P %1(%7i%) %3(%7U%) %3(%7y%) %4(%B%-45G%) %d\n")
  (gnus-group-sort-function '(gnus-group-sort-by-level gnus-group-sort-by-alphabet))
  :config (require 'gnus-topic))

;; Gnus 文章列表与 Thread 树状图 (Summary Mode) 布局
(use-package gnus-sum
  :ensure nil
  :hook (gnus-select-group . gnus-group-set-timestamp)
  :custom
  ;; 使用 Unicode 字符高亮美化 Thread 关系树
  (gnus-sum-thread-tree-indent          "  ")
  (gnus-sum-thread-tree-single-indent   "◎ ")
  (gnus-sum-thread-tree-root            "┌ ")
  (gnus-sum-thread-tree-false-root      "◌ ")
  (gnus-sum-thread-tree-vertical        "│")
  (gnus-sum-thread-tree-leaf-with-other "├─►")
  (gnus-sum-thread-tree-single-leaf     "╰─►")
  (gnus-summary-line-format "%U%R %3d %[%-23,23f%] %B %s\n")
  (gnus-summary-make-false-root 'adopt)
  (gnus-simplify-subject-functions '(gnus-simplify-subject-re gnus-simplify-whitespace))
  (gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
  (gnus-fetch-old-headers 0)                       ; 进入组时不自动拉取旧标头（提升速度）
  (gnus-fetch-old-ephemeral-headers 0)
  (gnus-build-sparse-threads 'some)
  (gnus-show-threads t)
  (gnus-thread-indent-level 2)
  (gnus-thread-hide-subtree nil)
  (gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date))
  (gnus-subthread-sort-functions '(gnus-thread-sort-by-date))
  (gnus-view-pseudos 'automatic)
  (gnus-view-pseudos-separately t)
  (gnus-view-pseudo-asynchronously t)
  (gnus-auto-select-first nil)                      ; 关闭进入组时自动选中第一篇
  (gnus-auto-select-next nil)
  (gnus-paging-select-next nil))

;; Lightweight RCIRC 客户端配置
(use-package rcirc
  :ensure nil
  :custom
  (rcirc-debug t)
  (rcirc-default-nick user-full-name)
  (rcirc-default-user-name user-full-name)
  (rcirc-log-directory (concat nn-directory "rcirc-log/"))
  (rcirc-default-full-name user-full-name)
  (rcirc-server-alist                              ; 默认连接 Libera.Chat 频道
   '(("irc.libera.chat"
      :port 6697
      :encryption tls
      :channels ("#emacs" "#systemcrafters"))))
  (rcirc-reconnect-delay 5)                        ; 断线 5 秒重连
  (rcirc-fill-column 100)
  (rcirc-track-ignore-server-buffer-flag t)
  :config
  (make-directory (concat nn-directory "rcirc-log/") t)
  (setq rcirc-authinfo
        `(("irc.libera.chat"
           certfp
           ,(expand-file-name "cert.pem" user-emacs-directory) ; 基于 CertFP 证书认证身份
           ,(expand-file-name "cert.pem" user-emacs-directory)))))

;; Feature-rich ERC 客户端配置
(use-package erc
  :ensure nil
  :hook (erc-insert-modify . my-erc-colorize-nick)  ; 插入新消息时计算并高亮 Nick 颜色
  :custom
  (erc-image-cache-directory (concat nn-directory "erc/images/"))
  (erc-log-channels-directory (concat nn-directory "erc/log-channels/"))
  (erc-join-buffer 'window)
  (erc-hide-list '("JOIN" "PART" "QUIT"))          ; 屏蔽进出频道的冗余系统消息
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs" "#systemcrafters")))
  (erc-server-reconnect-attempts 10)
  (erc-server-reconnect-timeout 3)
  (erc-fill-function 'erc-fill-wrap)
  (erc-log-insert-log-on-open
   (if (fboundp 'erc-log-new-target-buffer-p)
       'erc-log-new-target-buffer-p
     t))
  (erc-save-buffer-on-part t)
  (erc-save-queries-on-quit t)
  (erc-log-write-after-send t)
  (erc-log-write-after-insert t)
  (erc-spelling-dictionaries '(("Libera.Chat" "en_US")))
  :config
  (make-directory (expand-file-name "erc/images/" nn-directory) t)
  (make-directory (expand-file-name "erc/log-channels/" nn-directory) t)

  (setopt erc-sasl-mechanism 'external)

  ;; 算法函数：依据 Nick 昵称计算 Sxhash 并映射到 Catppuccin 9 色调调色板
  (defun my-erc-get-color-for-nick (nick)
    "Return a Catppuccin Mocha Like color string for NICK based on its hash."
    (let* ((colors '("#f38ba8" "#a6e3a1" "#f9e2af" "#89b4fa"
                     "#cba6f7" "#fab387" "#b4befe" "#eba0ac"
                     "#f5c2e7"))
           (hash (mod (abs (sxhash nick)) (length colors))))
      (nth hash colors)))

  ;; 函数：正则扫描并应用 Nick Face 颜色
  (defun my-erc-colorize-nick ()
    "Colorize nicknames in ERC buffer."
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\(<\\)\\([^ >]+\\)\\(>\\)" nil t)
        (let* ((nick (match-string 2))
               (color (my-erc-get-color-for-nick nick)))
          (put-text-property (match-beginning 2) (match-end 2)
                             'face `(:foreground ,color :weight bold))))))

  (add-to-list 'erc-modules 'log)
  (add-to-list 'erc-modules 'sasl)

  ;; 交互命令：使用预设客户端证书直接发向 Libera.Chat 建立 SSL 连接
  (defun erc-liberachat ()
    (interactive)
    (let ((buf
           (erc-tls
            :server "irc.libera.chat"
            :port 6697
            :user user-full-name
            :password ""
            :client-certificate
            `(,(expand-file-name "cert.pem" user-emacs-directory)
              ,(expand-file-name "cert.pem" user-emacs-directory)))))
      (when (bufferp buf)
        (pop-to-buffer buf))))

  (erc-spelling-mode 1))

;; Telega: Emacs 内置 Telegram 客户端
(use-package telega
  :hook
  (telega-before-auth . my-telega-proxy)           ; 认证前加载 Socks5 代理
  (telega-chat-mode . telega-completions-setup-capf)
  (telega-image-mode . image-transform-fit-to-window)
  :custom
  (telega-server-libs-prefix "D:/local")            ; C 语言库加载前缀路径 (针对 Windows)
  (telega-avatar-workaround-gaps-for (when (display-graphic-p) '(return t)))
  (telega-translate-to-language-by-default "zh")   ; 默认翻译为中文
  (telega-msg-save-dir "~/Downloads")
  (telega-chat-input-markups '("markdown2" "org"))
  (telega-root-keep-cursor 'track)
  (telega-root-buffer-name "*Telega Root*")
  (telega-root-fill-column 70)
  (telega-emoji-use-images nil)                    ; 不渲染图片类 Emoji
  (telega-filters-custom nil)
  (telega-filter-custom-show-folders nil)
  ;; 将各种 UI 状态与控制项替换为 Nerd-Icons 矢量符号图标
  (telega-symbol-vertical-bar "│")
  (telega-symbol-mark (propertize " " 'face 'telega-button-highlight))
  (telega-symbol-button-close (nerd-icons-mdicon "nf-md-close_box_outline"))
  (telega-symbol-verified (nerd-icons-codicon "nf-cod-verified_filled" :face 'telega-blue))
  (telega-symbol-saved-messages-tag-end (nerd-icons-faicon "nf-fa-tag"))
  (telega-symbol-forum (nerd-icons-mdicon "nf-md-format_list_text"))
  (telega-symbol-reply-quote (nerd-icons-faicon "nf-fa-reply_all"))
  (telega-symbol-forward (nerd-icons-faicon "nf-fa-mail_forward"))
  (telega-symbol-checkmark (nerd-icons-mdicon "nf-md-check"))
  (telega-symbol-heavy-checkmark (nerd-icons-codicon "nf-cod-check_all"))
  (telega-symbol-summarize-in (nerd-icons-octicon "nf-oct-fold"))
  (telega-symbol-summarize-out (nerd-icons-octicon "nf-oct-unfold"))
  :config
  (telega-autoplay-mode 1)
  (telega-notifications-mode 1)
  (setq telega-symbols-emojify
        (cl-reduce
         (lambda (emojify key)
           (assq-delete-all key emojify))
         '(verified vertical-bar
           checkmark forum heavy-checkmark
           reply reply-quote horizontal-bar
           forward button-close summarize-in summarize-out)
         :initial-value telega-symbols-emojify))

  ;; 代理注入回调函数
  (defun my-telega-proxy ()
    (telega--addProxy
        `(:server "localhost"
          :port ,nn-proxy-port
          :type (:@type "proxyTypeSocks5"))
      :enable-p 'enable))

  ;; Windows 专用 Advice：强制使用控制台/Pipe 通信方式重构启动进程，解决无法建立子进程通道的问题
  (when (eq system-type 'windows-nt)
    (define-advice telega-server--start (:around (fn &rest args) my-telega-server--start)
      (apply fn args)
      (let* ((buf telega-server--buffer)
             (cmd (process-command (get-buffer-process buf))))
        (delete-process (get-buffer-process buf))
        (make-process
         :coding '(binary . utf-8)
         :name "telega-server"
         :buffer buf
         :command cmd
         :noquery t
         :sentinel #'telega-server--sentinel
         :filter #'telega-server--filter
         :connection-type 'pipe
         :stderr (make-pipe-process
                  :name "telega-server--stderr"
                  :buffer " *telega-server--stderr*"
                  :noquery t))))))
                  
(provide 'init-www)
