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

;; --- 无缝对接你现有的 General.el / C-c 前缀 ---
(with-eval-after-load 'general
  ;; 1. 替换原生快捷键 (不影响 C-o / C-S-o 和 C-c 分类)
  (general-define-key
    "C-s" '("search buffer" . swiper)
    "M-x" '("execute command" . counsel-m-x)
    "C-x b" '("switch buffer" . counsel-switch-buffer))

  ;; 2. 挂载到 C-c 前缀定义器 (my-leader-def) 下
  (my-leader-def
    "s s" '("swiper search line" . swiper)
    "s r" '("ripgrep project" . counsel-rg)
    "s i" '("imenu symbols" . counsel-imenu)
    
    "f f" '("find file" . counsel-find-file)
    "f r" '("recent files" . counsel-recentf)
    
    "b b" '("switch buffer" . counsel-switch-buffer)))

(provide 'init-ivy)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本模块当前未加入 `my/init-modules'，仅作为 Ivy/Counsel/Swiper 备选补全方案保留。
;; - 启用后 `C-s' 搜索当前 Buffer，`M-x' 使用 Counsel，`C-x b' 切换 Buffer。
;; - Leader 下 `C-c s s/r/i' 搜索行/项目/符号，`C-c f f/r' 文件/最近文件，`C-c b b' Buffer。
;; - Ivy 与当前 Vertico/Consult 体系会争用全局键；若要启用，应先停用对应现代补全模块。
;;; init-ivy.el ends here
