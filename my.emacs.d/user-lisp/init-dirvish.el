;;; init-dirvish.el --- Dirvish 文件管理器配置 -*- lexical-binding: t; -*-

;; Ranger 的配置仍保留在 init-ranger.el 中，但不再由启动流程加载。
;; 这里显式调用 Dirvish，因此不会改变原生 Dired 的打开行为。

(require 'dired)


(defvar-local my/dirvish-preview-enabled nil
  "Non-nil when the current Dirvish directory updates previews automatically.")

(defun my/dirvish--put-property (property value)
  "Set PROPERTY to VALUE in the current Dirvish buffer's local properties."
  (let ((entry (assq property dirvish--props)))
    (if entry
        (setcdr entry value)
      (push (cons property value) dirvish--props)))
  value)

(defun my/dirvish-disable-auto-preview (&rest _)
  "Disable preview dispatchers for a newly entered Dirvish directory.
The preview pane remains part of the layout but no file-reading or external
thumbnail process starts while the cursor moves."
  (setq-local my/dirvish-preview-enabled nil)
  (my/dirvish--put-property :preview-dps nil)
  nil)

(defun my/dirvish-toggle-preview ()
  "Toggle file preview for the current Dirvish directory with `P'."
  (interactive)
  (let ((session (or (dirvish-curr) (user-error "当前不在 Dirvish 中"))))
    (if my/dirvish-preview-enabled
        (progn
          (setq-local my/dirvish-preview-enabled nil)
          (my/dirvish--put-property :preview-dps nil)
          (message "Dirvish 文件预览已关闭"))
      (setq-local my/dirvish-preview-enabled t)
      (my/dirvish--put-property :preview-dps
                                (dirvish--preview-dps-validate))
      (when-let ((file (dired-get-filename nil t)))
        (dirvish--preview-update session file))
      (message "Dirvish 文件预览已开启"))))

(defun my/dirvish-open (&optional path)
  "使用 Dirvish 打开 PATH；省略 PATH 时打开当前目录。"
  (interactive)
  (require 'dirvish)
  (let ((path (or path default-directory)))
    ;; Dirvish 2.3.0 的首次打开分支漏执行了目录进入步骤。已有会话的
    ;; 路径是正常的；首次会话在此显式完成“创建 → 建立 Dired 根缓冲区 →
    ;; 构建父目录栏/预览栏”的三个步骤。
    (if (or (dirvish-curr) (dirvish--get-session 'type 'default))
        (dirvish path)
      (let* ((session (dirvish--new :curr-layout dirvish-default-layout))
             (buffer (dirvish-dired-noselect-a
                      (symbol-function 'dired-noselect) path)))
        (switch-to-buffer buffer)
        (dirvish--build-layout session)))))

(defun my/dirvish-isolate-from-native-dired (&rest _)
  "移除原生 Dired 的局部装饰，交给 Dirvish 渲染自身界面。"
  (when (and (fboundp 'my/dired-ui-mode)
             (boundp 'my/dired-ui-mode)
             (symbol-value 'my/dired-ui-mode))
    (my/dired-ui-mode -1))
  (when (bound-and-true-p nerd-icons-dired-mode)
    (nerd-icons-dired-mode -1))
  (hl-line-mode 1)
  (setq-local cursor-type 'box)
  ;; `dirvish-find-entry-hook' 的非空返回值会截断目录/文件进入流程。
  nil)

(use-package dirvish
  :straight (:host github :repo "alexluigit/dirvish")
  :commands (dirvish dirvish-dwim dirvish-dispatch dirvish-quit)
  :custom
  ;; 一个父目录栏、宽主栏和预览栏；长文件名不会被多个窄栏挤压。
  (dirvish-default-layout '(1 0.18 0.40))
  ;; 详情、Git 状态、提交信息和图标均直接显示在列表中。
  (dirvish-attributes
   '(vc-state subtree-state nerd-icons collapse git-msg file-modes file-time file-size))
  (dirvish-hide-details nil)
  (dirvish-hide-cursor nil)
  ;; 大目录改由 fd 异步扫描；文本预览只保留前 5 MiB，避免卡住 Emacs。
  (dirvish-large-directory-threshold 20000)
  (dirvish-preview-large-file-threshold (* 5 1024 1024))
  (dirvish-preview-buffers-max-count 5)
  ;; Homebrew 没有 epub-thumbnailer；不注册该分发器，避免选择 EPUB 时出现
  ;; 缺少外部程序的错误。其余已注册预览器的依赖均已安装。
  (dirvish-preview-dispatchers '(video image gif audio archive font pdf))
  (dirvish-reuse-session 'quit)
  :config
  ;; Dirvish 的完整会话通过对 Dired 创建路径的集成来初始化；不开启时
  ;; `dirvish' 只会落入原生 Dired，因而没有父目录栏、预览或 Git 属性。
  (dirvish-override-dired-mode 1)
  (add-hook 'dirvish-find-entry-hook #'my/dirvish-isolate-from-native-dired)
  (add-hook 'dirvish-find-entry-hook #'my/dirvish-disable-auto-preview)
  ;; 当前项始终可见，并与现有深色主题保持足够、但不刺眼的区分度。
  (set-face-attribute 'dirvish-hl-line nil :background "#343a5d" :extend t)
  (set-face-attribute 'dirvish-hl-line-inactive nil :background "#2c3150" :extend t)
  (require 'dirvish-extras)
  (require 'transient)
  ;; 该宏在启动期字节编译用户配置时尚不可见；延迟求值可确保它在
  ;; `transient' 已加载后展开，避免把菜单名当作普通变量求值。
  (eval
   '(transient-define-prefix my/dirvish-menu ()
      "Dirvish 的完整中文帮助与高频操作菜单。"
      [["导航"
      ("j" "下一项" dired-next-line :transient t)
      ("k" "上一项" dired-previous-line :transient t)
      ("h" "上级目录" dired-up-directory)
      ("l" "打开当前项" dired-find-file)
      ("g" "刷新目录" revert-buffer)]
     ["文件与标记"
      ("m" "标记/取消标记" dired-mark)
      ("u" "取消标记" dired-unmark)
      ("C" "复制标记项" dired-do-copy)
      ("R" "重命名/移动标记项" dired-do-rename)
      ("D" "删除标记项" dired-do-delete)
      ("+" "新建目录" dired-create-directory)]
     ["显示、预览与排序"
      ("P" "开关文件预览" my/dirvish-toggle-preview)
      ("z" "显示/隐藏详情" dired-hide-details-mode)
      ("L" "切换栏布局" dirvish-layout-switch)
      ("s" "排序菜单" dirvish-quicksort)
      ("i" "文件详情" dirvish-file-info-menu)
      ("U" "界面设置" dirvish-setup-menu)]
     ["Git、搜索与更多"
      ("v" "Git 操作" dirvish-vc-menu)
      ("/" "当前目录 fd 搜索" dirvish-fd)
      ("a" "快捷目录" dirvish-quick-access)
      ("M" "标记管理" dirvish-mark-menu)
      ("?" "官方全部命令" dirvish-dispatch)
      ("q" "退出 Dirvish" dirvish-quit)]]))
  (with-eval-after-load 'general
    (general-define-key
     :keymaps 'dirvish-mode-map
     "h" '("上级目录" . dired-up-directory)
     "l" '("打开当前项" . dired-find-file)
     "j" '("下一项" . dired-next-line)
     "k" '("上一项" . dired-previous-line)
     "g" '("刷新目录" . revert-buffer)
     "P" '("开关文件预览" . my/dirvish-toggle-preview)
     "?" '("Dirvish 完整帮助" . my/dirvish-menu)
     "a" '("快捷目录" . dirvish-quick-access)
     "s" '("排序菜单" . dirvish-quicksort)
     "i" '("文件详情" . dirvish-file-info-menu)
     "q" '("退出 Dirvish" . dirvish-quit))
    ;; 保持旧 Ranger 的入口位置，但实际打开 Dirvish。
    (general-define-key
     "C-c r" '("Dirvish 文件管理器" . my/dirvish-open))
    (my-leader-def
      "d r" '("Dirvish 文件管理器" . my/dirvish-open))))

(provide 'init-dirvish)
;;; init-dirvish.el ends here
