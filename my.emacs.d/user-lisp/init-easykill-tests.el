;;; init-easykill-tests.el --- Tests for Easy Kill menu -*- lexical-binding: t; -*-

(require 'ert)
(add-to-list 'load-path (file-name-directory load-file-name))

(defmacro use-package (name &rest args)
  (when (eq name 'hydra)
    `(progn ,(plist-get args :config))))

(defmacro defhydra (name &rest heads)
  `(progn
     (put ',name 'my/hydra-hint ',(nth 1 heads))
     (put ',name 'my/hydra-heads ',heads)
     (defun ,(intern (concat (symbol-name name) "/body")) ()
       (interactive))))

(load (expand-file-name "init-easykill.el" (file-name-directory load-file-name))
      nil nil t)

(ert-deftest my/easy-kill-menu-is-a-hydra-with-native-duplication ()
  "M-3 opens the Easy Kill Hydra with native before/after duplication."
  (let ((heads (get 'hydra-easy-kill-menu 'my/hydra-heads)))
    (should (eq (key-binding (kbd "M-3")) #'hydra-easy-kill-menu/body))
    (should (member '("]" easy-dup-after) heads))
    (should (member '("[" easy-dup-before) heads))
    (should (member '("u" my/easy-kill-copy-lines-up :exit t) heads))
    (should (member '("n" my/easy-kill-copy-lines-down :exit t) heads))
    (should (member '("v" my/easy-kill-kill-lines-up :exit t) heads))
    (should (member '("x" my/easy-kill-kill-lines-down :exit t) heads))
    (should (member '("q" my/easy-kill-cancel :exit t) heads))
    (should (member '("<escape>" my/easy-kill-cancel :exit t) heads))))

(ert-deftest my/easy-kill-menu-hint-keeps-detailed-transient-descriptions ()
  "The Hydra presents the former three groups with detailed descriptions."
  (let ((hint (get 'hydra-easy-kill-menu 'my/hydra-hint)))
    (dolist (text '("开始操作"
                    "行操作"
                    "选择对象"
                    "调整与完成"
                    "开始 Easy Mark"
                    "复制当前对象到下方"
                    "复制当前对象到上方"
                    "复制到 kill-ring 并退出"
                    "剪切候选并退出"
                    "显示完整键位帮助"
                    "退出菜单"))
      (should (string-match-p (regexp-quote text) hint)))))

(ert-deftest my/easy-kill-line-operations-copy-and-kill-whole-lines ()
  "M-3 must provide directional whole-line copy and kill operations."
  (dolist (command '(my/easy-kill-copy-lines-up
                     my/easy-kill-copy-lines-down
                     my/easy-kill-kill-lines-up
                     my/easy-kill-kill-lines-down))
    (should (fboundp command)))
  (let ((kill-ring nil))
    (with-temp-buffer
      (insert "one\ntwo\nthree\n")
      (goto-char (+ (point-min) 5))
      (let ((origin (point)))
        (my/easy-kill-copy-lines-up 2)
        (should (equal (current-kill 0 t) "one\ntwo\n"))
        (should (= (point) origin)))
      (my/easy-kill-copy-lines-down 2)
      (should (equal (current-kill 0 t) "two\nthree\n")))
    (with-temp-buffer
      (insert "one\ntwo\nthree\n")
      (goto-char (+ (point-min) 5))
      (my/easy-kill-kill-lines-up 2)
      (should (equal (buffer-string) "three\n"))
      (should (= (current-column) 1)))
    (with-temp-buffer
      (insert "one\ntwo\nthree\n")
      (goto-char (+ (point-min) 5))
      (my/easy-kill-kill-lines-down 2)
      (should (equal (buffer-string) "one\n"))
      (should (= (current-column) 1)))))

;;; init-easykill-tests.el ends here
