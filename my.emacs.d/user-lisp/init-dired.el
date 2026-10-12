;;; -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. 内置 Dired 基础增强与性能优化
;; ============================================================================
(use-package dired
  :straight nil                          ; 内置包，无需 straight 安装
  :custom
  (dired-listing-switches "-lhA --group-directories-first") ; 人类可读文件大小 + 目录优先排列
  (dired-recursive-copies 'always)       ; 递归复制无需反复询问
  (dired-recursive-deletes 'always)     ; 递归删除无需反复询问
  (dired-dwim-target t)                  ; 开启双窗口时，自动以另一个窗口作为复制/移动的目标路径
  :config
  ;; 按 a 键直接在当前窗口打开目录/文件，防止产生大量不必要的 Dired Buffer
  (put 'dired-find-alternate-file 'disabled nil))

;; ============================================================================
;; 2. Dired 智能文件预览 (dired-preview)
;; ============================================================================
(use-package dired-preview
  :straight t
  :after dired
  :custom
  (dired-preview-delay 0.1)              ; 延迟 0.1 秒预览，滑动列表时极度流畅
  (dired-preview-max-size 10000000)      ; 超过 10MB 的文件跳过预览
  :config
  (dired-preview-global-mode 1))         ; 全局开启 Dired 侧边/弹窗实时预览

;; ============================================================================
;; 3. Dired 文件图标显示 (nerd-icons-dired)
;; ============================================================================
(use-package nerd-icons-dired
  :straight t
  :after dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; ============================================================================
;; 4. Dired 快捷按键优化 (类似 Ranger / Vim)
;; ============================================================================
(use-package dired
  :general
  (:keymaps 'dired-mode-map
   "h" '(dired-up-directory :which-key "parent directory")
   "l" '(dired-find-alternate-file :which-key "open file/directory")
   "j" '(dired-next-line :which-key "next entry")
   "k" '(dired-previous-line :which-key "previous entry")
   "f" '(dired-goto-file :which-key "find entry")
   "z" '(dired-hide-details-mode :which-key "toggle details")))

(with-eval-after-load 'general
  (my-leader-def
    "d d" '(dired-jump :which-key "Dired current directory")))

(provide 'init-dired)
