;;; init-bm.el --- 可视书签配置 -*- lexical-binding: t; -*-

(require 'cl-lib)

(declare-function bm-buffer-save-all "bm" ())
(declare-function bm-remove-all-all-buffers "bm" ())
(declare-function bm-repository-clear "bm" ())
(declare-function bm-repository-save "bm" ())

(defun my/bm-save-on-exit ()
  "退出 Emacs 前保存所有可视书签及其仓库。"
  (bm-buffer-save-all)
  (bm-repository-save))

(defun my/bm-clear-all ()
  "清除所有已打开 Buffer 的可视书签及未打开文件的持久化书签。"
  (interactive)
  ;; 中文说明：bm 的全局删除只处理已打开 Buffer；还须清空并立即保存仓库。
  (bm-remove-all-all-buffers)
  (bm-repository-clear)
  (bm-repository-save)
  (message "已清除所有可视书签。"))

(defun my/bm--dedupe-lists (lists)
  "移除 LISTS 两侧重复出现的同一个书签 overlay。"
  ;; 中文说明：Emacs 29+ 的两个 overlays-in 范围都包含光标所在行；
  ;; bm-lists 因此可能把同一个书签同时放入前后两组。
  (cons (car lists)
        (cl-remove-if (lambda (bookmark) (memq bookmark (car lists)))
                      (cdr lists))))

(use-package bm
  :straight (:host github :repo "joodland/bm")
  :demand t
  :init
  ;; 中文说明：先设置仓库路径再加载 bm，确保启动时能从 runtimes 恢复。
  (setq bm-repository-file (my/runtime-file "bm-repository")
        bm-restore-repository-on-load (file-readable-p bm-repository-file))
  (setq-default bm-buffer-persistence t)
  :config
  ;; 中文说明：在 bm-lists 的出口按 overlay 身份去重，同时修正列表、计数和保存。
  (unless (advice-member-p #'my/bm--dedupe-lists 'bm-lists)
    (advice-add 'bm-lists :filter-return #'my/bm--dedupe-lists))
  ;; 中文说明：书签只在文件打开、保存、关闭或 Emacs 退出时持久化。
  (add-hook 'find-file-hook #'bm-buffer-restore)
  (add-hook 'after-revert-hook #'bm-buffer-restore)
  (add-hook 'after-save-hook #'bm-buffer-save)
  (add-hook 'kill-buffer-hook #'bm-buffer-save)
  (add-hook 'kill-emacs-hook #'my/bm-save-on-exit))

(with-eval-after-load 'general
  (my-leader-def
    "j b t" '("切换当前行书签" . bm-toggle)
    "j b n" '("下一个可视书签" . bm-next)
    "j b p" '("上一个可视书签" . bm-previous)
    "j b l" '("列出当前文件书签" . bm-show)
    "j b a" '("列出全部可视书签" . bm-show-all)
    "j b d" '("清空当前文件书签" . bm-remove-all-current-buffer)
    "j b D" '("清空所有可视书签" . my/bm-clear-all)))

(provide 'init-bm)
;;; init-bm.el ends here
