;;; init-diffnav.el --- diffnav 本地插件配置 -*- lexical-binding: t; -*-

;; 中文说明：此模块使用 use-package 引入仓库内的 diffnav-emacs 插件；插件
;; 只在用户主动启动时检查外部可执行文件，不改变 Magit、Diff Mode 或 Git 配置。

(use-package diffnav-emacs
  ;; 中文说明：use-package 会将相对路径按 user-emacs-directory 展开；使用
  ;; 字符串而非表达式，保证冷启动和字节编译时都能正确加入 load-path。
  :load-path "plugins/diffnav-emacs"
  ;; 中文说明：这是仓库内本地插件，不交给 straight 查询或下载远程包。
  :straight nil
  :demand t
  :config
  ;; 中文说明：保留 PATH 中的 diffnav 解析结果；需要固定版本时可在 custom.el
  ;; 中把 `diffnav-emacs-executable' 改为具体绝对路径。
  (setq diffnav-emacs-executable "diffnav")

  (with-eval-after-load 'general
    ;; 中文说明：Git 分组保留既有 Magit 键位；使用空闲的 v/V/w/b/F 提供
    ;; Diffnav 的工作区、暂存区、监看、当前文件状态与预设提交比较入口。
    (my-leader-def
      "g n" '("Diffnav 操作菜单" . diffnav-emacs-menu)
      "g b" '("Diffnav 提交版本比较" . diffnav-emacs-revision-menu)
      "g v" '("Diffnav 工作区改动" . diffnav-emacs-working-tree)
      "g V" '("Diffnav 暂存区改动" . diffnav-emacs-staged)
      "g w" '("Diffnav 监看工作区" . diffnav-emacs-watch-working-tree)
      "g F" '("Diffnav 当前文件状态" . diffnav-emacs-current-file-menu))))

(provide 'init-diffnav)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c g n' 打开 Diffnav 的 Transient 菜单；`C-c g b' 打开预设提交比较菜单。
;;   其中“当前分支相对默认分支”会自动识别 origin/HEAD、main 或 master。
;; - 当前文件菜单按 Git 状态只显示适用项：未跟踪、未暂存、已暂存、已提交或冲突。
;; - `C-c SPC' 的“项目与 Git”列按 `v' 可打开 Diffnav 操作菜单。
;; - 在 diffnav 终端中按 `q' 返回 Emacs；按 `s' 切换左右/统一 diff 视图。
;; - 外部 diffnav 不存在时，只会在调用时提示安装或配置路径，不影响其他功能。
;;; init-diffnav.el ends here
