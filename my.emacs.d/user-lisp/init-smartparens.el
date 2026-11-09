;;; init-smartparens.el --- Smartparens Hydra workbench -*- lexical-binding: t; -*-

(require 'cl-lib)
(use-package hydra :straight t :demand t)

(use-package smartparens
  :straight (:host github :repo "Fuco1/smartparens")
  :demand t
  :config
  (require 'smartparens-config)
  ;; Smartparens takes over automatic pair insertion from electric-pair.
  (electric-pair-mode -1)
  (smartparens-global-mode 1))

;; (use-package change-inner :straight t :demand t)

(use-package embrace
  :straight t
  :demand t
  :config
  (add-hook 'org-mode-hook #'embrace-org-mode-hook)
  (add-hook 'emacs-lisp-mode-hook #'embrace-emacs-lisp-mode-hook))

(defvar my/smartparens-command-pages nil
  "Completion choices for Hydra pages containing Smartparens commands.")

(defun my/smartparens-open-command-page ()
  "Choose a Hydra page containing Smartparens interactive commands."
  (interactive)
  (unless my/smartparens-command-pages
    (user-error "没有可用的 Smartparens 命令"))
  (let* ((choice (completing-read "Smartparens 命令页: "
                                  my/smartparens-command-pages nil t))
         (body (cdr (assoc choice my/smartparens-command-pages))))
    (funcall body)))

(defhydra my/smartparens-workbench (:hint nil :color pink :foreign-keys warn)
  "
导航: _f_ 跳到下一表达式之后  _b_ 跳到上一表达式之前  _d_ 进入下一层括号  _u_ 离开当前层括号
      _n_ 同级下一个表达式  _p_ 同级上一个表达式
吞吐: _S_ 右吞右侧表达式  _A_ 左吞左侧表达式  _B_ 右吐最右侧表达式  _F_ 左吐最左侧表达式
结构: _s_ 拆除外层括号并保留内容  _U_ 解包当前或邻接括号  _r_ 提升当前表达式并替换外层结构
      _t_ 交换相邻表达式  _j_ 合并相邻同级表达式  _v_ 在光标处拆分表达式
文本: _c_ 复制完整表达式  _k_ 剪切表达式并保持括号平衡
      _i_ 清空下一表达式内部  _I_ 清空当前包围结构内部
扩展: _e_ Embrace（添加、修改或删除围栏）
帮助: _o_ 打开全部命令分页  _?_ 查看 Smartparens 速查表
退出: _q_ / _C-t_ / ESC / _C-g_"
  ("f" sp-forward-sexp)
  ("b" sp-backward-sexp)
  ("u" sp-up-sexp)
  ("d" sp-down-sexp)
  ("n" sp-next-sexp)
  ("p" sp-previous-sexp)
  ("S" sp-forward-slurp-sexp)
  ("A" sp-backward-slurp-sexp)
  ("B" sp-forward-barf-sexp)
  ("F" sp-backward-barf-sexp)
  ("s" sp-splice-sexp)
  ("r" sp-raise-sexp)
  ("t" sp-transpose-sexp)
  ("j" sp-join-sexp)
  ("v" sp-split-sexp)
  ("U" sp-unwrap-sexp)
  ("c" sp-copy-sexp)
  ("k" sp-kill-sexp)
  ("i" sp-change-inner :exit t)
  ("I" sp-change-enclosing :exit t)
  ("e" my/embrace-menu/body :exit t)
  ("o" my/smartparens-open-command-page :exit t)
  ("?" sp-cheat-sheet :exit t)
  ("q" nil :exit t)
  ("C-t" nil :exit t)
  ("<escape>" nil :exit t)
  ("C-g" nil :exit t))

;; (defhydra my/change-inner-menu (:hint nil :color pink :foreign-keys warn)
;;   "
;; ChangeInner
;; _i_ 修改包围结构内部内容  _o_ 修改整个包围结构
;; _b_ 返回 Smartparens  _C-t_ / _q_ 退出"
;;   ("i" change-inner :exit t)
;;   ("o" change-outer :exit t)
;;   ("b" my/smartparens-workbench/body :exit t)
;;   ("C-t" nil :exit t)
;;   ("q" nil :exit t))

(defhydra my/embrace-menu (:hint nil :color pink :foreign-keys warn)
  "
Embrace
_a_ 添加围栏  _c_ 修改围栏  _d_ 删除围栏  _m_ 打开 Embrace 总菜单
_b_ 返回 Smartparens  _C-t_ / _q_ 退出"
  ("a" embrace-add :exit t)
  ("c" embrace-change :exit t)
  ("d" embrace-delete :exit t)
  ("m" embrace-commander :exit t)
  ("b" my/smartparens-workbench/body :exit t)
  ("C-t" nil :exit t)
  ("q" nil :exit t))

(defun my/smartparens-build-command-pages ()
  "Bind every interactive Smartparens command in numbered Hydra pages."
  (let* ((commands
          (sort (delete-dups
                 (cl-loop for entry in (cdr (feature-symbols 'smartparens))
                          for command = (and (consp entry) (cdr entry))
                          when (and (eq (car-safe entry) 'defun)
                                    (symbolp command)
                                    (commandp command)
                                    (not (eq command 'advice-compilation)))
                          collect command))
                (lambda (a b) (string< (symbol-name a) (symbol-name b)))))
         (page-size 9))
    (setq my/smartparens-command-pages nil)
    (cl-loop for start from 0 below (length commands) by page-size
             for number from 1
             for chunk = (cl-subseq commands start
                                     (min (+ start page-size) (length commands)))
             for name = (intern (format "my/smartparens-commands-%02d" number))
             for body = (intern (format "%s/body" name))
             for title = (format "%02d: %s … %s" number
                                 (car chunk) (car (last chunk)))
             for hint = (concat
                         (format "Smartparens 命令页 %02d\n" number)
                         (mapconcat
                          (lambda (item)
                            (format "%d %s" (car item) (cdr item)))
                          (cl-loop for command in chunk for key from 1
                                   collect (cons key command)) "\n")
                         "\nb 返回  C-t / q 退出")
             do (eval `(defhydra ,name (:hint nil :color pink :foreign-keys warn)
                         ,hint
                         ,@(cl-loop for command in chunk for key from 1
                                    collect (list (number-to-string key) command))
                         ("b" my/smartparens-workbench/body :exit t)
                         ("C-t" nil :exit t)
                         ("q" nil :exit t)))
             do (push (cons title body) my/smartparens-command-pages))
    (setq my/smartparens-command-pages
          (nreverse my/smartparens-command-pages))))

(my/smartparens-build-command-pages)
(when (eq (lookup-key (current-global-map) (kbd "C-q"))
          #'my/smartparens-workbench/body)
  (keymap-global-set "C-q" #'quoted-insert))
(keymap-global-set "C-t" #'my/smartparens-workbench/body)

(with-eval-after-load 'general
  ;; (general-define-key
  ;;   "M-i" '("ChangeInner 内部" . change-inner)
  ;;   "M-o" '("ChangeInner 整体" . change-outer))
  (my-leader-def
    ;; "e i" '("ChangeInner 内部" . change-inner)
    ;; "e o" '("ChangeInner 整体" . change-outer)
    "e s" '("Embrace 围栏菜单" . embrace-commander))
  (general-define-key "C-t" '("Smartparens 菜单" . my/smartparens-workbench/body)))

(provide 'init-smartparens)
;;; init-smartparens.el ends here
