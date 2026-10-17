;;; init-dirvish.el --- Dirvish 文件管理器配置 -*- lexical-binding: t; -*-

;; Ranger 的配置仍保留在 init-ranger.el 中，但不再由启动流程加载。
;; 这里显式调用 Dirvish，因此不会改变原生 Dired 的打开行为。

(require 'dired)

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
  ;; 当前项始终可见，并与现有深色主题保持足够、但不刺眼的区分度。
  (set-face-attribute 'dirvish-hl-line nil :background "#343a5d" :extend t)
  (set-face-attribute 'dirvish-hl-line-inactive nil :background "#2c3150" :extend t)
  (with-eval-after-load 'general
    (general-define-key
     :keymaps 'dirvish-mode-map
     "h" '("上级目录" . dired-up-directory)
     "l" '("打开当前项" . dired-find-file)
     "j" '("下一项" . dired-next-line)
     "k" '("上一项" . dired-previous-line)
     "g" '("刷新目录" . dirvish-revert)
     "?" '("Dirvish 命令帮助" . dirvish-dispatch)
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
