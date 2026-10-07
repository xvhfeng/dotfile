;;; init-dirvish.el --- Modern file manager powered by Dirvish -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Dirvish: 基于 Dired 的现代文件/目录管理器
;; ============================================================================
(use-package dirvish
  :straight t
  :init
  ;; 自动接管默认的 Dired (例如按 C-x d 或打开目录时)
  (dirvish-override-dired-mode 1)
  :custom
  ;; 设置界面样式与组件：显示文件图标、平滑折叠、文件大小、修改时间等
  (dirvish-attributes
   '(nerd-icons file-time file-size collapse subtree-state vc-state))
  ;; 开启文件预览功能 (支持文本、代码高亮、图像等)
  (dirvish-mode-line-format
   '(:left (sort symlink) :right (omit vc-info index)))
  ;; 设置双栏/三栏预览的宽度比例
  (dirvish-preview-dispatchers '(clink image gif video audio epub archive pdf))
  :config
  ;; 常用参数优化
  (setq dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first")
  (setq dirvish-reuse-session t)
  ;; 开启子目录树状展开 (Subtree) 支持
  (setq dirvish-subtree-state-style 'nerd))

;; ============================================================================
;; 2. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; 目录与文件管理器 (Directory / Dired)
    "d"   '(:ignore t :which-key "Directory / File Manager")
    "d d" '(dirvish                 :which-key "open dirvish (full frame)")
    "d s" '(dirvish-side            :which-key "toggle side-bar file tree") ; 类似 VSCode 侧边栏
    "d f" '(dirvish-fd              :which-key "fd search in directory")
    "d j" '(dirvish-fd-jump         :which-key "quick jump to directory")
    "d h" '(dirvish-history         :which-key "directory history")
    "d m" '(dirvish-mark-menu       :which-key "mark actions menu")))

;; ============================================================================
;; 3. Dirvish 内部常用快捷键提示 (原生 Dired 扩展)
;; ============================================================================
;; 打开 Dirvish 后，你可以直接使用以下键盘操作：
;;  - `TAB`     : 展开/折叠子目录 (Subtree Preview)
;;  - `a`       : 呼出 Dirvish 专属快捷菜单 (Quick Dispatcher)
;;  - `f`       : 实时过滤列表中的文件 (File Filter)
;;  - `m` / `u` : 标记 (Mark) / 取消标记 (Unmark) 文件
;;  - `C-c C-w` : 开启 Wdired 模式 (极其强大！允许你把目录当纯文本直接修改文件名，保存即批量重命名)
;;  - `q`       : 退出 Dirvish

(provide 'init-dirvish)
;;; init-dirvish.el ends here