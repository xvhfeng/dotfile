;;; init-dired.el --- Polished native Dired configuration -*- lexical-binding: t; -*-

(require 'dired)
(require 'dired-x)

(defvar my/native-dired-ui-allowed t
  "Non-nil means a new Dired buffer may enable the native Dired UI.
Ranger dynamically binds this to nil while it creates its own buffers.")

(defconst my/dired-gnu-ls
  (or (and (eq system-type 'darwin) (executable-find "gls"))
      (and (not (memq system-type '(darwin berkeley-unix)))
           (executable-find "ls")))
  "GNU ls executable used by Dired, or nil when unavailable.")

(defun my/dired-visual-setup ()
  "Apply a compact, icon-friendly presentation to the current Dired buffer."
  (when my/native-dired-ui-allowed
    (my/dired-ui-mode 1)
    (dired-hide-details-mode 1)
    (hl-line-mode 1)
    (display-line-numbers-mode -1)
    (setq-local truncate-lines t
                header-line-format
                '(:eval
                  (propertize
                   (concat "  " (abbreviate-file-name default-directory))
                   'face 'dired-directory)))))

(defvar-keymap my/dired-ui-mode-map
  :doc "Only active in native Dired buffers.")

(define-minor-mode my/dired-ui-mode
  "Presentation and key bindings used only by native Dired."
  :init-value nil
  :lighter nil
  :keymap my/dired-ui-mode-map)

(defun my/dired-enable-nerd-icons ()
  "Enable Nerd Icons only for native Dired, never for Ranger buffers."
  (when my/native-dired-ui-allowed
    (nerd-icons-dired-mode 1)))

(use-package dired
  :straight nil
  :custom
  (dired-auto-revert-buffer t)
  (dired-dwim-target t)
  (dired-free-space nil)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  :init
  ;; macOS 自带 BSD ls 不支持目录优先；已安装 GNU coreutils 时使用 gls。
  (if my/dired-gnu-ls
      (setq insert-directory-program my/dired-gnu-ls
            dired-use-ls-dired t
            dired-listing-switches
            "-alh --group-directories-first --time-style=long-iso")
    (setq dired-use-ls-dired nil
          dired-listing-switches "-alh"))
  :hook (dired-mode . my/dired-visual-setup)
  :config
  (put 'dired-find-alternate-file 'disabled nil))

;; 与 doom-modeline 共用同一套 Nerd Font 图标，不再混用 all-the-icons。
(use-package nerd-icons-dired
  :straight (:host github :repo "rainstormstudio/nerd-icons-dired")
  :after (dired nerd-icons)
  :hook (dired-mode . my/dired-enable-nerd-icons))

;; 光标移动到文件时可按需显示预览；默认关闭，避免打开 Dired 就改变窗口布局。
(use-package dired-preview
  :straight (:host github :repo "protesilaos/dired-preview")
  :commands dired-preview-mode
  :custom
  (dired-preview-delay 0.15)
  (dired-preview-max-size (* 10 1024 1024)))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'my/dired-ui-mode-map
   "h" '("上级目录" . dired-up-directory)
   "l" '("在此打开" . dired-find-alternate-file)
   "j" '("下一项" . dired-next-line)
   "k" '("上一项" . dired-previous-line)
   "f" '("定位文件" . dired-goto-file)
   "." '("切换隐藏文件" . dired-omit-mode)
   "z" '("切换详情" . dired-hide-details-mode)
   "P" '("切换文件预览" . dired-preview-mode)
   "g" '("刷新目录" . revert-buffer))
  (my-leader-def
    "d d" '("Dired 当前目录" . dired-jump)
    "d p" '("Dired 项目根目录" . project-dired)))

(provide 'init-dired)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c d d' 打开当前目录，`C-c d p' 打开项目根目录；本模块使用 Nerd Icons。
;; - Dired 内 `h/l' 返回父目录/在当前 Buffer 打开，`j/k' 下移/上移，`g' 刷新。
;; - `f' 定位文件，`.' 显示/隐藏忽略文件，`z' 显示/隐藏详情，`P' 开关文件预览。
;; - 原生 Dired 的标记、复制、重命名和删除仍使用标准键 `m/u/C/R/D'。
;; - macOS 安装 GNU coreutils 后会自动使用 gls 实现目录优先排序；未安装也可正常使用。
;; - Dired 与 Ranger 的图标、局部变量和按键彼此隔离，调用 Ranger 不会接管 Dired。
;;; init-dired.el ends here
