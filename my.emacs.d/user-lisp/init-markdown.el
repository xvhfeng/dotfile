;;; init-markdown.el --- Markdown editing and preview -*- lexical-binding: t; -*-

(declare-function commonmark-gfm-use-as-markdown-command "commonmark-gfm")
(declare-function markdown-live-preview-mode "markdown-mode" (&optional arg))
(declare-function markdown-export-and-preview "markdown-mode")

;; Markdown 编辑模式。README 使用 GFM，其余常见扩展名使用 markdown-mode。
(use-package markdown-mode
  :straight t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'"
          . markdown-mode))
  :hook ((markdown-mode . visual-line-mode)
         (gfm-mode . visual-line-mode))
  :custom
  (markdown-enable-math t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t)
  (markdown-hide-markup nil)
  (markdown-indent-on-enter 'indent-and-new-item)
  (markdown-list-indent-width 4))

;; C-c ' 将围栏代码块放入使用对应 major mode 的间接 Buffer 中编辑。
(use-package edit-indirect
  :straight t
  :after markdown-mode)

;; 不依赖 pandoc/markdown 可执行文件的 CommonMark/GFM HTML 渲染器。
(use-package commonmark-gfm
  :straight (:host github :repo "kn66/commonmark-gfm.el")
  :after markdown-mode
  :config
  (commonmark-gfm-use-as-markdown-command))

(use-package markdown-toc
  :straight t
  :commands (markdown-toc-generate-toc
             markdown-toc-refresh-toc
             markdown-toc-delete-toc))

(defun my/markdown-ensure-buffer ()
  "Signal a user-facing error unless the current Buffer is Markdown."
  (unless (derived-mode-p 'markdown-mode 'gfm-mode)
    (user-error "当前 Buffer 不是 Markdown 文件")))

(defun my/markdown-toggle-live-preview ()
  "Toggle the Markdown HTML preview in EWW."
  (interactive)
  (my/markdown-ensure-buffer)
  (require 'commonmark-gfm)
  (commonmark-gfm-use-as-markdown-command)
  (markdown-live-preview-mode (if markdown-live-preview-mode -1 1)))

(defun my/markdown-export-and-preview ()
  "Export the current Markdown Buffer and open its HTML preview."
  (interactive)
  (my/markdown-ensure-buffer)
  (require 'commonmark-gfm)
  (commonmark-gfm-use-as-markdown-command)
  (call-interactively #'markdown-export-and-preview))

(with-eval-after-load 'general
  (my-leader-def
    "k p" '("toggle live preview" . my/markdown-toggle-live-preview)
    "k v" '("export and preview" . my/markdown-export-and-preview)
    "k e" '("export HTML" . markdown-export)
    "k l" '("insert/edit link" . markdown-insert-link)
    "k i" '("insert/edit image" . markdown-insert-image)
    "k c" '("edit code block" . markdown-edit-code-block)
    "k t" '("generate table of contents" . markdown-toc-generate-toc)
    "k r" '("refresh table of contents" . markdown-toc-refresh-toc)
    "k d" '("delete table of contents" . markdown-toc-delete-toc)))

(provide 'init-markdown)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c k p'：在 EWW 中开启/关闭实时预览；不需要 Pandoc 或外部 markdown 命令。
;; - `C-c k v'：导出 HTML 并预览；`C-c k e'：只导出 HTML。
;; - `C-c k l/i'：插入或修改链接/图片；`C-c k c'：独立编辑当前围栏代码块。
;; - `C-c k t/r/d'：生成、刷新、删除目录。
;; - Markdown 模式原生支持 `TAB/S-TAB' 折叠标题，`C-c C-h' 查看模式完整按键。
;; - README.md 自动使用 GFM；普通 .md/.markdown 文件使用 markdown-mode。
;;; init-markdown.el ends here
