;;; -*- lexical-binding: t -*-

;;; 中文导读：版本控制模块。VC/VC-Dir 是 Emacs 内置统一接口，Diff/Ediff 比较内容，
;;; Smerge 处理冲突，Transient 构建命令菜单，Magit 提供完整 Git 工作流。VC-Dir 中
;;; RET 看 diff、c 执行下一步版本控制动作、f 拉取；C-c g l 查看当前文件日志；
;;; Magit 状态页 RET 快速查看当前文件差异。退出 Ediff 后会恢复原窗口布局。
;; Emacs 内置版本控制系统 (VC) 核心配置
(use-package vc
  :ensure nil
  :custom
  (vc-follow-symlinks t)                                   ; 自动跟随符号链接（不弹窗询问）
  (vc-handled-backends '(Git))                             ; 仅启用 Git 后端，关闭 Hg/SVN 等提升性能
  ;; 忽略根目录匹配正则及 node_modules 目录，防止 VC 扫描巨型前端项目卡死
  (vc-ignored-dir-regexp (format "%s\\|%s" locate-dominating-stop-dir-regexp "[/\\\\]node_modules")))

;; VC-Dir 状态面板配置
(use-package vc-dir
  :ensure nil
  :bind
  (:map vc-dir-mode-map
   ("RET" . vc-diff)                                       ; 回车直接查看当前文件 Diff
   ("c" . vc-next-action)                                  ; c 键发起 Commit 或下一步 VC 操作
   ("f" . vc-pull))                                        ; f 键执行 git pull
  :hook (vc-dir-refresh . my-vc-dir-hide-dirs)             ; 刷新视图后自动隐藏纯目录节点
  :config
  ;; 函数：从 VC-Dir 界面中剔除目录条目，仅留存实际改变状态的文件
  (defun my-vc-dir-hide-dirs ()
    (when (and (boundp 'vc-ewoc) vc-ewoc)
      (ewoc-filter vc-ewoc (lambda (i) (not (vc-dir-fileinfo->directory i)))))))

;; Diff 模式（文本补丁/差异文件查看）
(use-package diff-mode
  :ensure nil
  :hook (diff-mode . outline-minor-mode)                   ; 开启 outline 节点折叠
  :custom
  (diff-refine nil)                                        ; 关闭高亮字级别的细粒度修改（提升速度）
  (diff-default-read-only t)                               ; 默认只读，防止误触修改
  (diff-advance-after-apply-hunk t)                        ; 应用 Hunk 补丁后自动跳到下一个 Hunk
  (diff-update-on-the-fly t)                               ; 随编辑动态更新 diff 状态
  (diff-font-lock-syntax 'hunk-also)                       ; 启用基于语法的 Hunk 增删高亮
  (diff-font-lock-prettify nil))                           ; 关闭美化字符以保持原始比对格式

;; Ediff 交互式三方合并/文件比对工具
(use-package ediff
  :ensure nil
  :hook
  (ediff-quit . tab-bar-history-back)                      ; 退出 Ediff 后切回 Tab 栏历史
  (ediff-prepare-buffer . outline-show-all)                ; 准备 Buffer 时展开所有隐藏内容
  (ediff-before-setup . my-ediff-save-wconf-h)             ; 启动 Ediff 前保存当前窗口布局
  ((ediff-quit ediff-suspend) . my-ediff-restore-wconf-h)  ; 退出/挂起 Ediff 后恢复窗口布局
  :custom
  (ediff-diff-options "-w")                                ; 默认忽略空白字符差异 (-w)
  (ediff-window-setup-function #'ediff-setup-windows-plain); Plain 模式：不弹独立 Control Frame 悬浮小窗，使用 Emacs 当前 Window
  (ediff-split-window-function #'split-window-horizontally)  ; 左右平铺分割窗口
  (ediff-merge-split-window-function #'split-window-horizontally)
  :config
  (defvar my--ediff-saved-wconf nil)                       ; 保存窗口布局的临时变量

  (defun my-ediff-save-wconf-h ()
    (setq my--ediff-saved-wconf (current-window-configuration)))

  (defun my-ediff-restore-wconf-h ()
    (when (window-configuration-p my--ediff-saved-wconf)
      (set-window-configuration my--ediff-saved-wconf))))

;; Smerge 冲突处理模式
(use-package smerge-mode
  :ensure nil
  :hook (find-file . my-init-smerge-mode-h)               ; 打开文件时触发检测
  :config
  ;; 快速检索文件内是否存在 Git 冲突标记 `<<<<<<< `，若存在则自动激活 smerge-mode
  (defun my-init-smerge-mode-h ()
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^<<<<<<< " nil t) (smerge-mode 1)))))

;; Transient (Magit 底部弹出的级联快捷菜单面板引擎)
(use-package transient
  :ensure nil
  :custom
  (transient-history-file (concat nn-directory "transient/history.el")) ; 独立存储 Transient 操作历史
  (transient-levels-file (concat nn-directory "transient/levels.el"))
  (transient-values-file (concat nn-directory "transient/values.el")))

;; Magit：Git 操作界面
(use-package magit
  :bind
  (("C-c g l" . magit-log-buffer-file)                     ; C-c g l 查看当前文件的 Commit 历史
   :map magit-status-mode-map
   ("<return>" . my-magit-fast-diff))                      ; 回车只聚焦查看光标所在文件的极速 Diff
  :hook
  ;; 设置 Git Commit 编辑框的换行宽度等于摘要最大长度
  (git-commit-setup . (lambda () (setq fill-column git-commit-summary-max-length)))
  ;; 规避 Magit 官方长行卡顿 Bug (#5320)：禁用长行阈值检测
  (magit-status-mode . (lambda () (setq long-line-threshold nil)))
  (magit-process-mode . goto-address-mode)                  ; 在 Magit 日志/输出 Buffer 中将 URL 渲染为超链接
  (magit-diff-visit-file . my-magit-reveal-point-if-invisible-h) ; 跳转到文件后自动展开折叠区域
  :custom
  (git-commit-major-mode 'git-commit-elisp-text-mode)
  (magit-commit-show-diff nil)                             ; Commit 时不默认显示完整 Diff (大幅加速)
  (magit-commit-ask-to-stage nil)                          ; 提交时不询问未暂存文件
  (magit-auto-revert-mode nil)                             ; 关闭自动 Revert (手动控制以换取速度)
  (magit-refresh-verbose nil)
  (magit-refresh-status-buffer nil)                        ; 关闭高开销的 status 自动刷新
  (magit-revision-insert-related-refs nil)                 ; 不在 Revision 中插入相关分支引用
  (magit-save-repository-buffers nil)                      ; 刷新时不保存项目所有 Buffer
  (magit-uniquify-buffer-names nil)                        ; 关闭独一无二的 Buffer 命名处理
  (magit-no-confirm '(stage-all-changes unstage-all-changes)) ; 暂存/取消暂存所有文件时不弹确认窗
  (magit-run-hooks-from-githooks (not (eq system-type 'windows-nt))) ; Windows 上禁用 git-hooks 提升速度
  ;; 自定义 Status 面板展示模块（移除了默认极其吃性能的完整 Diff 列表）
  (magit-status-sections-hook
   '(magit-insert-status-headers
     magit-insert-untracked-files
     my-magit-insert-unstaged-files
     my-magit-insert-staged-files
     magit-insert-recentcommits))
  :config
  ;; Git --name-status 的状态缩写映射表 (代码 -> 描述说明 -> 猫娘主题 Catppuccin 色值)
  (defconst my-magit--status-alist
    '(("M" "modified" . (:foreground "#f9e2af"))
      ("A" "new file" . (:foreground "#a6e3a1"))
      ("D" "deleted"  . (:foreground "#f38ba8"))
      ("R" "renamed"  . (:foreground "#89b4fa"))
      ("C" "copied"   . (:foreground "#94e2d5"))
      ("U" "unmerged" . (:foreground "#cba6f7"))))

  ;; 极简高效地插入由 git --name-status 提供的单行文件修改状态
  (defun my-magit--insert (lines)
    "Insert file status LINES as Magit file sections."
    (dolist (line lines)
      (let* ((parts (split-string line "\t"))
             (code (car parts))
             (file (car (last parts)))
             (info (and code (assoc (substring code 0 1) my-magit--status-alist))))
        (magit-insert-section (file file)
          (insert
           (propertize
            (format "%-10s%s\n" (if info (cadr info) code) file)
            'font-lock-face (if info (cddr info) 'magit-diff-file-heading))))))
    (insert "\n"))

  ;; 轻量替代函数：通过 `git diff --name-status` 获取未暂存列表并渲染
  (defun my-magit-insert-unstaged-files ()
    "Insert compact status entries for unstaged files."
    (when-let* ((lines (magit-git-lines "diff" "--name-status")))
      (magit-insert-section (unstaged)
        (magit-insert-heading t "Unstaged changes")
        (my-magit--insert lines))))

  ;; 轻量替代函数：通过 `git diff --cached --name-status` 获取已暂存列表并渲染
  (defun my-magit-insert-staged-files ()
    "Insert compact status entries for staged files."
    (unless (magit-bare-repo-p)
      (when-let* ((lines (magit-git-lines "diff" "--cached" "--name-status")))
        (magit-insert-section (staged)
          (magit-insert-heading t "Staged changes")
          (my-magit--insert lines)))))

  ;; 跳转回调函数：如果在 Org-mode 中，使用 `org-reveal` 展开当前光标隐藏树，否则调用 `reveal` 扩展展开
  (defun my-magit-reveal-point-if-invisible-h ()
    "Reveal the point if in an invisible region."
    (if (derived-mode-p 'org-mode)
        (org-reveal '(4))
      (require 'reveal)
      (reveal-post-command)))

  ;; 快速查看单文件 Diff 的自定义命令
  (defun my-magit-fast-diff ()
    (interactive)
    (when-let* ((file (magit-file-at-point)))
      (magit-diff-dwim nil `(,file)))))
(provide 'init-vc)
