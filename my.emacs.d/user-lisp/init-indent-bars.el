;;; init-indent-bars.el --- 点状缩进层级引导线 -*- lexical-binding: t; -*-

;; 强制使用普通字符 `|'，避免图形 stipple 在深色背景中显示为厚重方块。
;; 它不改写文本，也不绑定任何按键。
(use-package indent-bars
  :straight (:host github :repo "jdtsmith/indent-bars")
  :hook ((prog-mode html-mode html-ts-mode mhtml-mode mhtml-ts-mode
                    web-mode yaml-mode yaml-ts-mode) . indent-bars-mode)
  :custom
  (indent-bars-prefer-character t)
  (indent-bars-no-stipple-char ?|)
  (indent-bars-no-stipple-char-font-weight 'normal)
  ;; 与 Tokyo Night Moon 背景协调的低对比蓝灰，不抢占代码文本注意力。
  (indent-bars-color '("#646a82" :blend 1))
  (indent-bars-color-by-depth nil)
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-lists 'skip))

(provide 'init-indent-bars)
;;; init-indent-bars.el ends here
