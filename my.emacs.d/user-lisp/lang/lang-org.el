;;; -*- lexical-binding: t -*-

;;; 中文导读：Org 工作流配置。Org 管理大纲/任务/链接，Agenda 汇总日程，Capture
;;; 快速记录，Clock 计时，Crypt 加密条目，Babel/org-src 编辑和执行代码块，
;;; org-modern 美化显示。Leader C-z n a/b/c 打开议程、切换 Org 缓冲区、捕获；
;;; Org 中 C-RET/C-S-RET/C-M-RET 插入标题/TODO/子标题，C-c C-t 改 TODO，
;;; C-c C-q 设标签，C-c C-d/C-s 设截止/计划，C-c ./! 插活动/非活动时间戳，
;;; C-c C-o 开链接，C-c @ 插引用；Leader C-z n e 导出，C-z n s k/a 剪切/归档
;;; 子树。Agenda 中 t/r/q/d/s 修改 TODO/归档/标签/截止/计划，C-SPC 预览条目。
(use-package ol
  :straight nil
  :config
  (org-link-set-parameters
   "file"
   :face
   (lambda (path)
     (if (or (if (eq system-type 'windows-nt)
                 (string-prefix-p "//" path))
             (file-remote-p path)
             (if (eq system-type 'windows-nt)
                 (string-prefix-p "\\\\" path))
             (file-exists-p path))
         'org-link
       '(warning org-link)))))

(use-package org
  :straight nil
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
   "C-c @" '("insert citation" . org-cite-insert)
   "C-c *" '("toggle heading" . org-ctrl-c-star)
   "C-c -" '("toggle list item" . org-ctrl-c-minus))
  :hook ((org-babel-after-execute org-mode) . org-redisplay-inline-images)
  :custom
  (org-persist-directory (concat nn-directory "org/persist/"))
  (org-id-locations-file (concat nn-directory "org/id-locations.el"))
  (org-publish-timestamp-directory (concat nn-directory "org/timestamps/"))
  (org-modules nil)
  (org-support-shift-select t)
  (org-auto-align-tags nil)
  (org-log-done 'time)
  (org-pretty-entities t)
  (org-ellipsis nn-fold-string)
  (org-enforce-todo-dependencies t)
  (org-tags-column 0)
  (org-confirm-babel-evaluate nil)
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
  (org-startup-folded nil)
  (org-use-sub-superscripts '{})
  (org-todo-keywords
   '((sequence
      "TODO(t)" "PROJ(p)" "LOOP(r)" "STRT(s)"
      "WAIT(w)" "HOLD(h)" "IDEA(i)"
      "|" "DONE(d)" "KILL(k)")
     (sequence
      "[ ](T)" "[-](S)" "[?](W)"
      "|" "[X](D)")
     (sequence
      "|" "OKAY(o)" "YES(y)" "NO(n)")))
  (org-babel-load-languages
   '((emacs-lisp . t) (python . t)
     (shell . t) (perl . t)
     (C . t) (java . t)
     (js . t) (css . t)
     (plantuml . t)))
  :config
  ;; Org 自带的多层快捷键也补充 keymap 局部名称，避免显示 +prefix。
  (which-key-add-keymap-based-replacements
    org-mode-map
    "C-c C-x" "Org extras"
    "C-c \"" "Table plots"
    "C-c C-v" "Babel")
  (add-to-list 'org-structure-template-alist '("n" . "note"))
  (add-to-list 'org-tags-exclude-from-inheritance "crypt")
  (add-to-list 'org-file-apps
               '("\\.\\(x?html?\\|pdf\\)\\'"  .
                 (lambda (file _link)
                   (centaur-browse-url-of-file (browse-url-file-url file)))))

  (dolist (abbrev '(("github"     . "https://github.com/%s")
                    ("youtube"    . "https://youtube.com/watch?v=%s")
                    ("google"     . "https://google.com/search?q=%s")
                    ("gimages"    . "https://google.com/images?q=%s")
                    ("gmap"       . "https://maps.google.com/maps?q=%s")
                    ("kagi"       . "https://kagi.com/search?q=%s")
                    ("duckduckgo" . "https://duckduckgo.com/?q=%s")
                    ("wikipedia"  . "https://en.wikipedia.org/wiki/%s")
                    ("wolfram"    . "https://wolframalpha.com/input/?i=%s")
                    ("emacsdir"   . ,(expand-file-name "%s" user))))
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
  (org-agenda-files '("~/agenda.org"))
  (org-agenda-window-setup 'current-window)
  (org-agenda-skip-unavailable-files t)
  (org-agenda-span 10)
  (org-agenda-start-on-weekday nil)
  (org-agenda-start-day "-3d")
  (org-agenda-inhibit-startup t))

(with-eval-after-load 'general
  (my-leader-def
    "n a" '("agenda" . org-agenda)
    "n b" '("switch Org buffer" . org-switchb)
    "n c" '("capture" . org-capture)
    "n e" '("export" . org-export-dispatch)
    "n t" '("TODO list" . org-todo-list)
    "n s k" '("cut subtree" . org-cut-subtree)
    "n s a" '("archive subtree" . org-archive-subtree-default)))

(use-package org-src
  :straight nil
  :custom
  (org-src-preserve-indentation t)
  (org-src-lang-modes
   '(("el" . emacs-lisp) ("elisp" . emacs-lisp)
     ("sh" . sh) ("bash" . sh) ("powershell" . powershell)
     ("bat" . bat) ("vbs" . js)
     ("html" . web) ("css" . css) ("scss" . scss)
     ("javascript" . js) ("js" . js) ("jsx" . js)
     ("typescript" . typescript-ts) ("ts" . typescript-ts) ("tsx" . tsx-ts)
     ("java" . java) ("go" . go-ts) ("rust" . rust-ts) ("python" . python)
     ("c" . c) ("c++" . c++) ("cpp" . c++) ("glsl" . c))))

(use-package org-capture
  :straight nil
  :custom
  (org-capture-templates
   `(("i" "Idea" entry (file ,(concat org-directory "/idea.org"))
      "*  %^{Title} %?\n%U\n%a\n")
     ("t" "Todo" entry (file ,(concat org-directory "/gtd.org"))
      "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
     ("n" "Note" entry (file ,(concat org-directory "/note.org"))
      "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
     ("j" "Journal" entry (file+olp+datetree
                           ,(concat org-directory "/journal.org"))
      "*  %^{Title} %?\n%U\n%a\n" :clock-in t :clock-resume t)
     ("b" "Book" entry (file+olp+datetree
                        ,(concat org-directory "/book.org"))
      "* Topic: %^{Description} %^g %? Added: %U"))))

(use-package org-entities
  :straight nil
  :custom
  (org-entities-user
   '(("flat"  "\\flat" nil "" "" "266D" "♭")
     ("sharp" "\\sharp" nil "" "" "266F" "♯"))))

(use-package org-clock
  :straight nil
  :commands org-clock-save
  :custom
  (org-clock-persist-file (concat nn-directory "org/clock-persist.el"))
  (org-clock-persist 'history)
  (org-clock-in-resume t)
  (org-clock-out-remove-zero-time-clocks t)
  :config
  (add-hook 'kill-emacs-hook #'org-clock-save)
  (dolist (cmd '(org-clock-in org-clock-out org-clock-goto org-clock-cancel))
    (advice-add cmd :before #'org-clock-load)))

(use-package org-crypt
  :straight nil
  :config (org-crypt-use-before-save-magic))

(use-package org-faces
  :straight nil
  :custom
  (org-priority-faces
   '((?A . error)
     (?B . warning)
     (?C . success)))
  (org-agenda-deadline-faces
   '((1.0 . error)
     (1.0 . org-warning)
     (0.5 . org-upcoming-deadline)
     (0.0 . org-upcoming-distant-deadline))))

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :custom
  (org-modern-table t)
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 1)
  (org-modern-star 'replace)
  (org-modern-replace-stars "◉⦿⊚⊙∘"))

(provide 'lang-org)
