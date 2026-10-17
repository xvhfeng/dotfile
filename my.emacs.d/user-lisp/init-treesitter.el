;;; init-treesitter.el --- Automatic Tree-sitter configuration -*- lexical-binding: t; -*-

(defun my/indent-block--content-line-p ()
  "Return non-nil when the current line contains non-whitespace text."
  (looking-at-p "^[ \t]*[^ \t\n]"))

(defun my/indent-block--anchor-line ()
  "Return the beginning of a content line representing the current position."
  (save-excursion
    (beginning-of-line)
    ;; 空行没有自身层级，优先使用上方最近的内容行，必要时再向下找。
    (unless (my/indent-block--content-line-p)
      (or (re-search-backward "^[ \t]*[^ \t\n]" nil t)
          (re-search-forward "^[ \t]*[^ \t\n]" nil t))
      (beginning-of-line))
    (unless (my/indent-block--content-line-p)
      (user-error "当前 Buffer 没有可选择的缩进块"))
    (point)))

(defun my/indent-block--parent-line (anchor)
  "Return nearest less-indented content line above ANCHOR, or nil."
  (save-excursion
    (goto-char anchor)
    (let ((indent (current-indentation)))
      (catch 'parent
        (while (not (bobp))
          (forward-line -1)
          (when (and (my/indent-block--content-line-p)
                     (< (current-indentation) indent))
            (throw 'parent (point))))))))

(defun my/indent-block--inner-bounds (header)
  "Return the content bounds immediately inside indentation HEADER."
  (save-excursion
    (goto-char header)
    (let ((indent (current-indentation)))
      (forward-line 1)
      (let ((beginning (point)))
        ;; 同级缩进通常是结束标签、下一个 sibling 或父块的后续内容；不包含它。
        (while (and (not (eobp))
                    (or (not (my/indent-block--content-line-p))
                        (> (current-indentation) indent)))
          (forward-line 1))
        (cons beginning (point))))))

(defun my/indent-block--select-bounds (bounds)
  "Activate the region represented by BOUNDS."
  (goto-char (car bounds))
  (push-mark (cdr bounds) nil t)
  (activate-mark))

(defun my/mark-indent-block ()
  "选择包含当前行的外层缩进块内部。
例如光标在 HTML table 行时，选择包围它的 div 内容，而不含 div 的首尾标签。"
  (interactive)
  (save-restriction
    (widen)
    (let* ((anchor (my/indent-block--anchor-line))
           (container (or (my/indent-block--parent-line anchor) anchor)))
      (my/indent-block--select-bounds
       (my/indent-block--inner-bounds container)))))

(defun my/mark-indent-block-inner ()
  "选择当前缩进块的内部内容。
例如光标在 HTML table 行时，仅选择 table 的内部区域，不含 table 首尾标签。"
  (interactive)
  (save-restriction
    (widen)
    (my/indent-block--select-bounds
     (my/indent-block--inner-bounds (my/indent-block--anchor-line)))))

;; ============================================================================
;; 1. 自定义语法包存放路径 (Custom Grammar Storage Directory)
;; ============================================================================
(use-package treesit
  :straight nil
  :demand t
  :init
  ;; 建立自定义运行目录变量
  (defvar my/treesit-grammar-dir
    ;; `treesit-install-language-grammar' 固定写入这个内置目录；与它对齐，
    ;; 才能让手动安装和 `treesit-auto' 安装的 grammar 都被自动发现。
    (expand-file-name "tree-sitter" user-emacs-directory)
    "Directory to store and load compiled tree-sitter grammars.")

  ;; 自动创建该目录 (如果尚不存在)
  (unless (file-exists-p my/treesit-grammar-dir)
    (make-directory my/treesit-grammar-dir t))

  ;; 告诉 Emacs 优先从此路径加载编译好的语法动态库 (.so / .dylib)
  (add-to-list 'treesit-extra-load-path my/treesit-grammar-dir)

  ;; 部分未启用 Tree-sitter 的 Emacs 构建不会预先声明该变量；保持配置可加载，
  ;; 之后安装/启用语法支持时仍可直接复用下面的来源清单。
  (defvar treesit-language-source-alist nil)

  ;; 集中登记 lang/ 中涉及语言的官方语法仓库；只登记来源，不在启动时强制编译。
  ;; 可通过 M-x treesit-install-language-grammar 或 treesit-auto 的提示按需安装。
  (dolist (source
           '((c . ("https://github.com/tree-sitter/tree-sitter-c"))
             (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
             (java . ("https://github.com/tree-sitter/tree-sitter-java"))
             (python . ("https://github.com/tree-sitter/tree-sitter-python"))
             (lua . ("https://github.com/tree-sitter-grammars/tree-sitter-lua"))
             (bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
             (elisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
             (html . ("https://github.com/tree-sitter/tree-sitter-html"))
             (css . ("https://github.com/tree-sitter/tree-sitter-css"))
             (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
             (json . ("https://github.com/tree-sitter/tree-sitter-json"))
             (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
             (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"))
             (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src"))
             (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src"))))
    (add-to-list 'treesit-language-source-alist source)))

  ;; ============================================================================
;; 2. Treesit-auto: 自动下载并编译到指定目录
;; ============================================================================
(condition-case err
    (use-package treesit-auto
      :straight t
      :demand t
      :custom
      ;; 打开文件时不强制下载 grammar；已安装时自动切换到
      ;; *-ts-mode，缺失时稳定回退到传统 major mode。需要时可用
      ;; M-x treesit-auto-install-all 一次性安装。
      (treesit-auto-install nil)

      :config
      ;; 关键：强行指定 treesit-auto 将源码编译安装到我们自定义的路径
      (setq treesit-auto-install-dir my/treesit-grammar-dir)

      ;; 设置 Treesit 高亮精细度等级 (1: 极简 -> 4: 最精细/最漂亮)
      (setq treesit-font-lock-level 4)

      ;; 自动将系统默认的 Major-mode 映射替换为对应的 -ts-mode
      (global-treesit-auto-mode))
  (error (message "treesit-auto 未加载：%s" (error-message-string err))))

;; ============================================================================
;; 3. Treesit-fold: 基于语法树的代码块折叠
;; ============================================================================
(condition-case err
    (use-package treesit-fold
      :straight (:host github :repo "emacs-tree-sitter/treesit-fold")
      :defer t
      :hook ((c-ts-mode
              c++-ts-mode
              python-ts-mode
              rust-ts-mode
              go-ts-mode
              js-ts-mode
              java-ts-mode
              sql-ts-mode
              elisp-ts-mode
              lua-ts-mode
              typescript-ts-mode) . treesit-fold-mode))
  (error (message "treesit-fold 未加载：%s" (error-message-string err))))

;; ============================================================================
;; 4. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "t f" '("切换代码折叠" . treesit-fold-toggle)
    "t F" '("展开全部折叠" . treesit-fold-open-all)
    "t i" '("检查光标处 AST" . treesit-inspect-mode)
    "t m" '("选择当前缩进块" . my/mark-indent-block)
    "t M" '("选择当前缩进块内部" . my/mark-indent-block-inner)
    "t a" '("批量安装全部语法" . treesit-auto-install-all)))

(provide 'init-treesitter)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 已安装 grammar 时自动使用对应 `*-ts-mode'，缺失时回退传统 major mode，不阻断打开文件。
;; - `C-c t a' 批量下载并编译全部 grammar；产物保存在 `tree-sitter/'。
;; - `C-c t f' 折叠/展开当前代码块，`C-c t F' 展开当前 Buffer 的全部折叠。
;; - `C-c t i' 打开语法树检查模式，适合确认光标处 AST 节点及排查高亮问题。
;; - 编译 grammar 需要 Git、C 编译器和可用网络；本配置启动时不会强制下载。
;;; init-treesitter.el ends here
