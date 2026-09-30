;;; init-editing.el --- Advanced Non-Evil Editing Suite -*- lexical-binding: t; -*-

;;; Commentary:
;; 本文件包含非-Evil（Emacs 原生快捷键模式）下的高效文本编辑与围栏符号增强方案。
;; 提供了类似于 Vim 的 ci/ca/ys/cs/ds 快捷体验以及多光标、语义选区扩充。

;;; Code:

;; ============================================================================
;; 1. Change-Inner: 实现类似 Vim 的 ci" / ca" / ci( / ca( 操作
;; ============================================================================
(use-package change-inner
  :straight t
  :bind (("M-i" . change-inner)      ; M-i + 引号/括号 -> 清空内部并进入编辑 (对应 ci)
         ("M-o" . change-outer)))     ; M-o + 引号/括号 -> 连同符号一起清除并编辑 (对应 ca)

;; ============================================================================
;; 2. Embrace: 实现类似 Vim 的 ys / cs / ds (Surround 围栏符号增删改)
;; ============================================================================
(use-package embrace
  :straight t
  ;; 绑定快捷键唤出 embrace 菜单 (a: 增加, c: 修改, d: 删除)
  :bind ("C-c e" . embrace-commander)
  :config
  ;; 为常见的 major-mode 启用官方内置的扩展配置 (例如 org-mode, elisp 等)
  (add-hook 'org-mode-hook #'embrace-org-mode-hook)
  (add-hook 'emacs-lisp-mode-hook #'embrace-emacs-lisp-mode-hook))

;; ============================================================================
;; 3. Expand-Region: 按语法结构/语义扩展/缩减选区
;; ============================================================================
(use-package expand-region
  :straight t
  :bind (("C-=" . er/expand-region)  ; 按 C-= 逐步扩大选中区域 (字符 -> 单词 -> 符号 -> 函数)
         ("C--" . er/contract-region))) ; 按 C-- 逐步缩小选中区域

;; ============================================================================
;; 4. Multiple-Cursors: 多光标并发编辑
;; ============================================================================
(use-package multiple-cursors
  :straight t
  :bind (("C-S-c C-S-c" . mc/edit-lines)              ; 选中多行后，在每行首插入光标
         ("C->"         . mc/mark-next-like-this)     ; 标记选中下一个相同的词/变量
         ("C-<"         . mc/mark-previous-like-this) ; 标记选中上一个相同的词/变量
         ("C-c C-<"     . mc/mark-all-like-this)))     ; 一键高亮选中所有匹配项

(provide 'init-edit)
;;; init-editing.el ends here
