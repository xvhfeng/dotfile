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

(defun my/indent-block--nearby-opening-brace ()
  "Return a relevant opening brace position near point, or nil.
This covers C-like styles where a control header and its `{` occupy separate
lines, while still recognizing a brace enclosing point."
  (or (and (eq (char-after) ?{) (point))
      (save-excursion
        (when (search-forward "{" (line-end-position) t)
          (1- (point))))
      (save-excursion
        (end-of-line)
        (forward-line 1)
        (while (and (not (eobp)) (looking-at-p "^[ \t]*$"))
          (forward-line 1))
        (when (looking-at "[ \t]*{")
          (1- (match-end 0))))
      (let ((opening (nth 1 (syntax-ppss))))
        (and opening (eq (char-after opening) ?{) opening))))

(defun my/indent-block--brace-inner-bounds ()
  "Return bounds inside a nearby balanced `{...}` block, or nil."
  (when-let ((opening (my/indent-block--nearby-opening-brace)))
    (save-excursion
      (goto-char opening)
      (condition-case nil
          (progn
            (forward-sexp 1)
            (cons (1+ opening) (1- (point))))
        (scan-error nil)))))

(defun my/indent-block--opening-sexp-at-or-after-point ()
  "Return an opening syntactic delimiter at or after point on this line."
  (or (and (eq (char-syntax (char-after)) ?\() (point))
      (let ((opening (nth 1 (syntax-ppss))))
        (and opening (eq (char-syntax (char-after opening)) ?\() opening))
      (save-excursion
        (let ((limit (line-end-position))
              opening)
          (while (and (not opening) (< (point) limit))
            (if (eq (char-syntax (char-after)) ?\()
                (setq opening (point))
              (forward-char 1)))
          opening))))

(defun my/indent-block--sexp-inner-bounds ()
  "Return bounds inside a nearby syntactically paired expression, or nil."
  (when-let ((opening (my/indent-block--opening-sexp-at-or-after-point)))
    (save-excursion
      (goto-char opening)
      (condition-case nil
          (progn
            (forward-sexp 1)
            (cons (1+ opening) (1- (point))))
        (scan-error nil)))))

(defun my/indent-block--tag-inner-bounds ()
  "Return bounds inside the current HTML/XML tag, or nil.
This delegates nested same-name tag matching to the `%` implementation in
`init-mykey`, which is loaded before this module during normal startup."
  (when (and (fboundp 'my/match-pair--tag-at-point)
             (fboundp 'my/match-pair--find-tag-match))
    (when-let* ((tag (my/match-pair--tag-at-point))
                (match (my/match-pair--find-tag-match tag)))
      (if (plist-get tag :closing)
          (save-excursion
            (goto-char match)
            (when-let ((opening (my/match-pair--tag-at-point)))
              (cons (plist-get opening :end) (plist-get tag :start))))
        (cons (plist-get tag :end) match)))))

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
     (or (my/indent-block--brace-inner-bounds)
         (my/indent-block--tag-inner-bounds)
         (my/indent-block--sexp-inner-bounds)
         (my/indent-block--inner-bounds (my/indent-block--anchor-line))))))

;; ============================================================================
;; 1. 自定义语法包存放路径 (Custom Grammar Storage Directory)
;; ============================================================================
(use-package treesit
  :straight nil
  :demand t
  :init
  ;; 建立自定义运行目录变量
  (defvar my/treesit-grammar-dir
    ;; 编译后的 grammar 是运行产物，统一保存在 runtimes；手动安装和
    ;; `treesit-auto' 安装共用此目录，且由 `treesit-extra-load-path' 发现。
    (my/runtime-file "tree-sitter/")
    "Directory to store and load compiled tree-sitter grammars.")

  ;; 自动创建该目录 (如果尚不存在)
  (unless (file-exists-p my/treesit-grammar-dir)
    (make-directory my/treesit-grammar-dir t))

  ;; 告诉 Emacs 优先从此路径加载编译好的语法动态库 (.so / .dylib)
  (add-to-list 'treesit-extra-load-path my/treesit-grammar-dir)

  ;; 部分未启用 Tree-sitter 的 Emacs 构建不会预先声明该变量；保持配置可加载，
  ;; 之后安装/启用语法支持时仍可直接复用下面的来源清单。
  (defvar treesit-language-source-alist nil)

  (defconst my/treesit-grammar-registry
    '((c . ("https://github.com/tree-sitter/tree-sitter-c"))
      (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
      (java . ("https://github.com/tree-sitter/tree-sitter-java"))
      (python . ("https://github.com/tree-sitter/tree-sitter-python"))
      (lua . ("https://github.com/tree-sitter-grammars/tree-sitter-lua"))
      (bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
      (elisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
      (html . ("https://github.com/tree-sitter/tree-sitter-html"))
      (css . ("https://github.com/tree-sitter/tree-sitter-css"))
      (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
      (json . ("https://github.com/tree-sitter/tree-sitter-json"))
      (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
      ;; 该仓库根目录没有 parser.c，必须指向实际 grammar 的源码子目录。
      (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                   nil "tree-sitter-markdown/src"))
      (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
                     "master" "typescript/src"))
      (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript"
              "master" "tsx/src")))
    "启动时自动下载并编译的 15 个 Tree-sitter grammar 注册表。")

  (defconst my/treesit-registered-languages
    (mapcar #'car my/treesit-grammar-registry)
    "从 `my/treesit-grammar-registry' 生成的语言列表。")

  ;; 中央注册表优先于其他模块的重复声明，确保自动安装使用同一份来源信息。
  (setq treesit-language-source-alist
        (append my/treesit-grammar-registry
                (seq-remove
                 (lambda (source)
                   (memq (car source) my/treesit-registered-languages))
                 treesit-language-source-alist))))

(defvar my/treesit-bootstrap-started nil
  "非 nil 表示本次 Emacs 会话已启动过 grammar 自动安装。")

(defvar my/treesit-last-install-result nil
  "最近一次 grammar 安装结果，格式为 (:status STATUS :total N :failed LIST)。")

(defun my/treesit-install-registered-grammars ()
  "把注册表中缺失的 grammar 编译安装到 `my/treesit-grammar-dir'。"
  (interactive)
  (unless (treesit-available-p)
    (user-error "当前 Emacs 构建不支持 Tree-sitter"))
  (let ((missing (seq-filter
                  (lambda (language)
                    (not (treesit-language-available-p language)))
                  my/treesit-registered-languages))
        failed)
    (if (null missing)
        (progn
          (setq my/treesit-last-install-result
                (list :status 'complete
                      :total (length my/treesit-registered-languages)
                      :failed nil))
          (message "Tree-sitter：注册的 %d 个 grammar 均已安装"
                   (length my/treesit-registered-languages)))
      (setq my/treesit-last-install-result
            (list :status 'installing :total (length missing) :failed nil))
      (message "Tree-sitter：开始自动安装 %d 个缺失 grammar：%s"
               (length missing) (mapconcat #'symbol-name missing ", "))
      (dolist (language missing)
        (condition-case err
            (progn
              ;; OUT-DIR 必须显式传入；treesit-auto 没有 install-dir 配置变量。
              (treesit-install-language-grammar language my/treesit-grammar-dir)
              (unless (treesit-language-available-p language)
                (push language failed)))
          (error
           (push language failed)
           (message "Tree-sitter 安装 %s 失败：%s"
                    language (error-message-string err)))))
      (setq failed (nreverse (delete-dups failed)))
      (setq my/treesit-last-install-result
            (list :status (if failed 'failed 'complete)
                  :total (length missing) :failed failed))
      (if failed
          (message "Tree-sitter：自动安装结束，失败 %d 项：%s"
                   (length failed) (mapconcat #'symbol-name failed ", "))
        (message "Tree-sitter：%d 个缺失 grammar 自动安装完成"
                 (length missing))))))

(defun my/treesit-auto-install-registered-grammars ()
  "首次交互式初始化时自动安装全部注册 grammar，同一会话只启动一次。"
  (unless (or noninteractive my/treesit-bootstrap-started)
    (setq my/treesit-bootstrap-started t)
    (my/treesit-install-registered-grammars)))

;; ============================================================================
;; 2. Treesit-auto: 自动下载并编译到指定目录
;; ============================================================================
(condition-case err
    (use-package treesit-auto
      :straight t
      :demand t
      :custom
      ;; 禁用 treesit-auto 自带的按文件补装，因为它不能指定输出目录，会写回
      ;; ~/.emacs.d/tree-sitter/。统一由下面的安装器写入 runtimes/tree-sitter/。
      (treesit-auto-install nil)

      :config
      ;; 只管理中央注册表中的 15 种语言，不下载 treesit-auto 的全部 recipe。
      (setq treesit-auto-langs (copy-sequence my/treesit-registered-languages))

      ;; 设置 Treesit 高亮精细度等级 (1: 极简 -> 4: 最精细/最漂亮)
      (setq treesit-font-lock-level 4)

      ;; treesit-auto 插件安装并加载完毕后，立即根据注册表下载和编译缺失项。
      (my/treesit-auto-install-registered-grammars)

      ;; grammar 就绪后，自动将传统 Major mode 映射为对应的 -ts-mode。
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
    "t a" '("补齐注册的语法" . my/treesit-install-registered-grammars)))

(provide 'init-treesitter)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 已安装 grammar 时自动使用对应 `*-ts-mode'，缺失时回退传统 major mode，不阻断打开文件。
;; - 首次初始化自动安装注册的 15 个 grammar，以后启动只检查并补齐缺失项。
;; - `C-c t a' 可手动重试；产物固定保存在 `runtimes/tree-sitter/'。
;; - `C-c t f' 折叠/展开当前代码块，`C-c t F' 展开当前 Buffer 的全部折叠。
;; - `C-c t i' 打开语法树检查模式，适合确认光标处 AST 节点及排查高亮问题。
;; - 编译 grammar 需要 Git、C 编译器和可用网络；批处理和字节编译不会触发下载。
;;; init-treesitter.el ends here
