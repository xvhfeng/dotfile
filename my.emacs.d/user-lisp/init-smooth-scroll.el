;;; init-smooth-scroll.el --- Built-in smooth keyboard scrolling -*- lexical-binding: t; -*-

(require 'pixel-scroll)

;; 键盘翻页使用内置插值；鼠标也由同一模式处理，不依赖外部滚动插件。
(setq pixel-scroll-precision-interpolate-page t
      pixel-scroll-precision-interpolate-mice t
      pixel-scroll-precision-interpolation-total-time 0.15
      pixel-scroll-precision-interpolation-between-scroll 0.001)
(pixel-scroll-precision-mode 1)

(defun my/pixel-scroll-with-preserved-screen-row (scroll-function)
  "Run SCROLL-FUNCTION and restore point to its prior visual screen row."
  (let ((screen-row (count-screen-lines (window-start) (point) nil nil)))
    (funcall scroll-function)
    (goto-char (window-start))
    (vertical-motion screen-row)))

(defun my/pixel-scroll-half-screen-forward ()
  "平滑向前移动半屏，替代 C-0 的旧瞬间滚动入口。"
  (interactive)
  (my/pixel-scroll-with-preserved-screen-row
   (lambda ()
     (pixel-scroll-precision-interpolate
      (- (/ (window-text-height nil t) 2)) nil 1))))

(defun my/pixel-scroll-half-screen-backward ()
  "平滑向后移动半屏，替代 C-9 的旧瞬间滚动入口。"
  (interactive)
  (my/pixel-scroll-with-preserved-screen-row
   (lambda ()
     (pixel-scroll-precision-interpolate
      (/ (window-text-height nil t) 2) nil 1))))

(defun my/pixel-scroll-page-distance-with-context ()
  "Return one page of pixels while preserving context lines."
  (max 1
       (- (window-text-height nil t)
          (* (or next-screen-context-lines 0)
             (line-pixel-height)))))

(defun my/pixel-scroll-page-forward-with-context ()
  "平滑向前翻页，并保留窗口底部的上下文行。"
  (interactive)
  (my/pixel-scroll-with-preserved-screen-row
   (lambda ()
     (pixel-scroll-precision-interpolate
      (- (my/pixel-scroll-page-distance-with-context)) nil 1))))

(defun my/pixel-scroll-page-backward-with-context ()
  "平滑向后翻页，并保留窗口顶部的上下文行。"
  (interactive)
  (my/pixel-scroll-with-preserved-screen-row
   (lambda ()
     (pixel-scroll-precision-interpolate
      (my/pixel-scroll-page-distance-with-context) nil 1))))

;; 保留原 my-scroll-half-screen-up/down 定义不变，只替换用户指定按键。
(keymap-global-set "C-0" #'my/pixel-scroll-half-screen-forward)
(keymap-global-set "C-9" #'my/pixel-scroll-half-screen-backward)
(keymap-global-set "C-8" #'my/pixel-scroll-page-forward-with-context)
(keymap-global-set "C-7" #'my/pixel-scroll-page-backward-with-context)
;; C-v / M-v 保留 Emacs 的原生整屏翻页语义。
(keymap-global-set "C-v" #'scroll-up-command)
(keymap-global-set "M-v" #'scroll-down-command)

(provide 'init-smooth-scroll)
;;; init-smooth-scroll.el ends here
