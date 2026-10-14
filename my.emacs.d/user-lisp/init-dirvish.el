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
    "d v" '("open dirvish (full frame)" . dirvish)
    "d s" '("toggle side-bar file tree" . dirvish-side) ; 类似 VSCode 侧边栏
    "d f" '("fd search in directory" . dirvish-fd)
    "d j" '("quick jump to directory" . dirvish-fd-jump)
    "d h" '("directory history" . dirvish-history)
    "d m" '("mark actions menu" . dirvish-mark-menu)
    "d w" '("edit filenames with Wdired" . wdired-change-to-wdired-mode)))

;; ============================================================================
;; 3. Dirvish 内部常用快捷键提示 (原生 Dired 扩展)
;; ============================================================================
;; 打开 Dirvish 后，你可以直接使用以下键盘操作：
;;  - `TAB`     : 展开/折叠子目录 (Subtree Preview)
;;  - `a`       : 呼出 Dirvish 专属快捷菜单 (Quick Dispatcher)
;;  - `f`       : 实时过滤列表中的文件 (File Filter)
;;  - `m` / `u` : 标记 (Mark) / 取消标记 (Unmark) 文件
;;  - `C-c d w` : 开启 Wdired 模式 (允许把目录当纯文本修改文件名)
;;  - `q`       : 退出 Dirvish

(provide 'init-dirvish)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本模块当前未加入 `my/init-modules'，是 Dired/Ranger 之外的备用方案，默认不生效。
;; - 启用前应确认是否需要让 Dirvish 接管 Dired；当前配置会调用 `dirvish-override-dired-mode'。
;; - 启用后 `C-c d v/s/f/j/h/m/w'：全屏/侧栏/fd 搜索/目录跳转/历史/标记/Wdired。
;; - Dirvish 内 `TAB' 展开子目录，`a' 动作菜单，`f' 过滤，`m/u' 标记/取消，`q' 退出。
;; - `C-c d w' 进入 Wdired，可像编辑文本一样批量改名；完成后按 `C-c C-c' 保存。
;;; init-dirvish.el ends here
