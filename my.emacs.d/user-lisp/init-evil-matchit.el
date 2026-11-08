;;; init-evil-matchit.el --- Global Evil Matchit integration -*- lexical-binding: t; -*-

;; Evil Matchit 扩展成对标签、括号与代码块之间的跳转，并提供选中、删除及
;; 高亮当前匹配项的命令。此配置不依赖 Evil，跳转使用原生入口。

(defface my/evilmi-highlight-face
  '((t :inherit region))
  "Face used to temporarily highlight the Evil Matchit item range.")

(defvar-local my/evilmi-highlight-overlay nil
  "Overlay used by `evilmi-highlight-items' in the current buffer.")

(defun evilmi-highlight-items (&optional num)
  "Temporarily highlight NUM matching Evil Matchit items and their contents.

Evil Matchit provides the range computation used by its select/delete
commands, but no public highlight command.  This compatibility command keeps
the requested `evilmi-*' interface while leaving point and the region intact."
  (interactive "p")
  (unless (fboundp 'evilmi--region-to-select-or-delete)
    (user-error "Evil Matchit 尚未加载"))
  (when (overlayp my/evilmi-highlight-overlay)
    (delete-overlay my/evilmi-highlight-overlay))
  (if-let ((range (evilmi--region-to-select-or-delete (or num 1))))
      (let ((overlay (make-overlay (car range) (cadr range))))
        (setq my/evilmi-highlight-overlay overlay)
        (overlay-put overlay 'face 'my/evilmi-highlight-face)
        (run-at-time
         1.2 nil
         (lambda (candidate)
           (when (overlayp candidate)
             (delete-overlay candidate)))
         overlay))
    (user-error "当前位置没有可匹配的文本项")))

(use-package evil-matchit
  :straight (:host github :repo "redguardtoo/evil-matchit")
  :demand t
  :config
  (keymap-global-set "M-5" #'evilmi-jump-items-native)
  (with-eval-after-load 'general
    (general-define-key "M-5" '("匹配跳转〔Evil Matchit〕" . evilmi-jump-items-native))))

(provide 'init-evil-matchit)
;;; init-evil-matchit.el ends here
