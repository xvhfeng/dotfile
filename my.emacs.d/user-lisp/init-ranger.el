;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; Ranger: 类似终端 Ranger 的文件管理器 (整合 Dired + 实时预览)
;; ============================================================================

;; Hydra 由 init-window.el 统一安装和加载；Ranger 仅按命令延迟加载自身。

(defun my/ranger-add-straight-package-paths ()
  "Register Ranger and icon package build directories before requiring them."
  (dolist (package '(ranger all-the-icons all-the-icons-dired))
    (let ((directory
           (expand-file-name (format "straight/build/%s" package)
                             user-emacs-directory)))
      (when (file-directory-p directory)
        (add-to-list 'load-path directory)))))

(my/ranger-add-straight-package-paths)

(defun my/ranger-require ()
  "Load the locally built Ranger package through its registered build path."
  (my/ranger-add-straight-package-paths)
  (require 'ranger))

(defun my/ranger-restore-command-line-keymap ()
  "Restore Ranger's native command-line keymap and navigation prefixes."
  (setq ranger-map-style 'ranger)
  (when (and (keymapp ranger-mode-map)
             (keymapp ranger-normal-mode-map))
    (set-keymap-parent ranger-mode-map ranger-normal-mode-map))
  ;; This binding was previously overwritten by Ranger's optional Hydra.
  (when (keymapp ranger-mode-map)
    (define-key ranger-mode-map "g" #'ranger-go)))

(defun my/ranger-disable-hydra ()
  "Disable Ranger's incompatible optional Hydra integration.
Recent Ranger releases may define the optional Hydra menu when Hydra is
available even if the menu was previously enabled only temporarily.  Restore
the normal `g' navigation command so it can never evaluate `ranger-hydra-go'
as a variable."
  (setq ranger-use-hydra nil)
  (when (boundp 'ranger-mode-map)
    (my/ranger-restore-command-line-keymap)))

(defun my/ranger-finish-isearch ()
  "Finish I-search before Ranger changes the current buffer.
Ranger's upstream hook only clears `isearch--current-buffer', which can leave
`isearch-mode-map' installed as `overriding-terminal-local-map'."
  (when (bound-and-true-p isearch-mode)
    (isearch-done))
  ;; Repair a half-closed search left by an earlier Ranger invocation.
  (when (and (boundp 'isearch-mode-map)
             (eq overriding-terminal-local-map isearch-mode-map))
    (setq overriding-terminal-local-map nil)))

(defvar-local my/ranger-search-regexp nil
  "Last filename regexp used by Ranger's non-I-search search commands.")

(defun my/ranger--step-search-line (direction)
  "Move one Dired line in DIRECTION, wrapping at buffer boundaries."
  (if (> direction 0)
      (when (/= (forward-line 1) 0)
        (goto-char (point-min)))
    (if (= (line-beginning-position) (point-min))
        (progn
          (goto-char (point-max))
          (forward-line -1))
      (forward-line -1))))

(defun my/ranger--search-filename (regexp direction)
  "Move to the next filename matching REGEXP in DIRECTION.
Search wraps once and never enters Emacs I-search."
  (let ((origin (point))
        (line-count (max 1 (line-number-at-pos (point-max))))
        found)
    (dotimes (_ line-count)
      (unless found
        (my/ranger--step-search-line direction)
        (let ((file (dired-get-filename nil t)))
          (when (and file
                     (string-match-p
                      regexp
                      (file-name-nondirectory (directory-file-name file))))
            (setq found t)))))
    (unless found
      (goto-char origin)
      (user-error "Ranger: no filename matches %s" regexp))
    found))

(defun my/ranger-search ()
  "Search Ranger filenames with a regexp, without activating I-search."
  (interactive)
  (setq my/ranger-search-regexp
        (read-regexp "Ranger filename regexp: " my/ranger-search-regexp))
  (my/ranger--search-filename my/ranger-search-regexp 1))

(defun my/ranger-search-next ()
  "Repeat the last Ranger filename search forward."
  (interactive)
  (unless my/ranger-search-regexp
    (user-error "Ranger: press / to start a filename search first"))
  (my/ranger--search-filename my/ranger-search-regexp 1))

(defun my/ranger-search-previous ()
  "Repeat the last Ranger filename search backward."
  (interactive)
  (unless my/ranger-search-regexp
    (user-error "Ranger: press / to start a filename search first"))
  (my/ranger--search-filename my/ranger-search-regexp -1))

(defun my/ranger--isolate-from-native-dired (function &rest args)
  "Finish I-search, then run FUNCTION with native Dired UI disabled."
  (my/ranger-finish-isearch)
  (let ((my/native-dired-ui-allowed nil))
    (apply function args)))

(defun my/ranger-enable-original-icons ()
  "Use Ranger's original all-the-icons renderer and remove Dired's Nerd Icons."
  (when (display-graphic-p)
    (require 'all-the-icons nil t)
    (require 'all-the-icons-dired nil t))
  (when (bound-and-true-p my/dired-ui-mode)
    (my/dired-ui-mode -1))
  (when (bound-and-true-p nerd-icons-dired-mode)
    (nerd-icons-dired-mode -1))
  (when (and (display-graphic-p)
             (fboundp 'all-the-icons-dired-mode))
    (all-the-icons-dired-mode 1)))

(defun my/ranger-enable-icons-in-created-dired-buffer ()
  "Enable Ranger icons in Dired buffers created inside a Ranger operation."
  (unless my/native-dired-ui-allowed
    (my/ranger-enable-original-icons)))

(defun my/ranger-open (&optional path)
  "Open the full three-pane Ranger UI, never the single-pane Deer variant."
  (interactive)
  (my/ranger-require)
  (my/ranger-restore-command-line-keymap)
  ;; `ranger-minimal' is kept as a frame parameter by Ranger.  Clear a stale
  ;; Deer-mode setting before opening so parent and preview panes are restored.
  (modify-frame-parameters nil '((ranger-minimal . nil)))
  (setq ranger-parent-depth 1
        ranger-preview-file t)
  (let ((my/native-dired-ui-allowed nil))
    (ranger path))
  (when (derived-mode-p 'ranger-mode)
    (my/ranger-enable-original-icons)))

(defun my/ranger-localize-dired-state (&rest _)
  "Make Dired/ls variables buffer-local before Ranger changes them.
This prevents an open Ranger session from changing native Dired buffers."
  (dolist (variable
           '(dired-listing-switches
             ls-lisp-use-insert-directory-program
             ls-lisp-ignore-case
             ls-lisp-verbosity
             ls-lisp-uid-s-fmt
             ls-lisp-gid-s-fmt
             ls-lisp-UCA-like-collation
             ls-lisp-format-time-list))
    (make-local-variable variable)))

(with-eval-after-load 'ranger
  ;; 不替换普通 Dired；只通过 Ranger 专用入口打开三栏界面。
  (setq ranger-override-dired nil
        ;; 上游可选 Hydra 菜单在当前 Hydra 版本下会触发变量错误。
        ranger-use-hydra nil
        ranger-show-hidden t
        ranger-cleanup-on-disable t
        ranger-max-preview-size 10
        ranger-dont-show-binary t
        ranger-parent-depth 1
        ranger-preview-file t
        ranger-show-literal t)
  ;; Ranger 会在内部创建若干 Dired 派生缓冲区。动态关闭原生 Dired UI，
  ;; 并在主窗口、父目录和预览目录中只启用 Ranger 原来的图标方案。
  (dolist (function '(ranger-find-file ranger-dir-buffer))
    (advice-remove function #'my/ranger--isolate-from-native-dired)
    (advice-add function :around #'my/ranger--isolate-from-native-dired))
  ;; Ranger's built-in /, n and N commands call `isearch-forward' directly.
  ;; Keep their familiar keys, but use a filename-only regexp search instead.
  (dolist (pair '((ranger-search . my/ranger-search)
                  (ranger-search-next . my/ranger-search-next)
                  (ranger-search-previous . my/ranger-search-previous)))
    (advice-remove (car pair) (cdr pair))
    (advice-add (car pair) :override (cdr pair)))
  (advice-remove 'ranger-setup #'my/ranger-localize-dired-state)
  (advice-add 'ranger-setup :before #'my/ranger-localize-dired-state)
  (add-hook 'dired-mode-hook #'my/ranger-enable-icons-in-created-dired-buffer)
  (add-hook 'ranger-mode-hook #'my/ranger-enable-original-icons)
  ;; Run after Ranger's own mode hooks so no hook can leave I-search half-open.
  (add-hook 'ranger-mode-hook #'my/ranger-finish-isearch t)
  ;; 设置标题栏样式
  (setq ranger-header-func 'ranger-header-line)
  (my/ranger-disable-hydra))

(with-eval-after-load 'general
  (general-define-key
   "C-c r" '("Ranger 文件管理器" . my/ranger-open))
  (my-leader-def
    "d r" '("Ranger 文件管理器" . my/ranger-open)))

(provide 'init-ranger)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c r' 或 `C-c d r' 打开 Ranger；它不会替换原生 Dired。
;; - Ranger 使用原来的三栏目录/文件预览和 All The Icons，与 Dired 的 Nerd Icons 隔离。
;; - 常用导航为 `h/j/k/l'，`RET' 打开，`q' 退出；具体包内操作可按 `?' 查看。
;; - `/` 按文件名正则搜索，`n/N' 向后/向前重复；实现不进入 I-search。
;; - 文件预览上限为 10 MB，二进制文件不预览，退出时会清理临时 Buffer。
