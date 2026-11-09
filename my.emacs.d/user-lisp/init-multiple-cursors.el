;;; init-multiple-cursors.el --- Multiple Cursors Hydra workbench -*- lexical-binding: t; -*-

(use-package multiple-cursors :straight t :demand t)
(use-package hydra :straight t :demand t)

(defun mc/unmark-current-like-this ()
  "Unmark the current cursor, keeping the nearest other cursor active."
  (interactive)
  (let ((cursor (car (sort (mc/all-fake-cursors)
                           (lambda (a b)
                             (< (abs (- (marker-position (overlay-get a 'point)) (point)))
                                (abs (- (marker-position (overlay-get b 'point)) (point)))))))))
    (unless cursor
      (user-error "No other cursor to keep"))
    (mc/pop-state-from-overlay cursor)
    (mc/maybe-multiple-cursors-mode)))


(defhydra my/multiple-cursors-workbench (:hint nil :color pink :foreign-keys warn)
  "
常用: _n_ 下一个  _w_ 匹配单词  _s_ 匹配符号  _m_ 完整单词  _y_ 完整符号
      _N_ 上一个  _W_ 上词  _S_ 上符号  _M_ 上完整词  _Y_ 上完整符号  _k_ 取消当前
批量: _a a_ 全部  _a d_ 智能全部  _a w_ 全词  _a s_ 全符号  _a r_ 区域  _a f_ 函数
编辑: _e l_ 按行  _e b_ 行首  _e e_ 行尾  _i n_ 数字  _i l_ 字母
整理: _o s_ 排序  _o r_ 反转  _o v_ 垂直对齐  _o w_ 空格对齐
退出: _C-,_ / ESC / _C-g_"
  ("n" mc/mark-next-like-this)
  ("w" mc/mark-next-like-this-word)
  ("s" mc/mark-next-like-this-symbol)
  ("m" mc/mark-next-word-like-this)
  ("y" mc/mark-next-symbol-like-this)
  ("N" mc/mark-previous-like-this)
  ("W" mc/mark-previous-like-this-word)
  ("S" mc/mark-previous-like-this-symbol)
  ("M" mc/mark-previous-word-like-this)
  ("Y" mc/mark-previous-symbol-like-this)
  ("k" mc/unmark-current-like-this)
  ("a a" mc/mark-all-like-this)
  ("a d" mc/mark-all-dwim)
  ("a w" mc/mark-all-words-like-this)
  ("a s" mc/mark-all-symbols-like-this)
  ("a r" mc/mark-all-in-region)
  ("a f" mc/mark-all-like-this-in-defun)
  ("a W" mc/mark-all-words-like-this-in-defun)
  ("a S" mc/mark-all-symbols-like-this-in-defun)
  ("x e" mc/mark-more-like-this-extended)
  ("x c" mc/add-cursor-on-click)
  ("x p" mc/mark-pop)
  ("u n" mc/unmark-next-like-this)
  ("u p" mc/unmark-previous-like-this)
  ("q n" mc/skip-to-next-like-this)
  ("q p" mc/skip-to-previous-like-this)
  ("e l" mc/edit-lines)
  ("e b" mc/edit-beginnings-of-lines)
  ("e e" mc/edit-ends-of-lines)
  ("i n" mc/insert-numbers)
  ("i l" mc/insert-letters)
  ("o s" mc/sort-regions)
  ("o r" mc/reverse-regions)
  ("o v" mc/vertical-align)
  ("o w" mc/vertical-align-with-space)
  ("t t" mc/mark-sgml-tag-pair)
  ("r c" set-rectangular-region-anchor)
  ("C-," nil :exit t)
  ("<escape>" nil :exit t)
  ("C-g" nil :exit t))

(defun my/multiple-cursors-register-hydra-commands ()
  "Tell Multiple Cursors to run generated Hydra wrapper commands only once."
  (mapatoms
   (lambda (symbol)
     (when (and (fboundp symbol)
                (string-prefix-p "my/multiple-cursors-workbench/" (symbol-name symbol)))
       (add-to-list 'mc/cmds-to-run-once symbol)))))

(my/multiple-cursors-register-hydra-commands)

(keymap-global-set "C-," #'my/multiple-cursors-workbench/body)

(with-eval-after-load 'general
  (general-define-key "C-," '("多光标工作台" . my/multiple-cursors-workbench/body))
  (my-leader-def
    "e l" '("multiple cursors on lines" . mc/edit-lines)
    "e n" '("mark next occurrence" . mc/mark-next-like-this)
    "e p" '("mark previous occurrence" . mc/mark-previous-like-this)
    "e a" '("mark all occurrences" . mc/mark-all-like-this)))

(with-eval-after-load 'multiple-cursors-core
  (add-to-list 'mc/cmds-to-run-once #'mc/unmark-current-like-this)
  (add-to-list 'mc/cmds-to-run-once #'my-copy-dwim)
  (my/multiple-cursors-register-hydra-commands))

(provide 'init-multiple-cursors)
;;; init-multiple-cursors.el ends here
