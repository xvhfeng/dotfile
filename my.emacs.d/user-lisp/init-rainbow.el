;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; Rainbow Delimiters: 彩虹括号 (按嵌套层级高亮括号)
;; ============================================================================
(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

;; ============================================================================
;; Rainbow Mode: 颜色代码高亮预览 (如 #ffffff, red, rgb(...))
;; ============================================================================
(use-package rainbow-mode
  :straight t
  ;; 建议在 Web 前端开发模式、Emacs Lisp 和 CSS 中自动启用
  :hook (css-mode html-mode emacs-lisp-mode web-mode))


(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  ;; 自定义极浅/极深主题下的第 1 到 4 层括号颜色 (根据喜好微调)
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#7fbbb3"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#d3c6aa"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#e67e80"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#a7c080"))))))

(provide 'init-rainbow)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 所有 prog-mode 自动按嵌套层级给括号着色，便于辨认复杂表达式的配对关系。
;; - CSS、HTML、Web 和 Emacs Lisp 中的 #RRGGBB、颜色名等会直接显示对应背景色。
;; - 临时关闭可运行 `M-x rainbow-delimiters-mode' 或 `M-x rainbow-mode'。
;; - 本模块没有快捷键；颜色由末尾的 face 设置控制，可按主题对比度自行调整。
