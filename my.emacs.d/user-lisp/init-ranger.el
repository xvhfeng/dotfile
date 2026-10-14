;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; Ranger: 类似终端 Ranger 的文件管理器 (整合 Dired + 实时预览)
;; ============================================================================

;; 1. 确保安装并加载 hydra
(use-package hydra
  :straight t)

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

(use-package all-the-icons
  :straight t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :straight t
  :if (display-graphic-p)
  :commands all-the-icons-dired-mode)


(use-package ranger
  :straight (:host github :repo "punassuming/ranger.el")
 :after hydra
  :general
  ("C-c r" '("Ranger file manager" . ranger))
  
  :custom
  ;; 1. 是否在启动 dired 时自动替换为 ranger 界面（建议先设为 nil，用 C-c r 手动调出）
  (ranger-override-dired nil)

  ;; 2. 界面与外观优化
  (ranger-show-hidden t)             ; 显示隐藏文件
  (ranger-cleanup-on-disable t)      ; 关闭时清理后台临时 Buffer
  (ranger-max-preview-size 10)       ; 限制文件预览大小为 10MB
  (ranger-dont-show-binary t)        ; 不预览二进制文件
  (ranger-parent-depth 1)            ; 左侧父目录深度
  (ranger-preview-file t)            ; 开启右侧文件预览
  (ranger-show-literal t)            ; 开启排版美化

  :config
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
  (setq ranger-header-func 'ranger-header-line))

(with-eval-after-load 'general
  (my-leader-def
    "d r" '("Ranger file manager" . ranger)))

(provide 'init-ranger)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c r' 或 `C-z d r' 打开 Ranger；它不会替换原生 Dired。
;; - Ranger 使用原来的三栏目录/文件预览和 All The Icons，与 Dired 的 Nerd Icons 隔离。
;; - 常用导航为 `h/j/k/l'，`RET' 打开，`q' 退出；具体包内操作可按 `?' 查看。
;; - `/` 按文件名正则搜索，`n/N' 向后/向前重复；实现不进入 I-search。
;; - 文件预览上限为 10 MB，二进制文件不预览，退出时会清理临时 Buffer。
