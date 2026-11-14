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

(defun my/window-test-layout-names (&optional tree)
  "Return TREE's leaf buffer names while retaining its split nesting."
  (setq tree (or tree (car (window-tree))))
  (if (windowp tree)
      (buffer-name (window-buffer tree))
    (mapcar #'my/window-test-layout-names (cddr tree))))

(ert-deftest my/window-swap-group-right-moves-a-two-window-group-past-a-leaf ()
  "Swapping right moves the complete left vertical group past one window."
  (save-window-excursion
    (delete-other-windows)
    (switch-to-buffer (get-buffer-create " *window-test-A*"))
    (let ((right (split-window-right)))
      (with-selected-window right
        (switch-to-buffer (get-buffer-create " *window-test-C*")))
      (let ((bottom (split-window-below)))
        (with-selected-window bottom
          (switch-to-buffer (get-buffer-create " *window-test-B*")))
        (my/window-swap-group-right)
        (should (equal (my/window-test-layout-names)
                       '(" *window-test-C*"
                         (" *window-test-A*" " *window-test-B*"))))))))

(ert-deftest my/window-swap-group-down-exchanges-horizontal-subtrees ()
  "Swapping down exchanges complete upper and lower horizontal groups."
  (save-window-excursion
    (delete-other-windows)
    (switch-to-buffer (get-buffer-create " *window-test-A*"))
    (let ((bottom (split-window-below)))
      (with-selected-window bottom
        (switch-to-buffer (get-buffer-create " *window-test-C*")))
      (let ((top-right (split-window-right)))
        (with-selected-window top-right
          (switch-to-buffer (get-buffer-create " *window-test-B*")))
        (with-selected-window bottom
          (let ((bottom-right (split-window-right)))
            (with-selected-window bottom-right
              (switch-to-buffer (get-buffer-create " *window-test-D*")))))
        (select-window (get-buffer-window " *window-test-A*"))
        (my/window-swap-group-down)
        (should (equal (my/window-test-layout-names)
                       '((" *window-test-C*" " *window-test-D*")
                         (" *window-test-A*" " *window-test-B*"))))))))

(ert-deftest my/window-swap-group-offers-all-groups-in-a-direction ()
  "Directional group lookup keeps every sibling available to Ace Window."
  (should (equal (my/window--swap-target-indexes 0 3 'right) '(1 2)))
  (should (equal (my/window--swap-target-indexes 2 3 'left) '(0 1))))

(ert-deftest my/window-swap-group-uses-ace-selection-for-multiple-targets ()
  "Ace Window chooses which of several directional groups to exchange."
  (save-window-excursion
    (delete-other-windows)
    (switch-to-buffer (get-buffer-create " *window-test-A*"))
    (let ((middle (split-window-right))
          right)
      (with-selected-window middle
        (switch-to-buffer (get-buffer-create " *window-test-B*"))
        (setq right (split-window-right))
        (with-selected-window right
          (switch-to-buffer (get-buffer-create " *window-test-C*"))))
      (let ((tree (car (window-tree))))
        (cl-letf (((symbol-function 'aw-select)
                   (lambda (&rest _) right)))
          (should (= (my/window--select-group-target tree nil '(1 2)) 2)))))))

(ert-deftest my/window-menu-documents-layout-group-swap-keys ()
  "The window Hydra exposes the four directional group-swap commands."
  (let ((hint (get 'hydra-window-menu 'my/hydra-hint)))
    (dolist (text '("布局组交换"
                    "交换左侧布局组"
                    "交换下方布局组"
                    "交换上方布局组"
                    "交换右侧布局组"))
      (should (string-match-p (regexp-quote text) hint)))))

;;; init-window-tests.el ends here
