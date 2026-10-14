;;; init-org.el --- Org notes, tasks, agenda and Babel -*- lexical-binding: t; -*-

(defgroup my-org nil
  "Personal Org workflow."
  :group 'org)

(defcustom my/org-directory (expand-file-name "~/org/")
  "Directory containing notes, tasks, journal and agenda files."
  :type 'directory
  :group 'my-org)

(defconst my/org-runtime-directory (my/runtime-file "org/")
  "Directory for Org caches and persistent runtime state.")

(defun my/org-file (name)
  "Return the absolute Org file path for NAME."
  (expand-file-name name my/org-directory))

(defun my/org-ensure-directories (&rest _)
  "Create Org data and runtime directories when an Org command needs them."
  (make-directory my/org-directory t)
  (make-directory my/org-runtime-directory t))

(defun my/org-open-inbox ()
  "Open the Org inbox file."
  (interactive)
  (my/org-ensure-directories)
  (find-file (my/org-file "inbox.org")))

(use-package org
  :straight nil
  :commands (org-agenda org-capture org-store-link org-switchb)
  :general
  (:keymaps 'org-mode-map
   "C-c C-S-l" '("toggle link display" . org-toggle-link-display)
   "C-<return>" '("insert heading" . org-insert-heading-respect-content)
   "C-S-<return>" '("insert TODO heading" . org-insert-todo-heading-respect-content)
   "C-M-<return>" '("insert subheading" . org-insert-subheading)
   "C-c '" '("edit source block" . org-edit-special)
   "C-c C-," '("insert structure" . org-insert-structure-template)
   "C-c C-t" '("change TODO state" . org-todo)
   "C-c C-q" '("set tags" . org-set-tags-command)
   "C-c C-d" '("set deadline" . org-deadline)
   "C-c C-s" '("schedule" . org-schedule)
   "C-c ." '("insert timestamp" . org-time-stamp)
   "C-c !" '("insert inactive timestamp" . org-time-stamp-inactive)
   "C-c C-o" '("open at point" . org-open-at-point)
   "C-c C-l" '("insert link" . org-insert-link)
   "C-c *" '("toggle heading" . org-ctrl-c-star)
   "C-c -" '("toggle list item" . org-ctrl-c-minus))
  :hook
  ((org-mode . visual-line-mode)
   (org-babel-after-execute . org-redisplay-inline-images))
  :custom
  (org-directory my/org-directory)
  (org-default-notes-file (my/org-file "inbox.org"))
  (org-persist-directory (expand-file-name "persist/" my/org-runtime-directory))
  (org-id-locations-file (expand-file-name "id-locations.el" my/org-runtime-directory))
  (org-publish-timestamp-directory
   (expand-file-name "timestamps/" my/org-runtime-directory))
  (org-support-shift-select t)
  (org-auto-align-tags nil)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-pretty-entities t)
  (org-ellipsis " … ")
  (org-enforce-todo-dependencies t)
  (org-tags-column 0)
  ;; Keep confirmation enabled because Babel blocks can execute local commands.
  (org-confirm-babel-evaluate t)
  (org-catch-invisible-edits 'show-and-error)
  (org-hide-emphasis-markers t)
  (org-hide-leading-stars t)
  (org-image-actual-width nil)
  (org-special-ctrl-a/e t)
  (org-M-RET-may-split-line nil)
  (org-insert-heading-respect-content t)
  (org-indirect-buffer-display 'current-window)
  (org-fontify-done-headline t)
  (org-fontify-quote-and-verse-blocks t)
  (org-fontify-whole-heading-line t)
  (org-src-tab-acts-natively t)
  (org-src-fontify-natively t)
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-use-sub-superscripts '{})
  (org-todo-keywords
   '((sequence
      "TODO(t)" "PROJ(p)" "STRT(s)" "WAIT(w)" "HOLD(h)" "IDEA(i)"
      "|" "DONE(d)" "KILL(k)")))
  (org-babel-load-languages
   '((emacs-lisp . t) (python . t) (shell . t) (perl . t)
     (C . t) (java . t) (js . t) (css . t) (plantuml . t)))
  :config
  (make-directory my/org-runtime-directory t)
  (ora-advice-add 'org-agenda :before #'my/org-ensure-directories)
  (ora-advice-add 'org-capture :before #'my/org-ensure-directories)
  (which-key-add-keymap-based-replacements
    org-mode-map
    "C-c C-x" "Org extras"
    "C-c \"" "Table plots"
    "C-c C-v" "Babel")
  (add-to-list 'org-structure-template-alist '("n" . "note"))
  (add-to-list 'org-tags-exclude-from-inheritance "crypt")
  (dolist (abbrev `(("github" . "https://github.com/%s")
                    ("youtube" . "https://youtube.com/watch?v=%s")
                    ("google" . "https://google.com/search?q=%s")
                    ("wikipedia" . "https://en.wikipedia.org/wiki/%s")
                    ("emacsdir" . ,(expand-file-name "%s" user-emacs-directory))))
    (add-to-list 'org-link-abbrev-alist abbrev)))

(use-package org-agenda
  :straight nil
  :general
  (:keymaps 'org-agenda-mode-map
   "t" '("change TODO state" . org-agenda-todo)
   "r" '("refile" . org-agenda-refile)
   "q" '("set tags" . org-agenda-set-tags)
   "d" '("set deadline" . org-agenda-deadline)
   "s" '("schedule" . org-agenda-schedule)
   "C-SPC" '("preview entry" . org-agenda-show-and-scroll-up))
  :custom
  (org-agenda-files (list my/org-directory))
  (org-agenda-window-setup 'current-window)
  (org-agenda-skip-unavailable-files t)
  (org-agenda-span 10)
  (org-agenda-start-on-weekday nil)
  (org-agenda-start-day "-3d")
  (org-agenda-inhibit-startup t))

(use-package org-capture
  :straight nil
  :custom
  (org-capture-templates
   `(("i" "Inbox" entry (file ,(my/org-file "inbox.org"))
      "* %?\n%U\n%a\n")
     ("t" "Todo" entry (file ,(my/org-file "gtd.org"))
      "* TODO %?\n%U\n%a\n")
     ("n" "Note" entry (file ,(my/org-file "notes.org"))
      "* %^{Title} %? :NOTE:\n%U\n%a\n")
     ("j" "Journal" entry
      (file+olp+datetree ,(my/org-file "journal.org"))
      "* %^{Title} %?\n%U\n"))))

(use-package org-src
  :straight nil
  :custom
  (org-src-preserve-indentation t)
  (org-src-lang-modes
   '(("el" . emacs-lisp) ("elisp" . emacs-lisp)
     ("sh" . sh) ("bash" . sh) ("html" . web) ("css" . css)
     ("javascript" . js) ("js" . js) ("typescript" . typescript-ts)
     ("java" . java) ("go" . go-ts) ("rust" . rust-ts)
     ("python" . python) ("c" . c) ("c++" . c++) ("cpp" . c++))))

(use-package org-clock
  :straight nil
  :commands (org-clock-in org-clock-out org-clock-goto org-clock-cancel)
  :custom
  (org-clock-persist-file (expand-file-name "clock-persist.el" my/org-runtime-directory))
  (org-clock-persist 'history)
  (org-clock-in-resume t)
  (org-clock-out-remove-zero-time-clocks t)
  :config
  (org-clock-persistence-insinuate))

(use-package org-crypt
  :straight nil
  :config
  (org-crypt-use-before-save-magic)
  (add-to-list 'org-tags-exclude-from-inheritance "crypt"))

(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-table t)
  (org-modern-star 'replace)
  (org-modern-replace-stars "◉⦿⊚⊙∘"))

(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    my-leader-map
    "n" "Notes / Org"
    "n k" "Org clock"
    "n s" "Org subtree"))

(with-eval-after-load 'general
  (my-leader-def
    "n a" '("agenda" . org-agenda)
    "n b" '("switch Org buffer" . org-switchb)
    "n c" '("capture" . org-capture)
    "n e" '("export" . org-export-dispatch)
    "n f" '("open inbox" . my/org-open-inbox)
    "n l" '("store link" . org-store-link)
    "n t" '("TODO list" . org-todo-list)
    "n k i" '("clock in" . org-clock-in)
    "n k o" '("clock out" . org-clock-out)
    "n k g" '("go to active clock" . org-clock-goto)
    "n k c" '("cancel clock" . org-clock-cancel)
    "n s k" '("cut subtree" . org-cut-subtree)
    "n s a" '("archive subtree" . org-archive-subtree-default)))

(provide 'init-org)

;; ==========================================================================
;; 使用说明（全部为注释，不参与加载）
;; ==========================================================================
;; 1. Org 文件默认保存在 ~/org/。可执行：
;;      M-x customize-group RET my-org
;;    修改 `my/org-directory' 后重启 Emacs。
;;
;; 2. 日常工作流：
;;    - C-z n f       打开 inbox.org，直接记录内容。
;;    - C-z n c       快速捕获；i=收件箱，t=任务，n=笔记，j=日志。
;;    - C-z n a       打开 Agenda；选择 t 查看全部 TODO。
;;    - C-z n t       直接显示 TODO 列表。
;;    - C-z n l       在当前页面保存链接，Capture 时可用 %a 引用。
;;
;; 3. Org 文件内常用快捷键：
;;    - TAB / S-TAB   折叠当前标题 / 循环整个文件显示状态。
;;    - C-RET         新建同级标题；C-S-RET 新建 TODO 标题。
;;    - C-M-RET       新建子标题。
;;    - C-c C-t       切换 TODO 状态。
;;    - C-c C-s       设置计划时间；C-c C-d 设置截止时间。
;;    - C-c C-q       设置标签；C-c . 插入活动时间戳。
;;    - C-c C-l       插入链接；C-c C-o 打开光标处链接。
;;    - C-c C-,       插入 src/quote/example 等结构模板。
;;    - C-c '         在独立缓冲区编辑代码块。
;;    - C-c C-c       执行代码块；出于安全考虑会先确认。
;;
;; 4. Agenda 内常用快捷键：
;;    - t             修改 TODO 状态；s 设置计划；d 设置截止日期。
;;    - r             移动条目；q 设置标签；C-SPC 预览条目。
;;    - g             刷新 Agenda；RET 跳转到原始 Org 条目。
;;
;; 5. 计时与归档：
;;    - C-z n k i/o   开始/结束计时；C-z n k g 跳到当前计时任务。
;;    - C-z n s a     归档当前子树；C-z n s k 剪切当前子树。
;;
;; 6. Babel 示例：
;;      #+begin_src python
;;      print("hello")
;;      #+end_src
;;    把光标放在代码块中按 C-c C-c 执行。
;; ==========================================================================
;;; init-org.el ends here
