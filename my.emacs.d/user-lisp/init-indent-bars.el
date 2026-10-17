;;; init-indent-bars.el --- 点状缩进层级引导线 -*- lexical-binding: t; -*-

;; `indent-bars' 使用字体渲染的缩进引导线；pattern 中的非空字符为实心部分，
;; 单个点形成简洁的虚线效果。它不改写文本，也不绑定任何按键。
(use-package indent-bars
  :straight (:host github :repo "jdtsmith/indent-bars")
  :hook ((prog-mode html-mode html-ts-mode mhtml-mode mhtml-ts-mode
                    web-mode yaml-mode yaml-ts-mode) . indent-bars-mode)
  :custom
  (indent-bars-pattern ".")
  (indent-bars-width-frac 0.12)
  (indent-bars-pad-frac 0.12)
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-lists 'skip))

(provide 'init-indent-bars)
;;; init-indent-bars.el ends here
