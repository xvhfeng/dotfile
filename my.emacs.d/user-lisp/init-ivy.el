;;; init-ivy.el --- Safe Ivy / Counsel / Swiper Setup -*- lexical-binding: t; -*-

(use-package ivy
  :straight t
  :init
  (ivy-mode 1)
  :general
  (:keymaps 'ivy-minibuffer-map
   "C-o" nil)
  :config
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-initial-inputs-alist nil
        enable-recursive-minibuffers t))

(use-package swiper
  :straight t
  :after ivy)

(use-package counsel
  :straight t
  :after (ivy general)
  :init
  (counsel-mode 1))

(use-package ivy-rich
  :straight t
  :after counsel
  :init
  (ivy-rich-mode 1))

;; --- 无缝对接你现有的 General.el / C-z 前缀 ---
(with-eval-after-load 'general
  ;; 1. 替换原生快捷键 (不影响 C-o / C-S-o 和 C-z)
  (general-define-key
    "C-s" '(swiper :which-key "search buffer")
    "M-x" '(counsel-m-x :which-key "execute command")
    "C-x b" '(counsel-switch-buffer :which-key "switch buffer"))

  ;; 2. 挂载到你的 C-z 前缀定义器 (my-cz-def) 下
  (my-leader-def
    "s"   '(:ignore t :which-key "search/ivy")
    "s s" '(swiper :which-key "swiper search line")
    "s r" '(counsel-rg :which-key "ripgrep project")
    "s i" '(counsel-imenu :which-key "imenu symbols")
    
    "f"   '(:ignore t :which-key "files")
    "f f" '(counsel-find-file :which-key "find file")
    "f r" '(counsel-recentf :which-key "recent files")
    
    "b"   '(:ignore t :which-key "buffers")
    "b b" '(counsel-switch-buffer :which-key "switch buffer")))

(provide 'init-ivy)
;;; init-ivy.el ends here
