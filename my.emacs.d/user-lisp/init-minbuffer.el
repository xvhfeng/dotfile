
;;; -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------------------
;; 1. 基础模糊搜索与匹配样式 (Orderless + Savehist)
;; ----------------------------------------------------------------------------

  (use-package orderless
  :straight t
  :custom
  (orderless-matching-styles '(orderless-literal orderless-regexp))
  ;; 优先使用 orderless 和 substring，彻底取消必须从开头/前缀匹配的限制
  (completion-styles '(orderless substring flex))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles orderless substring)))))

;; 记住 Minibuffer 输入历史，把最近常用的文件排在最前面
(use-package savehist
  :init
  (savehist-mode 1))


;; ----------------------------------------------------------------------------
;; 2. 丰富 Minibuffer 提示信息 (Marginalia)
;; ----------------------------------------------------------------------------
;; 在补全文件/文件夹时，在右侧竖向列出文件权限、大小、修改时间等信息
(use-package marginalia
  :straight t
  :demand t
  :init
  (marginalia-mode 1))


;; ----------------------------------------------------------------------------
;; 3. Vertico 竖向 Minibuffer 核心配置
;; ----------------------------------------------------------------------------
(use-package vertico
  :straight t
  :demand t
  :init
  ;; 开启全局 Vertico 竖向补全模式
  (vertico-mode 1)

  :custom
  ;; 1) 竖向最多显示的候选行数
  (vertico-count 12)
  ;; 2) 循环滚动：光标移到最底下时，按 C-n 回到最顶部
  (vertico-cycle t)

  :bind (:map vertico-map
              ;; --- [要求 1] 使用 C-n / C-p 进行上下移动 ---
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous)

              ;; --- [要求 2] 输入 TAB 选择当前高亮的文件/文件夹 ---
              ;; 注：按 TAB 会将高亮项补全/确认为当前输入，若是文件则打开，若是目录则进入
              ("TAB"   . vertico-insert)
              ("<tab>" . vertico-insert)

              ;; --- [要求 3] 按 回车 (RET) 打开选中的文件或进入选中的文件夹 ---
              ("RET"   . vertico-directory-enter)
              ("<return>" . vertico-directory-enter)

              ;; --- [辅助] 删除路径增强：按 Backspace 快速退回上一级目录 ---
              ("DEL"   . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))

  :config
  ;; --- [要求 4] 输入 "/" 智能进入选中的文件夹 ---
  ;; 当你通过 C-n 选中某个文件夹，直接敲下 "/" 键，它会自动把文件夹名称填入并跳转进去
  (add-hook 'rdict-mode-hook #'vertico-directory-tidy)
  
  ;; 针对文件/路径补全，启用自动补全 `/` 的动作
  (defun my/vertico-insert-slash ()
    "如果当前选中的是目录，按 '/' 会自动补全目录名并进入下一级；否则正常输入 '/'"
    (interactive)
    (if (and (eq (vertico--metadata-get 'category) 'file)
             (>= vertico--index 0))
        (progn
          (vertico-insert)
          (unless (string-suffix-p "/" (minibuffer-contents))
            (insert "/")))
      (insert "/")))

  (define-key vertico-map (kbd "/") #'my/vertico-insert-slash))


;; ----------------------------------------------------------------------------
;; 4. 解决“0 个字母按 TAB 触发补全”与路径预填问题
;; ----------------------------------------------------------------------------
;; 在 C-x C-f 时，默认把光标放在路径最后，即使 0 个字母，vertico 也会自动竖向列出当前目录下所有文件/文件夹
(setq insert-default-directory t)
(setq read-file-name-completion-ignore-case t) ; 忽略文件名大小写

(provide 'init-minbuffer)