;;; init-separedit.el --- Edit comments and strings in separate buffers -*- lexical-binding: t; -*-

;;; Commentary:
;; 使用 separedit 在独立 Buffer 中编辑注释、字符串、docstring、heredoc、
;; Markdown/Org 围栏代码块和 C/C++ 多行宏。默认使用 Markdown 编辑普通文本，
;; 并保留原字符串缩进及当前文件可用的 fill-column 宽度。

;;; Code:

(declare-function separedit "separedit" ())
(declare-function separedit--apply-changes "separedit" ())
(declare-function separedit--point-info "separedit" (&optional beg end))
(declare-function separedit--restore-point "separedit" (line rcolumn))
(declare-function separedit-abort "separedit" ())
(declare-function separedit-commit "separedit" ())
(declare-function separedit-save "separedit" ())
(declare-function edit-indirect--abort "edit-indirect" (kill))

(defvar edit-indirect-mode-map)
(defvar edit-indirect--overlay)
(defvar separedit-entry-key)
(defvar separedit-commit-key)
(defvar separedit-save-key)
(defvar separedit-abort-key)

(defun my/separedit-setup-buffer ()
  "Apply this configuration's editing conventions to a separedit Buffer."
  ;; 只做视觉折行，不自动改写长注释；是否填充仍由用户显式决定。
  (visual-line-mode 1)
  (setq-local
   header-line-format
   (substitute-command-keys
    " 分离编辑  完成: `\\[separedit-commit]'  保存不退出: `\\[separedit-save]'  放弃: `\\[separedit-abort]' ")))

(defun my/separedit-commit ()
  "Commit the separate edit, return to its source Buffer and restore point.

Upstream `separedit-commit' assumes that closing the indirect edit window also
makes its source Buffer current.  That is not guaranteed in a reused or sole
window, so this implementation records and selects the source explicitly."
  (interactive)
  (unless (overlayp edit-indirect--overlay)
    (user-error "当前 Buffer 不是 separedit 分离编辑 Buffer"))
  (let* ((overlay edit-indirect--overlay)
         (source (overlay-buffer overlay))
         (point-info (separedit--point-info))
         region-beg region-end)
    (separedit--apply-changes)
    ;; The overlay tracks any size change caused by committing the edit.
    (setq region-beg (overlay-start overlay)
          region-end (overlay-end overlay))
    (edit-indirect--abort t)
    (unless (buffer-live-p source)
      (user-error "separedit 的源 Buffer 已被关闭"))
    (if-let ((window (get-buffer-window source t)))
        (select-window window)
      (switch-to-buffer source))
    (with-current-buffer source
      (goto-char
       (save-excursion
         (save-restriction
           (narrow-to-region region-beg (min region-end (point-max)))
           (goto-char (point-min))
           (apply #'separedit--restore-point point-info)
           (point)))))))

(use-package separedit
  :straight (:host github :repo "twlz0ne/separedit.el")
  :commands (separedit separedit-commit separedit-save separedit-abort)
  :init
  (setq separedit-entry-key (kbd "C-c e d")
        separedit-commit-key (kbd "C-c C-c")
        separedit-save-key (kbd "C-x C-s")
        separedit-abort-key (kbd "C-c C-k")
        separedit-default-mode 'markdown-mode
        ;; Python docstring、Shell heredoc 等内容保持原来的相对缩进。
        separedit-preserve-string-indentation t
        ;; 沿用源 Buffer 扣除注释前缀后的可用 fill-column。
        separedit-continue-fill-column t
        ;; 提交注释时清理行末空格，符合本配置统一使用空格缩进的习惯。
        separedit-remove-trailing-spaces-in-comment t
        ;; C-x C-s 只同步到源 Buffer，不越过用户主动保存文件的步骤。
        separedit-write-file-when-execute-save nil)
  :hook (separedit-buffer-creation . my/separedit-setup-buffer)
  :config
  ;; 上游提交命令依赖关闭窗口后的隐式 Buffer 切换；覆盖为显式返回源 Buffer
  ;; 的版本，避免单窗口或窗口被复用时在错误 Buffer 中恢复光标。
  (ora-advice-add 'separedit-commit :override #'my/separedit-commit)
  ;; 明确交给 General 管理间接编辑 Buffer 内的提交、保存和放弃操作。
  (general-define-key
    :keymaps 'edit-indirect-mode-map
    "C-c C-c" '("commit separate edit" . separedit-commit)
    "C-x C-s" '("save separate edit" . separedit-save)
    "C-c C-k" '("abort separate edit" . separedit-abort)))

;; Separedit 属于文本编辑操作，放在统一的 C-c e 编辑层级下。
(with-eval-after-load 'general
  (my-leader-def
    "e d" '("edit comment/string separately" . separedit)))

(provide 'init-separedit)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 把光标放在注释、字符串、docstring、heredoc、围栏代码块或 C/C++ 多行宏
;;   中，按 `C-c e d' 在独立 Buffer 中编辑；有选区时编辑整个选区。
;; - `C-u C-c e d'：先手工选择独立 Buffer 使用的 major mode。
;; - 独立 Buffer 默认使用 `markdown-mode'；带语言标记的代码块自动使用对应
;;   编程模式，并且可以再次按 `C-c e d' 继续进入内层字符串或代码块。
;; - `C-c C-c'：提交、关闭并可靠返回源 Buffer；`C-x C-s'：同步到源 Buffer 但保持打开；
;;   `C-c C-k'：放弃修改并关闭。
;; - 分离编辑时保留字符串缩进、延续源文件 fill-column，并使用视觉折行；
;;   `C-x C-s' 不会直接把源文件写入磁盘，仍由用户决定何时保存文件。
;;; init-separedit.el ends here
