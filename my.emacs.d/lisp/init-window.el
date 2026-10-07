;;; init-window.el --- Window management with ace-window -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Ace-Window: 窗口快速跳转、关闭、交换与切分核心
;; ============================================================================
(use-package ace-window
  :straight t
  :custom
  ;; 设置窗口选择标签：优先使用键盘 Home Row（中排按键），击键最快
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

  ;; 作用域：只在当前 Frame（窗口帧）内选择，避免跳到其他 Monitor/Frame
  (aw-scope 'frame)

  ;; 只有 2 个窗口时也强制显示编号标签，保持逻辑一致（默认 2 个窗口会自动直接跳转）
  (aw-dispatch-always t)

  :config
  ;; 自定义 Ace-Window 的快捷 Dispatch 动作列表 (按下 M-o 后，再按以下字母执行动作)：
  ;;  x - 关闭窗口 (Delete Window)
  ;;  m - 移动/交换窗口 (Swap Window)
  ;;  c - 复制当前 Buffer 到目标窗口 (Copy Window)
  ;;  v - 竖向切分 (Split Vertically / Side-by-side)
  ;;  b - 横向切分 (Split Horizontally / Below)
  ;;  o - 全屏化当前窗口 (Maximize / Delete Other Windows)
  (setq aw-dispatch-alist
        '((?x aw-delete-window "Delete Window")
          (?m aw-swap-window "Swap Window")
          (?c aw-copy-window "Copy Window")
          (?v aw-split-window-vert "Split Vertically")
          (?b aw-split-window-horiz "Split Horizontally")
          (?o delete-other-windows "Maximize Window")
          (?? aw-show-dispatch-help))))

;; ============================================================================
;; 2. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; 窗口管理主菜单 (Window)
    "w"   '(:ignore t :which-key "Windows")

    ;; 1. 窗口跳转 (Jump)
    "w w" '(ace-window             :which-key "ace window select/jump")
    "w M" '(ace-swap-window        :which-key "swap window with target")

    ;; 2. 窗口切分 (Split)
    "w v" '(split-window-right     :which-key "split vertically (|)")   ; 左右切分(生成竖向分界线)
    "w s" '(split-window-below     :which-key "split horizontally (-)") ; 上下切分(生成横向分界线)
    "w b" '(split-window-below     :which-key "split horizontally (-)")

    ;; 3. 窗口关闭与全屏 (Delete/Maximize)
    "w d" '(delete-window          :which-key "delete current window")
    "w x" '(ace-delete-window      :which-key "delete target window")
    "w m" '(delete-other-windows   :which-key "maximize current window")
    "w o" '(delete-other-windows   :which-key "delete other windows")

    ;; 4. 窗口平衡 (Balance)
    "w =" '(balance-windows        :which-key "balance windows size")))

(provide 'init-window)
;;; init-window.el ends here