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

(defvar-local my/multiple-cursors-collected-positions nil
  "Marker and highlight-overlay pairs for keyboard multi-cursor editing.")

(defface my/multiple-cursors-collected-position-face
  '((t :background "yellow" :foreground "black" :weight bold))
  "Highly visible face for a position collected before multi-cursor editing.")

(defun my/multiple-cursors-clear-collected-positions ()
  "Discard all positions collected for keyboard multi-cursor editing."
  (interactive)
  (mapc (lambda (entry)
          (set-marker (car entry) nil)
          (delete-overlay (cdr entry)))
        my/multiple-cursors-collected-positions)
  (setq my/multiple-cursors-collected-positions nil)
  (message "已清空多光标定位点"))

(defun my/multiple-cursors-collect-position ()
  "Collect point as an arbitrary, bare cursor location without editing yet."
  (interactive)
  (if (member (point)
              (mapcar (lambda (entry) (marker-position (car entry)))
                      my/multiple-cursors-collected-positions))
      (message "当前位置已在多光标定位点中")
    (let* ((marker (copy-marker (point)))
           (overlay (make-overlay (point) (min (1+ (point)) (point-max)))))
      (overlay-put overlay 'face 'my/multiple-cursors-collected-position-face)
      (when (= (point) (point-max))
        (overlay-put overlay 'before-string
                     (propertize "●" 'face
                                 'my/multiple-cursors-collected-position-face)))
      (push (cons marker overlay) my/multiple-cursors-collected-positions))
    (message "已收集 %d 个多光标定位点"
             (length my/multiple-cursors-collected-positions))))

(defun my/multiple-cursors-cancel-collected-position ()
  "Remove the collected position at point."
  (interactive)
  (let (entry)
    (dolist (candidate my/multiple-cursors-collected-positions)
      (when (= (point) (marker-position (car candidate)))
        (setq entry candidate)))
    (unless entry
      (user-error "当前位置没有待收集的多光标定位点"))
    (setq my/multiple-cursors-collected-positions
          (delq entry my/multiple-cursors-collected-positions))
    (set-marker (car entry) nil)
    (delete-overlay (cdr entry))
    (message "已取消当前位置，剩余 %d 个定位点"
             (length my/multiple-cursors-collected-positions))))

(defun my/multiple-cursors-start-collected-positions ()
  "Turn collected positions into bare Multiple Cursors for synchronized edits."
  (interactive)
  (let ((markers (sort (seq-filter #'marker-position
                                   (mapcar #'car
                                           my/multiple-cursors-collected-positions))
                       (lambda (a b)
                         (< (marker-position a) (marker-position b))))))
    (unless (> (length markers) 1)
      (user-error "请先用 x a 收集至少两个定位点"))
    (mc/remove-fake-cursors)
    (deactivate-mark)
    (goto-char (marker-position (car markers)))
    (dolist (marker (cdr markers))
      (save-excursion
        (goto-char (marker-position marker))
        (mc/create-fake-cursor-at-point)))
    (my/multiple-cursors-clear-collected-positions)
    (multiple-cursors-mode 1)))


(defhydra my/multiple-cursors-workbench (:hint nil :color red :foreign-keys run)
  "
常用: _n_ 下一个  _w_ 匹配单词  _s_ 匹配符号  _m_ 完整单词  _y_ 完整符号
      _N_ 上一个  _W_ 上词  _S_ 上符号  _M_ 上完整词  _Y_ 上完整符号  _k_ 取消当前
批量: _a a_ 全部  _a d_ 智能全部  _a w_ 全词  _a s_ 全符号  _a r_ 区域  _a f_ 函数
编辑: _e l_ 按行  _e b_ 行首  _e e_ 行尾  _i n_ 数字  _i l_ 字母
定位: _x a_ 收集并高亮当前位置  _x d_ 取消当前位置  _x s_ 开始多点编辑  _x c_ 清空定位点
跳过: _q n_ 跳过下个  _q p_ 跳过上个  _t t_ 标签对  _r c_ 矩形锚点
整理: _o s_ 排序  _o r_ 反转  _o v_ 垂直对齐  _o w_ 空格对齐
退出: 直接输入开始同步编辑；_ESC_ 退出菜单，_C-g_ 结束多光标"
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
  ("x a" my/multiple-cursors-collect-position)
  ("x d" my/multiple-cursors-cancel-collected-position)
  ("x s" my/multiple-cursors-start-collected-positions :exit t)
  ("x c" my/multiple-cursors-clear-collected-positions)
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
  ("<escape>" nil :exit t)
  ("C-g" mc/keyboard-quit :exit t))

(defun my/multiple-cursors-register-hydra-commands (&rest _)
  "Tell Multiple Cursors to run generated Hydra wrapper commands only once."
  (mapatoms
   (lambda (symbol)
     (when (and (fboundp symbol)
                (string-prefix-p "my/multiple-cursors-workbench/" (symbol-name symbol)))
       (add-to-list 'mc/cmds-to-run-once symbol)))))

(defun my/multiple-cursors--skip-hydra-wrapper (original &rest args)
  "Never replay Hydra lifecycle wrappers at fake cursors."
  (if (and (symbolp mc--this-command)
           (string-prefix-p "my/multiple-cursors-workbench/"
                            (symbol-name mc--this-command)))
      nil
    (apply original args)))

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
  (define-key mc/keymap (kbd "DEL") #'backward-delete-char-untabify)
  (define-key mc/keymap [backspace] #'backward-delete-char-untabify)
  (define-key mc/keymap [delete] #'delete-char)
  (my/multiple-cursors-register-hydra-commands)
  ;; `mc/load-lists' restores the user's saved lists with `setq', which
  ;; otherwise erases the generated Hydra commands registered above.
  (advice-add #'mc/load-lists :after
              #'my/multiple-cursors-register-hydra-commands)
  (advice-add #'mc/execute-this-command-for-all-cursors :around
              #'my/multiple-cursors--skip-hydra-wrapper))

(provide 'init-multiple-cursors)
;;; init-multiple-cursors.el ends here
