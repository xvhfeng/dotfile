;;; init-window-tests.el --- Tests for window navigation -*- lexical-binding: t; -*-

(require 'ert)
(add-to-list 'load-path (file-name-directory load-file-name))

;; Load the navigation helpers without loading third-party packages.
(defmacro use-package (_name &rest args)
  (when (eq _name 'hydra)
    `(progn ,(plist-get args :config))))

(defmacro defhydra (name &rest _heads)
  `(progn
     (put ',name 'my/hydra-hint ',(nth 1 _heads))
     (defun ,(intern (concat (symbol-name name) "/body")) ()
       (interactive))))
(load (expand-file-name "init-window.el" (file-name-directory load-file-name))
      nil nil t)

(defmacro my/window-test-with-treemacs-layout (&rest body)
  "Run BODY with a left side window and two vertically stacked editor windows."
  (declare (indent 0) (debug t))
  `(save-window-excursion
     (delete-other-windows)
     (switch-to-buffer (get-buffer-create " *window-test-top*"))
     (let ((bottom (split-window-below)))
       (with-selected-window bottom
         (switch-to-buffer (get-buffer-create " *window-test-bottom*")))
       (let ((tree (display-buffer-in-side-window
                    (get-buffer-create " *window-test-treemacs*")
                    '((side . left)))))
         ,@body))))

(ert-deftest my/window-select-wrap-leaves-treemacs-side-window-vertically ()
  "Vertical navigation from a full-height side window enters the editor area."
  (my/window-test-with-treemacs-layout
    (select-window tree)
    (my/window-select-down)
    (should (eq (selected-window) bottom))
    (select-window tree)
    (my/window-select-up)
    (should (eq (selected-window)
                (get-buffer-window " *window-test-top*")))))

(ert-deftest my/window-menu-is-a-hydra ()
  "C-w starts the persistent window Hydra rather than a Transient prefix."
  (should (eq (key-binding (kbd "C-w")) #'hydra-window-menu/body))
  (should (fboundp 'hydra-window-menu/body))
  (should-not (fboundp 'my/window-menu))
  (should-not (fboundp 'my/window-menu-open)))

(ert-deftest my/window-menu-hint-keeps-detailed-three-column-descriptions ()
  "The window Hydra presents the former Transient groups and descriptions."
  (let ((hint (get 'hydra-window-menu 'my/hydra-hint)))
    (dolist (text '("选择与移动"
                    "空间分割"
                    "布局与尺寸"
                    "向左循环切换窗口"
                    "Ace Window：选择窗口"
                    "左侧分割，留在原窗口"
                    "右侧分割并切换"
                    "与目标窗口交换"
                    "关闭当前窗口"
                    "关闭目标窗口"
                    "关闭其它窗口"
                    "Zoom 当前窗口/恢复布局"
                    "均分编辑窗口"
                    "调整窗口尺寸"
                    "退出菜单"))
      (should (string-match-p (regexp-quote text) hint)))))

;;; init-window-tests.el ends here
