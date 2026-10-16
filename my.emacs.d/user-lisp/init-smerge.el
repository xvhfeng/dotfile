;;; init-smerge.el --- 合并冲突处理配置 -*- lexical-binding: t; -*-

;; 中文说明：Smerge 是 Emacs 内置的合并冲突处理器。本模块只增加自动识别、
;; 可发现的快捷键与 Transient 菜单，不覆盖它原有的 `C-c ^' 操作组。

(require 'smerge-mode)
(require 'transient)

;; 中文说明：快捷键定义器由较早加载的 init-keybindings 提供；声明它可避免
;; 字节编译时把正常的跨模块调用误报为未定义函数。
(declare-function my-leader-def "init-keybindings" (&rest arguments))

(defun my/smerge-conflict-buffer-p ()
  "判断当前 Buffer 是否包含 Git 等工具写入的冲突标记。"
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      ;; 中文说明：同时要求开始与结束标记，避免代码注释里的单个示例文本
      ;; 意外开启 minor mode。
      (and (re-search-forward "^<<<<<<< .+$" nil t)
           (re-search-forward "^>>>>>>> .+$" nil t)))))

(defun my/smerge-enable-if-conflicted ()
  "当当前文件确有冲突标记时启用 `smerge-mode'。"
  (when (and (not smerge-mode)
             (my/smerge-conflict-buffer-p))
    (smerge-mode 1)))

;; 中文说明：打开、重载和 Git 操作后刷新到磁盘的文件均会检查冲突；普通文件
;; 不会开启额外 minor mode，因此现有语言模式和插件行为保持不变。
(add-hook 'find-file-hook #'my/smerge-enable-if-conflicted)
(add-hook 'after-revert-hook #'my/smerge-enable-if-conflicted)

(defun my/smerge--active-p ()
  "供 Transient 判断当前 Buffer 是否处于可操作的冲突状态。"
  smerge-mode)

(transient-define-prefix my/smerge-menu ()
  "打开当前文件的合并冲突处理菜单。"
  ["合并冲突（普通文件中的操作会保持禁用）"
   ["跳转"
    ("n" "下一处冲突" smerge-next :if my/smerge--active-p)
    ("p" "上一处冲突" smerge-prev :if my/smerge--active-p)]
   ["保留版本"
    ("u" "保留上方版本" smerge-keep-upper :if my/smerge--active-p)
    ("l" "保留下方版本" smerge-keep-lower :if my/smerge--active-p)
    ("b" "保留基础版本" smerge-keep-base :if my/smerge--active-p)
    ("RET" "保留光标所在版本" smerge-keep-current :if my/smerge--active-p)
    ("a" "保留全部版本" smerge-keep-all :if my/smerge--active-p)]
   ["比较与解决"
    ("=" "比较冲突版本" smerge-diff-upper-lower :if my/smerge--active-p)
    ("r" "尝试自动解决" smerge-resolve :if my/smerge--active-p)
    ("R" "细化差异高亮" smerge-refine :if my/smerge--active-p)
    ("e" "使用 Ediff 解决" smerge-ediff :if my/smerge--active-p)
    ("c" "合并下一处冲突" smerge-combine-with-next :if my/smerge--active-p)]])

;; 中文说明：`C-c c m' 是统一的发现入口；Smerge 原生 `C-c ^' 保持可用，
;; 熟悉原生快捷键时无需改变习惯。
(with-eval-after-load 'general
  (my-leader-def
    "c m" '("合并冲突菜单" . my/smerge-menu)))

(with-eval-after-load 'which-key
  ;; 中文说明：为内置 `C-c ^' 前缀提供中文提示，降低记忆原生命令的成本。
  (which-key-add-keymap-based-replacements
   smerge-mode-map "C-c ^" "合并冲突操作"))

(provide 'init-smerge)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 打开含 <<<<<<< / ======= / >>>>>>> 标记的文件时，Smerge 会自动启用。
;; - `C-c c m' 或个人工作台“合并冲突”打开本模块的 Transient 操作菜单。
;; - 原生 `C-c ^ n/p/u/l/a/r/E' 仍分别用于跳转、保留版本、自动解决与 Ediff。
;; - 所有保留/解决操作只作用于光标所在冲突块；完成后正常保存并 Git add 即可。
;;; init-smerge.el ends here
