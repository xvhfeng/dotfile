;;; init-easykill.el --- Easy Kill integration -*- lexical-binding: t; -*-

(autoload 'easy-kill-region "easy-kill" nil t)
(autoload 'easy-dup-after "easy-kill" nil t)
(autoload 'easy-dup-before "easy-kill" nil t)
;; 1.5. Easy Kill：按对象选择、复制或标记文本
;; ============================================================================
;; 中文说明：M-3 打开本配置的 Easy Kill Hydra，C-w 保留给窗口 Hydra。
;; 在单层菜单中开始对象选择后，y/RET/M-w 确认复制候选，k 剪切候选。
(use-package easy-kill
  :straight (:host github
             :repo "leoliu/easy-kill"
             :commit "98cbae5d8c378ad14d612d7c88a78484c49a80b8")
  :commands (easy-kill easy-mark easy-dup easy-dup-after easy-dup-before easy-kill-help
                       easy-kill-abort easy-kill-region))

;; Easy Kill 尚未加载时也让菜单命令作为可交互 autoload 可见。
(autoload 'easy-kill-region "easy-kill" nil t)

(defun easy-kill-on-word (n)
  "选择单词；当前位置没有单词时选择一个字符，兼容空格和符号。

N 保持 Easy Kill 的对象选择接口。"
  (let ((character (char-after)))
    (if (and character (eq (char-syntax character) ?w))
      ;; 中文说明：正常单词仍完全交给 Easy Kill 原流程，保留数字前缀、扩展与
      ;; 收缩候选等行为；`t' 防止再次调用本兼容 handler。
      (easy-kill-thing 'word n t)
      (let* ((point (point))
             ;; 中文说明：当前字符不是 word 时，严格选择该字符；符号、空格和
             ;; 标点不会按语法表的 symbol 规则扩展成整行。位于 Buffer 末尾则退回前一字符。
             (bounds (cond
                      (character (cons point (1+ point)))
                      ((> point (point-min)) (cons (1- point) point)))))
        (if bounds
            (easy-kill-adjust-candidate 'word (car bounds) (cdr bounds))
          (easy-kill-echo "当前 Buffer 没有可选择的字符"))))))

(defun my/easy-kill-active-p ()
  "返回非 nil 表示当前 Buffer 正处于 Easy Kill 临时选择状态。"
  (and (boundp 'easy-kill-candidate)
       (overlayp easy-kill-candidate)
       (overlay-buffer easy-kill-candidate)))

(defun my/easy-kill-select ()
  "按当前菜单键直接启动 Easy Kill 并选择对应对象。"
  (interactive)
  (let ((thing (pcase last-command-event
                 (?w 'word) (?s 'sexp) (?l 'list) (?f 'filename)
                 (?d 'defun) (?e 'line))))
    (unless thing
      (user-error "未定义的 Easy Kill 对象键"))
    (unless (my/easy-kill-active-p)
      (easy-kill))
    (easy-kill-thing thing)))

(defun my/easy-kill-copy-and-quit ()
  "复制当前候选到 kill-ring，并关闭 Easy Kill 菜单。"
  (interactive)
  (unless (my/easy-kill-active-p)
    (user-error "请先选择对象或标记选区"))
  (pcase (easy-kill-get bounds)
    (`(,beg . ,end) (kill-ring-save beg end)))
  (my/easy-kill-cancel))

(defun my/easy-kill-show-kill-ring ()
  "在临时 Buffer 中查看当前 kill ring。"
  (interactive)
  (with-output-to-temp-buffer "*Kill Ring*"
    (princ "Kill Ring\n=========\n\n")
    (if kill-ring
        (cl-loop for item in kill-ring
                 for index from 1
                 do (princ (format "%d. %s\n\n" index item)))
      (princ "(空)\n"))))

;; 让 Easy Kill 的临时 keymap 在复制后销毁候选并运行退出钩子。
(put 'my/easy-kill-copy-and-quit 'easy-kill-exit t)

(defun my/easy-kill-cancel ()
  "无条件退出 Easy Kill、Hydra 与普通 Emacs 标记状态。"
  (interactive)
  (when (my/easy-kill-active-p)
    (easy-kill-abort easy-kill-region))
  (deactivate-mark))

(defun my/easy-mark-start ()
  "进入统一的 Easy Mark 状态。"
  (interactive)
  (unless (my/easy-kill-active-p)
    (easy-mark)))

(defun my/easy-mark-expand ()
  "在 Easy Mark 状态中扩展候选。"
  (interactive)
  (unless (my/easy-kill-active-p)
    (user-error "请先按 m 开始标记"))
  (easy-kill-expand))

(defun my/easy-mark-shrink ()
  "在 Easy Mark 状态中收缩候选。"
  (interactive)
  (unless (my/easy-kill-active-p)
    (user-error "请先按 m 开始标记"))
  (easy-kill-shrink))

(defun my/easy-mark-cycle ()
  "在 Easy Mark 状态中循环候选类型。"
  (interactive)
  (unless (my/easy-kill-active-p)
    (user-error "请先按 m 开始标记"))
  (easy-kill-cycle))

(defun my/easy-kill-remind-delete-key ()
  "提示 Easy Kill 的候选剪切键，避免 C-w 与窗口菜单冲突。"
  (interactive)
  (message "Easy Kill 中按 k 剪切当前候选；C-w 保留给窗口菜单"))

(with-eval-after-load 'easy-kill
  ;; 中文说明：C-w 已被全局窗口 Hydra 使用。Easy Kill 临时状态中
  ;; k 剪切候选、m 标记候选、q 取消；原组合键仍可使用。
  (define-key easy-kill-base-map (kbd "k") #'easy-kill-region)
  (define-key easy-kill-base-map (kbd "m") #'easy-kill-mark-region)
  (define-key easy-kill-base-map (kbd "q") #'easy-kill-abort)
  (define-key easy-kill-base-map (kbd "C-k") #'easy-kill-region)
  (define-key easy-kill-base-map (kbd "C-w") #'my/easy-kill-remind-delete-key)
  ;; RET/M-w/y 均复制候选到 kill-ring 并关闭单层菜单；普通编辑状态的 M-w
  ;; 仍打开 Easy Kill 菜单。
  (define-key easy-kill-base-map (kbd "RET") #'my/easy-kill-copy-and-quit)
  (define-key easy-kill-base-map (kbd "M-w") #'my/easy-kill-copy-and-quit)
  (define-key easy-kill-base-map (kbd "y") #'my/easy-kill-copy-and-quit)
  ;; Easy Mark 会接管临时 map；这些键必须也在其 base map 中。
  (define-key easy-kill-base-map (kbd "=") #'my/easy-mark-expand)
  (define-key easy-kill-base-map (kbd "-") #'my/easy-mark-shrink)
  (define-key easy-kill-base-map (kbd "SPC") #'my/easy-mark-cycle)
  ;; 临时选择状态中，M-3 重新显示 Hydra；ESC 则取消候选并退出。
  (define-key easy-kill-base-map (kbd "M-3") #'hydra-easy-kill-menu/body)
  (define-key easy-kill-base-map [escape] #'my/easy-kill-cancel))

(when nil
(transient-define-prefix my/easy-kill-menu ()
  "打开单层 Easy Kill 对象选择、复制与标记菜单。"
  :variable-pitch t
  :column-widths '(26 26 26)
  [["   开始操作"
    ("m" "开始 Easy Mark" my/easy-mark-start :transient t)
    ;; ("p" "Emacs 标记" my/toggle-mark-command :transient t)
    ;; ("C-n" "向下扩展标记" next-line :transient t)
    ;; ("C-p" "向上扩展标记" previous-line :transient t)
    ("]" "在选区后插入对象" my/easy-kill-insert-after :transient t)
    ("[" "在选区前插入对象" my/easy-kill-insert-before :transient t)]
   ["   选择对象"
    :pad-keys t
    ("w" "单词" my/easy-kill-select :transient t)
    ("s" "表达式" my/easy-kill-select :transient t)
    ("l" "列表" my/easy-kill-select :transient t)
    ("f" "文件名" my/easy-kill-select :transient t)
    ("d" "函数" my/easy-kill-select :transient t)
    ("e" "整行" my/easy-kill-select :transient t)
    ]
   ["   调整与完成"
    :pad-keys t
    ("=" "扩展候选" my/easy-mark-expand :transient t)
    ("-" "收缩候选" my/easy-mark-shrink :transient t)
    ("SPC" "循环对象类型" my/easy-mark-cycle :transient t)
    ;; ("@" "复制候选并退出" my/easy-kill-copy-and-quit)
    ("y" "复制到 kill-ring 并退出" my/easy-kill-copy-and-quit)
    ("RET" "复制候选并退出" my/easy-kill-copy-and-quit)
    ("k" "剪切候选并退出" easy-kill-region)
    ("<escape>" "取消选择" my/easy-kill-cancel)
    ("h" "查看 Kill Ring" consult-yank-from-kill-ring)
    ("?" "显示完整键位帮助" easy-kill-help :transient t)]])
  )

(use-package hydra
  :straight t
  :demand t
  :config
  (defhydra hydra-easy-kill-menu (:hint nil)
    "
                                      Easy Kill
================================================================================
开始操作                             选择对象                              调整与完成
--------------------------------------------------------------------------------
_m_ 开始 Easy Mark                   _w_ 选择单词                          _=_ 扩展候选
_]_ 复制当前对象到下方               _s_ 选择表达式                        _-_ 收缩候选
_[_ 复制当前对象到上方               _l_ 选择列表                          _SPC_ 循环对象类型
                                      _f_ 选择文件名                        _y_ 复制到 kill-ring 并退出
                                      _d_ 选择函数                          _RET_ 复制到 kill-ring 并退出
                                      _e_ 选择整行                          _k_ 剪切候选并退出
                                                                            _h_ 查看 Kill Ring
                                                                            _?_ 显示完整键位帮助
                                                                            _q_ / _ESC_ 退出菜单
"
    ("m" my/easy-mark-start)
    ("]" easy-dup-after)
    ("[" easy-dup-before)
    ("w" my/easy-kill-select)
    ("s" my/easy-kill-select)
    ("l" my/easy-kill-select)
    ("f" my/easy-kill-select)
    ("d" my/easy-kill-select)
    ("e" my/easy-kill-select)
    ("=" my/easy-mark-expand)
    ("-" my/easy-mark-shrink)
    ("SPC" my/easy-mark-cycle)
    ("y" my/easy-kill-copy-and-quit :exit t)
    ("RET" my/easy-kill-copy-and-quit :exit t)
    ("k" easy-kill-region :exit t)
    ("h" consult-yank-from-kill-ring)
    ("?" easy-kill-help)
    ("q" my/easy-kill-cancel :exit t)
    ("<escape>" my/easy-kill-cancel :exit t)))

;; 兼容工作台和旧配置入口；两者现在都直接打开 Hydra。
(defalias 'my/easy-kill-menu #'hydra-easy-kill-menu/body)
(defalias 'my/easy-kill-toggle #'hydra-easy-kill-menu/body)

;; M-3 直接打开 Easy Kill Hydra。
(keymap-global-set "M-3" #'hydra-easy-kill-menu/body)
(with-eval-after-load 'general
  (general-define-key "M-3" '("Easy Kill 菜单" . hydra-easy-kill-menu/body)))

(defvar my/easy-kill-toggle-override-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-3") #'hydra-easy-kill-menu/body)
    map)
  "保证 M-3 优先于局部 keymap 的 Easy Kill Hydra map。")
(defvar my/easy-kill-toggle-emulation-alist
  `((t . ,my/easy-kill-toggle-override-map)))
(add-to-list 'emulation-mode-map-alists 'my/easy-kill-toggle-emulation-alist)

;; ============================================================================

(with-eval-after-load 'general
  (my-leader-def "e k" '("Easy Kill 菜单" . my/easy-kill-menu)))

(provide 'init-easykill)
;;; init-easykill.el ends here
