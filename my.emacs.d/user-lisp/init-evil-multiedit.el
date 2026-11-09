;;; init-evil-multiedit.el --- Multiedit Hydra without Evil mode -*- lexical-binding: t; -*-

(use-package hydra :straight t :demand t)

;; Evil 是 evil-multiedit 的依赖；只加载库，不启用 evil-mode。
;; 使用 iedit 的普通 Emacs 编辑方式，不安装 Evil 状态专用按键。
(use-package evil-multiedit
  :straight (:host github :repo "hlissner/evil-multiedit")
  :demand t
  :init
  (setq evil-multiedit-dwim-motion-keys nil))

(defun my/evil-multiedit-match-all ()
  "Edit every match of the active Emacs region or the symbol at point."
  (interactive)
  (if (use-region-p)
      (let ((regexp (regexp-quote
                     (buffer-substring-no-properties
                      (region-beginning) (region-end)))))
        (deactivate-mark)
        (evil-multiedit-ex-match (point-min) (point-max) nil regexp))
    (evil-multiedit-match-all)))

(defun my/evil-multiedit-toggle-current ()
  "Toggle the current edit occurrence when a multiedit session is active."
  (interactive)
  (unless (and (bound-and-true-p iedit-mode)
               (iedit-current-occurrence-string))
    (user-error "当前位置没有多处编辑匹配项"))
  (evil-multiedit-toggle-or-restrict-region))

(defun my/evil-multiedit-toggle-marker-here ()
  "Toggle a marker at point and keep Iedit's edit synchronization active."
  (interactive)
  (evil-multiedit-toggle-marker-here)
  (cond
   ((and iedit-occurrences-overlays (not iedit-mode))
    (setq iedit-mode t)
    (iedit-lib-start #'iedit-done)
    (run-hooks 'iedit-mode-hook))
   ((and iedit-mode (null iedit-occurrences-overlays))
    (evil-multiedit-abort))))

(defhydra my/evil-multiedit-workbench (:hint nil :color pink :foreign-keys warn)
  "
匹配: _n_ 下一词  _p_ 上一词  _h_ 下一符号  _l_ 上一符号  _a_ 全部匹配
编辑: _m_ 添加光标  _s_ 选中/放弃匹配  _j_ 跳到下一个  _k_ 跳到上一个
会话: _r_ 恢复上次  _q_ 结束多处编辑
菜单: _C-,_ / ESC / _C-g_"
  ("n" evil-multiedit-match-and-next)
  ("p" evil-multiedit-match-and-prev)
  ("h" evil-multiedit-match-symbol-and-next)
  ("l" evil-multiedit-match-symbol-and-prev)
  ("a" my/evil-multiedit-match-all)
  ("m" my/evil-multiedit-toggle-marker-here)
  ("s" my/evil-multiedit-toggle-current)
  ("j" evil-multiedit-next)
  ("k" evil-multiedit-prev)
  ("r" evil-multiedit-restore)
  ("q" evil-multiedit-abort :exit t)
  ("C-," nil :exit t)
  ("<escape>" nil :exit t)
  ("C-g" nil :exit t))

(keymap-global-set "C-," #'my/evil-multiedit-workbench/body)

(with-eval-after-load 'general
  (general-define-key "C-," '("多处编辑工作台" . my/evil-multiedit-workbench/body)))

(provide 'init-evil-multiedit)
;;; init-evil-multiedit.el ends here
