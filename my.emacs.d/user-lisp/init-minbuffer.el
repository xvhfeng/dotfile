;;; -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------------------
;; 1. 基础模糊搜索与匹配样式 (Orderless + Savehist)
;; ----------------------------------------------------------------------------

  (use-package orderless
  :straight t
  :custom
  (orderless-matching-styles '(orderless-literal orderless-regexp))
  ;; Orderless 负责普通候选；basic 作为兼容性后备。
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  ;; 路径补全保留 Emacs 原生 partial-completion（例如 ~/p/s）。
  (completion-category-overrides '((file (styles basic partial-completion)))))

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
  (vertico-count 13)
  ;; 2) 循环滚动：光标移到最底下时，按 C-n 回到最顶部
  (vertico-cycle t)
  ;; 3) 根据候选数量调整 Minibuffer 高度
  (vertico-resize t)

  :general
  (:keymaps 'vertico-map
   "C-n" '("下一个候选项" . vertico-next)
   "C-p" '("上一个候选项" . vertico-previous)
   "TAB" '("插入候选项" . vertico-insert)
   "<tab>" '("插入候选项" . vertico-insert)
   "RET" '("进入或打开候选项" . vertico-directory-enter)
   "<return>" '("进入或打开候选项" . vertico-directory-enter)
   "DEL" '("删除路径字符" . vertico-directory-delete-char)
   "M-DEL" '("删除路径组件" . vertico-directory-delete-word)
   "/" '("进入选中目录" . my/vertico-insert-slash))

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
      (insert "/"))))


;; ----------------------------------------------------------------------------
;; 4. 解决“0 个字母按 TAB 触发补全”与路径预填问题
;; ----------------------------------------------------------------------------
;; 在 C-x C-f 时，默认把光标放在路径最后，即使 0 个字母，vertico 也会自动竖向列出当前目录下所有文件/文件夹
(setq insert-default-directory t)
(setq read-file-name-completion-ignore-case t) ; 忽略文件名大小写

(provide 'init-minbuffer)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 当前启动列表会加载本模块：Vertico 显示竖向候选，Orderless 负责无序模糊匹配。
;; - Minibuffer 中 `C-n/C-p' 选择候选，`TAB' 插入候选，`RET' 进入或确认。
;; - 文件补全时 `/` 进入选中的目录，`DEL' 删除字符，`M-DEL' 删除一段路径。
;; - Marginalia 在候选右侧显示说明、文件大小和时间；Savehist 跨重启保留输入历史。
;; - 多个搜索词以空格分隔即可分别匹配；文件名补全默认忽略大小写。
