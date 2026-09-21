;;; -*- lexical-binding: t -*-

;;; 中文导读：代码与位置导航。Xref 是 Emacs 统一的定义/引用接口，Citre 读取
;;; tags 数据库并提供大型项目跳转，Bookmark 保存位置，goto-addr 识别可点击地址。
;;; M-g . 找定义，M-g , 返回；F12/S-F12 跳定义/引用，M-F12 打开 Citre 预览，
;;; 预览窗口中 q 退出。
(use-package goto-addr
  :ensure nil                                                  ; 内置包，无需从 ELPA/MELPA 下载
  :hook
  (prog-mode . goto-address-prog-mode)                         ; 编程模式下开启（仅将注释和字符串里的 URL 渲染为超链接）
  (text-mode . goto-address-prog-mode))                        ; 文本模式下开启

(use-package xref
  :autoload xref-show-definitions-completing-read              ; 延迟加载该函数
  :bind
  ("M-g ." . xref-find-definitions)                            ; M-g . 跳转到符号定义处
  ("M-g ," . xref-go-back)                                     ; M-g , 返回跳转前的位置
  :custom
  (xref-search-program (if (executable-find "rg") 'ripgrep 'grep)) ; 检测系统是否安装 rg，优先使用 ripgrep 提高搜索速度
  (xref-show-definitions-function #'xref-show-definitions-function-completing-read) ; 使用 Completing-read (Vertico/Helm/Ivy) 展示多重定义
  (xref-show-xrefs-function #'xref-show-definitions-completing-read))

(use-package bookmark
  :ensure nil                                                  ; 内置包
  :custom (bookmark-default-file (concat nn-directory "bookmark-default.el")) ; 自定义默认书签保存文件路径
  :config
  ;; Advice：在刷新书签菜单列表 (bookmark-bmenu) 后执行，动态美化条目，添加图标
  (define-advice bookmark-bmenu--revert (:after (&rest _) my-bookmark-bmenu--icons)
    "Prepend nerd-icons to bookmark names."
    (when (display-graphic-p)                                  ; 仅在图形界面 (GUI) 下渲染图标
      (dolist (entry tabulated-list-entries)                  ; 遍历书签列表的每一行 entry
        (let* ((rec (car entry))
               (row (cadr entry))
               (loc (bookmark-get-filename rec))               ; 获取书签对应的文件/路径名
               (file (and (stringp loc)
                          (not (string-empty-p loc))
                          (file-name-nondirectory loc)))       ; 提取单纯的文件名
               (icon (cond ((not loc) nil)                    ; 分情况匹配图标：
                           ((file-remote-p loc)                ; 1. Tramp 远程路径 -> 无线电塔图标
                            (nerd-icons-codicon "nf-cod-radio_tower"))
                           ((file-directory-p loc)             ; 2. 本地目录 -> 目录图标
                            (nerd-icons-icon-for-dir loc))
                           ((and file (not (string-empty-p file))) ; 3. 普通文件 -> 文件类型图标
                            (nerd-icons-icon-for-file file))))
               (idx (if bookmark-bmenu-toggle-filenames 1 0))) ; 根据是否显示文件名列确定插入图标的索引列位置
          (when icon
            (setf (elt row idx)                                ; 将图标拼接到书签名称前
                  (concat icon "  " (elt row idx))))))
      (tabulated-list-print t))))                              ; 重新绘制列表

(use-package citre
  :bind
  (("<f12>" . citre-jump)                                      ; F12 跳转到定义
   ("S-<f12>" . citre-jump-to-reference)                       ; Shift + F12 跳转到引用处
   ("M-<f12>" . citre-peek)                                    ; Alt + F12 开启 Peek View 预览窗口
   :map citre-peek-keymap
   ("q" . keyboard-quit))                                      ; 在 Peek 窗口中按 q 退出
  :hook (prog-mode . citre-mode)                               ; 在编程模式下自动启动 citre-mode
  :custom-face
  (citre-peek-border-face ((t :inherit font-lock-keyword-face :strike-through t :extend t))) ; 自定义 Peek 窗口边框样式
  :custom
  (citre-readtags-program "readtags")                          ; 指定 readtags 可执行文件路径
  (citre-ctags-program "ctags")                                ; 指定 ctags 可执行文件路径
  (citre-peek-fill-fringe nil)                                 ; 关闭 Peek 模式下的 Fringe 填充
  (citre-completion-case-sensitive t)                          ; 补全区分大小写
  (citre-imenu-create-tags-file-threshold (* 20 1024 1024))     ; 生成 tags 文件的阈值限制为 20MB
  (citre-default-create-tags-file-location 'in-dir)            ; 默认将 tags 文件创建在当前项目目录下
  (citre-edit-ctags-options-manually nil)                      ; 不手动编辑 ctags 参数配置
  (citre-auto-enable-citre-mode-backends-for-remote nil)       ; 远程 Tramp 连接时默认不自动开启 Citre 扩展
  :config
  (require 'citre-config)                                      ; 加载 Citre 的默认整合配置

  ;; 为 Citre 的补全设置专属的 completion-category-overrides（强制指定 basic 样式）
  (add-to-list 'completion-category-overrides '(citre (styles basic)))

  ;; 定义 Buffer 局部变量：存储当项目主 tags 文件未查到符号时需回退查找的外部 tags 路径列表
  (defvar-local nn-citre-external-tags nil
    "List of external tags files queried when the project tags returns nothing.")

  ;; Advice：当项目自带的 tags 文件找不到符号时，遍历 `nn-citre-external-tags` 中的外部 tags 补充查找
  (define-advice citre-tags-get-tags (:around (old-fn tagsfile &rest args) nn-ext)
    "Fall back to `nn-citre-external-tags' when project tags returns nothing."
    (or (apply old-fn tagsfile args)
        (cl-loop for f in nn-citre-external-tags
                 for ext = (expand-file-name f)
                 when (file-exists-p ext)
                 thereis (apply old-fn ext args))))

  ;; 映射表：将 Ctags 导出的各类 Symbol kind（如 function, class, variable 等）
  ;; 映射转换为 LSP 风格的标准名称，方便被 `nerd-icons-corfu` 识别并显示正确的图标
  (defconst nn-lsp-kind
    '(("function" "function") ("method" "method") ("procedure" "function")
      ("submethod" "method") ("subprogram" "function") ("subroutine" "function")
      ("prototype" "function") ("functor" "function") ("callback" "function")
      ("class" "class") ("struct" "struct") ("structure" "struct")
      ("union" "struct") ("record" "class") ("component" "class")
      ("object" "class") ("role" "class")
      ("interface" "interface") ("trait" "interface") ("protocol" "interface")
      ("annotation" "interface") ("implementation" "class")
      ("enum" "enum") ("enumerator" "enummember")
      ("variable" "variable") ("local" "variable") ("global" "variable")
      ("parameter" "variable") ("instance" "variable") ("macroparam" "variable")
      ("field" "field") ("member" "field") ("slot" "field")
      ("property" "property") ("attribute" "property")
      ("constant" "constant") ("const" "constant")
      ("module" "module") ("namespace" "module") ("package" "module")
      ("library" "module") ("using" "module")
      ("type" "typeparameter") ("template" "typeparameter") ("tparam" "typeparameter")
      ("generic" "typeparameter") ("typedef" "keyword") ("alias" "keyword")
      ("name" "keyword") ("define" "macro") ("macro" "macro")
      ("constructor" "constructor") ("destructor" "constructor")
      ("event" "event") ("signal" "event") ("handler" "event")
      ("file" "file") ("header" "file") ("script" "file")
      ("label" "keyword") ("anchor" "keyword") ("key" "keyword")
      ("operator" "operator") ("string" "string") ("number" "numeric")
      ("boolean" "boolean") ("array" "array") ("exception" "class")))

  ;; Advice：过滤并改写 Citre 补全项（Candidate）的 kind 属性
  (define-advice citre-capf--make-candidate (:filter-return (cand) nn-kind)
    "Rewrite citre-kind to nerd-icons-corfu-compatible key."
    (when-let* ((raw (citre-get-property 'kind cand))
                (mapped (cadr (assoc-string (symbol-name raw) nn-lsp-kind 'case-fold))))
      (citre-put-property cand 'kind (intern mapped)))
    cand))

(provide 'init-navigation)
