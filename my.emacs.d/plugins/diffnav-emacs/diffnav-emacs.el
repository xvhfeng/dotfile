;;; diffnav-emacs.el --- 在 Emacs 中启动 diffnav -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author: bigmouth <xvhfeng@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: tools, vc, diff
;; URL: https://github.com/dlvhdr/diffnav

;;; Commentary:
;;
;; diffnav 是终端交互式 Git diff 浏览器。此包默认通过原生模块驱动的 vterm
;; 运行 diffnav，保留其文件树、搜索和左右对比界面，同时提供 Emacs 命令入口。
;;
;;; Code:

(require 'project)
(require 'subr-x)
(require 'transient)

;; 中文说明：vterm 延迟加载以避免普通启动载入原生模块；提前声明其 API，
;; 让字节编译知道这些函数会在调用时由 `require' 提供。
(declare-function vterm "vterm" (&optional arg))
(declare-function vterm-send-string "vterm" (string &optional paste-p))
(declare-function vterm-send-return "vterm" ())
(defvar vterm-kill-buffer-on-exit)
(defvar vterm-timer-delay)
(defvar vterm-exit-functions)

(defgroup diffnav-emacs nil
  "在 Emacs 中调用 diffnav。"
  :group 'tools
  :prefix "diffnav-emacs-")

(defcustom diffnav-emacs-executable "diffnav"
  "diffnav 可执行文件的名称或绝对路径。"
  :type 'string
  :group 'diffnav-emacs)

(defcustom diffnav-emacs-extra-arguments nil
  "每次启动 diffnav 时追加的命令行参数。

例如设置为包含 --unified 的列表，可默认使用统一 diff 视图。"
  :type '(repeat string)
  :group 'diffnav-emacs)

(defcustom diffnav-emacs-terminal-function #'diffnav-emacs-vterm
  "用于启动 diffnav TUI 的函数。

函数接收两个参数：完整的 shell COMMAND 和工作目录 DIRECTORY。默认使用
`vterm'；也可替换为自己的终端启动函数。"
  :type 'function
  :group 'diffnav-emacs)

(defcustom diffnav-emacs-vterm-timer-delay 0.15
  "Diffnav 专用 vterm 的最小重绘间隔，单位为秒。

较大的值会把密集终端输出合并为更少的重绘，从而降低界面晃动；设为 nil
可关闭延迟重绘。此项仅作用于 Diffnav Buffer，不改变普通 vterm。"
  :type '(choice number (const :tag "不延迟重绘" nil))
  :group 'diffnav-emacs)

(defcustom diffnav-emacs-default-branch-candidates '("main" "master")
  "未配置远程默认分支时，用于识别默认分支的本地候选名称。"
  :type '(repeat string)
  :group 'diffnav-emacs)

(defvar-local diffnav-emacs--origin-window nil
  "打开当前 Diffnav vterm 前所选中的窗口。")

(defvar-local diffnav-emacs--origin-buffer nil
  "打开当前 Diffnav vterm 前该窗口显示的 Buffer。")

(defun diffnav-emacs-project-root (&optional directory)
  "返回 DIRECTORY 所在项目根；不在项目时返回 DIRECTORY 本身。"
  (let ((default-directory (file-name-as-directory
                            (expand-file-name (or directory default-directory)))))
    (if-let ((project (project-current nil default-directory)))
        (project-root project)
      default-directory)))

(defun diffnav-emacs--shell-command (arguments)
  "将 ARGUMENTS 转换为经 shell 安全转义的命令字符串。"
  (mapconcat #'shell-quote-argument arguments " "))

(defun diffnav-emacs-build-command (git-arguments)
  "构造将 GIT-ARGUMENTS 的输出管道传给 diffnav 的命令。"
  (format "%s | %s"
          (diffnav-emacs--shell-command git-arguments)
          (diffnav-emacs--shell-command
           (cons diffnav-emacs-executable diffnav-emacs-extra-arguments))))

(defun diffnav-emacs-build-watch-command (git-arguments)
  "构造监看 GIT-ARGUMENTS 输出的 diffnav 命令。"
  (string-join
   (append (list (shell-quote-argument diffnav-emacs-executable))
           (mapcar #'shell-quote-argument diffnav-emacs-extra-arguments)
           (list "--watch" "--watch-cmd"
                 (shell-quote-argument
                  (diffnav-emacs--shell-command git-arguments))))
   " "))

(defconst diffnav-emacs--unmerged-status-codes
  '("DD" "AU" "UD" "UA" "DU" "AA" "UU")
  "Git porcelain v1 中表示未合并冲突的 XY 状态组合。")

(defun diffnav-emacs-parse-file-status (porcelain-output)
  "将单个文件的 Git PORCELAIN-OUTPUT 映射为 Diffnav 状态列表。"
  (if (string-empty-p porcelain-output)
      '(committed)
    (let ((status (substring porcelain-output 0 (min 2 (length porcelain-output)))))
      (cond
       ((string= status "??") '(untracked))
       ((member status diffnav-emacs--unmerged-status-codes) '(conflicted))
       ((string= status "!!") '(ignored))
       (t
        ;; 中文说明：XY 的 X 表示暂存区、Y 表示工作区；MM 等组合状态需要
        ;; 同时保留两个入口，分别查看 Index 与未暂存改动。
        (delq nil (list (unless (eq (aref status 0) ?\s) 'staged)
                         (unless (eq (aref status 1) ?\s) 'modified))))))))

(defun diffnav-emacs-file-state-git-arguments (state relative-file)
  "返回 STATE 下浏览 RELATIVE-FILE 所需的 Git 参数列表。"
  (pcase state
    ('untracked
     ;; `--no-index' 将未跟踪文件与空文件比较，使 diffnav 也能显示新文件内容。
     (list "git" "diff" "--no-index" "--" "/dev/null" relative-file))
    ('modified (list "git" "diff" "--" relative-file))
    ('staged (list "git" "diff" "--cached" "--" relative-file))
    ;; `--root' 兼容仓库的首个提交，始终显示 HEAD 中该文件的提交差异。
    ('committed (list "git" "show" "--format=" "--root" "HEAD" "--" relative-file))
    ;; Git combined diff 专门表达合并/变基尚未解决的冲突块。
    ('conflicted (list "git" "diff" "--cc" "--" relative-file))
    (_ (user-error "Diffnav 不支持文件状态：%S" state))))

(defun diffnav-emacs-revision-git-arguments (comparison &optional default-branch)
  "返回预设 COMPARISON 所需的 Git 参数，不要求用户输入 revision。

DEFAULT-BRANCH 仅在 COMPARISON 为 `default-branch' 时使用。"
  (pcase comparison
    ('default-branch
     (list "git" "diff" (concat default-branch "...HEAD")))
    ;; `--root' 让仓库首个提交也能正常显示，无需依赖不存在的 HEAD^。
    ('last-commit (list "git" "show" "--format=" "--root" "HEAD"))
    ;; HEAD 同时覆盖暂存与未暂存内容，直观表示“当前提交之后的全部改动”。
    ('head-worktree (list "git" "diff" "HEAD"))
    (_ (user-error "Diffnav 不支持提交比较类型：%S" comparison))))

(defun diffnav-emacs-default-branch (&optional directory)
  "自动识别 DIRECTORY 所在 Git 仓库的默认分支。

优先使用 origin/HEAD，再回退到 `diffnav-emacs-default-branch-candidates'。
找不到时明确提示配置远程默认分支，而不弹出 revision 输入框。"
  (let ((default-directory (diffnav-emacs-project-root directory)))
    (or
     (with-temp-buffer
       (when (zerop (process-file "git" nil t nil "symbolic-ref" "--quiet"
                                  "--short" "refs/remotes/origin/HEAD"))
         (let ((remote-branch (string-trim (buffer-string))))
           (and (not (string-empty-p remote-branch))
                (string-remove-prefix "origin/" remote-branch)))))
     (catch 'found
       (dolist (candidate diffnav-emacs-default-branch-candidates)
         (when (zerop (process-file "git" nil nil nil "rev-parse" "--verify"
                                    "--quiet" candidate))
           (throw 'found candidate))))
     (user-error "无法识别默认分支；请配置 origin/HEAD 或创建 main/master 分支"))))

(defun diffnav-emacs--run-revision-comparison (comparison)
  "在当前项目中执行预设 COMPARISON 的 Diffnav 提交比较。"
  (let ((root (diffnav-emacs-project-root)))
    (diffnav-emacs-run
     (diffnav-emacs-revision-git-arguments
      comparison
      (and (eq comparison 'default-branch)
           (diffnav-emacs-default-branch root)))
     root)))

(defun diffnav-emacs--current-file-context ()
  "返回当前文件的项目根、相对路径与 Git 状态。

返回值为 (ROOT RELATIVE-FILE STATES)，STATES 由
`diffnav-emacs-parse-file-status' 生成。"
  (unless buffer-file-name
    (user-error "当前 Buffer 未访问文件，无法判断 Git 状态"))
  (let* ((root (diffnav-emacs-project-root))
         (relative-file (file-relative-name buffer-file-name root))
         (default-directory root)
         (status-output (with-temp-buffer
                          (let ((exit-code
                                 (process-file "git" nil t nil "status"
                                               "--porcelain=v1" "-z"
                                               "--untracked-files=all" "--"
                                               relative-file)))
                            (unless (zerop exit-code)
                              (user-error "当前目录不是可用的 Git 仓库"))
                            (buffer-string)))))
    (list root relative-file (diffnav-emacs-parse-file-status status-output))))

(defun diffnav-emacs--current-file-has-state-p (state)
  "判断当前访问文件是否处于 STATE；仅供 Transient 条件显示使用。"
  (condition-case nil
      (memq state (nth 2 (diffnav-emacs--current-file-context)))
    (error nil)))

(defun diffnav-emacs--run-current-file-state (state)
  "用 diffnav 显示当前文件处于 STATE 的对应差异。"
  (pcase-let ((`(,root ,relative-file ,states)
               (diffnav-emacs--current-file-context)))
    (unless (memq state states)
      (user-error "当前文件不是 %s 状态"
                  (pcase state
                    ('untracked "未跟踪") ('modified "未暂存")
                    ('staged "已暂存") ('committed "已提交")
                    ('conflicted "冲突") (_ "指定"))))
    (diffnav-emacs-run
     (diffnav-emacs-file-state-git-arguments state relative-file) root)))

(defun diffnav-emacs--restore-origin (buffer _event)
  "在 Diffnav vterm BUFFER 退出时恢复来源视图并销毁终端 Buffer。"
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (let ((origin-window diffnav-emacs--origin-window)
            (origin-buffer diffnav-emacs--origin-buffer))
        (when (and (window-live-p origin-window)
                   (buffer-live-p origin-buffer))
          ;; 中文说明：只有正在查看该 Diffnav 的情况下才转回来源窗口，避免
          ;; 用户已经切换到其他窗口时被异步退出事件强行抢走焦点。
          (when (eq (window-buffer (selected-window)) buffer)
            (select-window origin-window))
          (set-window-buffer origin-window origin-buffer)))
      ;; 中文说明：不依赖 vterm 全局 sentinel 的后续清理判断；diffnav 的 q
      ;; 已使其进程退出，此处明确销毁专用 Buffer，避免隐藏的终端残留。
      (kill-buffer buffer))))

(defun diffnav-emacs--vterm-exec-command (command)
  "将完整 COMMAND 包装为会在结束后退出的 vterm 启动命令。

COMMAND 常含有 `git diff | diffnav' 管道，必须由同一个被 `exec' 替换的
子 shell 执行；否则 `exec' 只会替换管道左侧的 git，diffnav 按 q 后 vterm
仍会回到原始 shell 提示符。"
  ;; 中文说明：shell-quote-argument 保持已有管道及参数语义，同时避免命令中的
  ;; 空格或特殊字符被 vterm 的初始 shell 重新解释。
  (format "exec /bin/sh -c %s" (shell-quote-argument command)))

(defun diffnav-emacs-vterm (command directory)
  "在 DIRECTORY 的 vterm 中以独立进程运行 COMMAND。

使用 `exec' 替换 vterm 初始 shell，并将整个管道置于子 shell：diffnav 按 q
退出后，终端进程随之结束，并由 `vterm-kill-buffer-on-exit' 自动清理 Buffer。"
  (unless (require 'vterm nil t)
    (user-error "vterm 不可用，无法流畅运行 diffnav"))
  (let ((default-directory (file-name-as-directory directory))
        ;; 中文说明：创建时即为 t，确保 vterm 安装退出 sentinel；仅在创建后
        ;; 设置局部变量已来不及让上游为该进程注册 sentinel。
        (vterm-kill-buffer-on-exit t)
        (origin-window (selected-window))
        (origin-buffer (current-buffer))
        (buffer (vterm (generate-new-buffer-name "*diffnav*"))))
    ;; 中文说明：只为 Diffnav Buffer 启用退出即关闭，不影响用户普通 vterm。
    (with-current-buffer buffer
      (setq-local vterm-kill-buffer-on-exit t
                  ;; 合并连续输出的绘制，降低 diffnav 在文件/行间移动时的闪动。
                  vterm-timer-delay diffnav-emacs-vterm-timer-delay
                  diffnav-emacs--origin-window origin-window
                  diffnav-emacs--origin-buffer origin-buffer)
      ;; vterm 先运行此钩子、后 kill Buffer，因此可稳定还原来源视图。
      (add-hook 'vterm-exit-functions #'diffnav-emacs--restore-origin nil t))
    ;; 中文说明：必须 exec 整个管道，而非仅 exec 管道左边的 git；这样 q 才会
    ;; 令 vterm 进程结束，退出钩子才能杀掉专用 Buffer 并回到来源 Buffer。
    (vterm-send-string (diffnav-emacs--vterm-exec-command command))
    (vterm-send-return)
    buffer))

(defun diffnav-emacs-run (git-arguments &optional directory)
  "在 DIRECTORY 中将 GIT-ARGUMENTS 的 diff 交给 diffnav 浏览。"
  (let ((directory (diffnav-emacs-project-root directory)))
    (unless (executable-find diffnav-emacs-executable)
      (user-error "找不到 diffnav；请安装它或设置 diffnav-emacs-executable"))
    (funcall diffnav-emacs-terminal-function
             (diffnav-emacs-build-command git-arguments)
             directory)))

(defun diffnav-emacs-run-watch (git-arguments &optional directory)
  "在 DIRECTORY 中用 diffnav 监看 GIT-ARGUMENTS 的变化。"
  (let ((directory (diffnav-emacs-project-root directory)))
    (unless (executable-find diffnav-emacs-executable)
      (user-error "找不到 diffnav；请安装它或设置 diffnav-emacs-executable"))
    (funcall diffnav-emacs-terminal-function
             (diffnav-emacs-build-watch-command git-arguments)
             directory)))

;;;###autoload
(defun diffnav-emacs-working-tree ()
  "用 diffnav 浏览当前项目未暂存的改动。"
  (interactive)
  (diffnav-emacs-run '("git" "diff")))

;;;###autoload
(defun diffnav-emacs-staged ()
  "用 diffnav 浏览当前项目已暂存的改动。"
  (interactive)
  (diffnav-emacs-run '("git" "diff" "--cached")))

;;;###autoload
(defun diffnav-emacs-current-file-untracked ()
  "用 diffnav 将当前未跟踪文件与空文件比较。"
  (interactive)
  (diffnav-emacs--run-current-file-state 'untracked))

;;;###autoload
(defun diffnav-emacs-current-file-modified ()
  "用 diffnav 浏览当前文件未暂存的改动。"
  (interactive)
  (diffnav-emacs--run-current-file-state 'modified))

;;;###autoload
(defun diffnav-emacs-current-file-staged ()
  "用 diffnav 浏览当前文件已暂存的改动。"
  (interactive)
  (diffnav-emacs--run-current-file-state 'staged))

;;;###autoload
(defun diffnav-emacs-current-file-committed ()
  "用 diffnav 浏览当前文件在 HEAD 提交中的差异。"
  (interactive)
  (diffnav-emacs--run-current-file-state 'committed))

;;;###autoload
(defun diffnav-emacs-current-file-conflicted ()
  "用 diffnav 浏览当前冲突文件的 Git combined diff。"
  (interactive)
  (diffnav-emacs--run-current-file-state 'conflicted))

;;;###autoload
(defun diffnav-emacs-watch-working-tree ()
  "用 diffnav 持续监看当前项目未暂存的改动。"
  (interactive)
  (diffnav-emacs-run-watch '("git" "diff")))

;;;###autoload
(defun diffnav-emacs-compare-default-branch ()
  "显示当前分支相对默认分支新增的提交差异。"
  (interactive)
  (diffnav-emacs--run-revision-comparison 'default-branch))

;;;###autoload
(defun diffnav-emacs-show-last-commit ()
  "显示最近一次提交本身包含的差异。"
  (interactive)
  (diffnav-emacs--run-revision-comparison 'last-commit))

;;;###autoload
(defun diffnav-emacs-compare-head-worktree ()
  "显示当前提交之后的全部改动（已暂存加未暂存）。"
  (interactive)
  (diffnav-emacs--run-revision-comparison 'head-worktree))

;;;###autoload
(transient-define-prefix diffnav-emacs-revision-menu ()
  "打开无需输入 revision 的 Diffnav 提交比较菜单。"
  ["提交版本比较"
   ["预设比较"
    ("d" "当前分支相对默认分支" diffnav-emacs-compare-default-branch)
    ("l" "最近一次提交的改动" diffnav-emacs-show-last-commit)
    ("w" "当前提交后的全部改动" diffnav-emacs-compare-head-worktree)]])

;;;###autoload
(transient-define-prefix diffnav-emacs-current-file-menu ()
  "按当前文件 Git 状态打开对应的 Diffnav 差异浏览操作。"
  ["当前文件状态"
   ["仅显示适用于当前文件的操作"
    ("u" "未跟踪：与空文件比较" diffnav-emacs-current-file-untracked
     :if (lambda () (diffnav-emacs--current-file-has-state-p 'untracked)))
    ("m" "未暂存：工作区差异" diffnav-emacs-current-file-modified
     :if (lambda () (diffnav-emacs--current-file-has-state-p 'modified)))
    ("s" "已暂存：Index 差异" diffnav-emacs-current-file-staged
     :if (lambda () (diffnav-emacs--current-file-has-state-p 'staged)))
    ("h" "已提交：HEAD 差异" diffnav-emacs-current-file-committed
     :if (lambda () (diffnav-emacs--current-file-has-state-p 'committed)))
    ("c" "冲突：Combined diff" diffnav-emacs-current-file-conflicted
     :if (lambda () (diffnav-emacs--current-file-has-state-p 'conflicted)))]])

;;;###autoload
(transient-define-prefix diffnav-emacs-menu ()
  "打开 diffnav 的 Git 改动浏览菜单。"
  ["Diffnav"
   ["查看改动"
    ("v" "工作区改动" diffnav-emacs-working-tree)
    ("V" "暂存区改动" diffnav-emacs-staged)
    ("F" "当前文件状态" diffnav-emacs-current-file-menu)
    ;; 中文说明：版本比较改为固定且可读的语义选项，不再要求输入 main/HEAD。
    ("b" "提交版本比较" diffnav-emacs-revision-menu)]
   ["持续查看"
    ("w" "监看工作区改动" diffnav-emacs-watch-working-tree)]])

(provide 'diffnav-emacs)

;;; diffnav-emacs.el ends here
