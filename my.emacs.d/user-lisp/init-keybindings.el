;; -*- lexical-binding: t -*-


;; 开启 Emacs 28+ 内置的快捷键重复模式
(repeat-mode 1)
;; 示例：
;; 撤销操作 (C-x u)：
;; 原生：你需要按 C-x u  C-x u  C-x u 来连续撤销。
;; 开启 repeat-mode 后：你只需要按 C-x u  u  u  u 即可连续撤销！



;; 电感式”的 Buffer 列表模式 electric-buffer-list
;; 开启后，光标会直接定位到列表，而且选完 Buffer 回车后窗口会自动恢复
(global-set-key (kbd "C-x C-b") 'electric-buffer-list)




;; ============================================================================
;; 1. Which-Key: 自动弹出按键提示面板
;; ============================================================================
(use-package which-key
  :straight t
  :init
  (setq which-key-idle-delay 0.4          ; 停顿 0.4 秒后弹出提示
        which-key-popup-type 'side-window ; 在底部侧边窗口显示
        which-key-side-window-location 'bottom)
  :config
  (which-key-mode 1))

;; ============================================================================
;; 2. Hydra: 定义连续/反复操作的微型状态机
;; ============================================================================
(use-package hydra
  :straight t)

;; 示例：定义一个窗口调整的 Hydra
(defhydra hydra-window-resize (:hint nil)
  "
  Window Size: _j_ Shrink-V  _k_ Enlarge-V  _h_ Shrink-H  _l_ Enlarge-H  _=_ Balance  _q_ Quit
  "
  ("j" shrink-window "shrink vertical")
  ("k" enlarge-window "enlarge vertical")
  ("h" shrink-window-horizontally "shrink horizontal")
  ("l" enlarge-window-horizontally "enlarge horizontal")
  ("=" balance-windows "balance")
  ("q" nil "quit" :exit t))

;; ============================================================================
;; 3. General.el: 统筹全局，绑定 Leader 键并联动 Hydra 和 Which-Key
;; ============================================================================
(use-package general
  :straight t
  :config
  ;; 定义一个以 C-c 为前缀的全局 Leader 键
  (general-create-definer my-leader-def
    :prefix "C-c"
    :non-normal-prefix "C-c")

  (my-leader-def
    ;; 顶层菜单命名（which-key 会读取这些名字）
    "f" '(:ignore t :which-key "Files")
    "ff" 'find-file
    "fr" 'recentf-open-files

    "b" '(:ignore t :which-key "Buffers")
    "bb" 'switch-to-buffer
    "bk" 'kill-current-buffer

    ;; 重点：将 Hydra 挂载到 General 的 Leader 键菜单上！
    "w" '(:ignore t :which-key "Windows")
    "wr" '(hydra-window-resize/body :which-key "resize-hydra")))


;; 使用general参数代替bind的示例
;; (use-package magit
;;  :straight t
;;  :general
;;  (my-leader-def
;;    "g g" 'magit-status)) ; 依然用的是你全局定义好的 my-leader-def

(message "my keybindings  loaded!")
(provide 'init-keybindings)
