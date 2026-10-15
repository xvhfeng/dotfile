;;; init-latex.el --- LaTeX editing, compilation and preview -*- lexical-binding: t; -*-

(declare-function TeX-command-master "tex" (&optional override-confirm))
(declare-function TeX-view "tex")
(declare-function preview-document "preview")
(declare-function preview-at-point "preview")
(declare-function preview-clearout-document "preview")

(defconst my/latex-engine-candidates
  '("latexmk" "xelatex" "lualatex" "pdflatex" "tectonic")
  "TeX engines accepted by the LaTeX commands in this configuration.")

(defun my/latex-find-engine ()
  "Return the first available TeX engine, or nil."
  (seq-find #'executable-find my/latex-engine-candidates))

(defun my/latex-require-engine ()
  "Return an installed TeX engine or report how to install one."
  (or (my/latex-find-engine)
      (user-error
       (concat "没有找到 LaTeX 引擎。macOS 请先安装 MacTeX/BasicTeX，"
               "并确认 latexmk、xelatex、lualatex、pdflatex 或 tectonic 在 PATH 中"))))

(defun my/latex-compile-document ()
  "Compile the current TeX master using AUCTeX."
  (interactive)
  (my/latex-require-engine)
  (call-interactively #'TeX-command-master))

(defun my/latex-view-document ()
  "Open the PDF belonging to the current TeX master."
  (interactive)
  (my/latex-require-engine)
  (call-interactively #'TeX-view))

(defun my/latex-preview-document ()
  "Render all supported LaTeX fragments inline with preview-latex."
  (interactive)
  (my/latex-require-engine)
  (require 'preview)
  (call-interactively #'preview-document))

(defun my/latex-preview-at-point ()
  "Render the LaTeX fragment at point with preview-latex."
  (interactive)
  (my/latex-require-engine)
  (require 'preview)
  (call-interactively #'preview-at-point))

(defun my/latex-clear-previews ()
  "Remove all preview-latex overlays from the current document."
  (interactive)
  (require 'preview)
  (call-interactively #'preview-clearout-document))

;; AUCTeX 提供语法高亮、补全、编译、错误跳转与 preview-latex 内联预览。
(use-package tex
  :straight auctex
  :mode (("\\.tex\\'" . LaTeX-mode)
         ("\\.ltx\\'" . LaTeX-mode)
         ("\\.sty\\'" . LaTeX-mode)
         ("\\.cls\\'" . LaTeX-mode))
  :hook ((LaTeX-mode . visual-line-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . turn-on-reftex)
         (LaTeX-mode . TeX-source-correlate-mode))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t)
  (TeX-source-correlate-start-server t)
  (TeX-save-query nil)
  (LaTeX-electric-left-right-brace t)
  (reftex-plug-into-AUCTeX t))

;; TAB 展开缩写，快速插入数学符号和 LaTeX 环境。
(use-package cdlatex
  :straight t
  :after tex
  :hook (LaTeX-mode . turn-on-cdlatex))

(with-eval-after-load 'general
  (my-leader-def
    "l c" '("compile document" . my/latex-compile-document)
    "l v" '("view PDF" . my/latex-view-document)
    "l p" '("preview document inline" . my/latex-preview-document)
    "l a" '("preview fragment at point" . my/latex-preview-at-point)
    "l x" '("clear inline previews" . my/latex-clear-previews)
    "l r" '("reference/table of contents" . reftex-toc)
    "l e" '("insert environment" . LaTeX-environment)
    "l m" '("insert macro" . TeX-insert-macro)
    "l k" '("clean generated files" . TeX-clean)))

(provide 'init-latex)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-c l c' 编译主文档，`C-c l v' 查看生成的 PDF，`C-c l k' 清理辅助文件。
;; - `C-c l p' 内联预览全文公式/图形，`C-c l a' 只预览光标处，`C-c l x' 清除预览。
;; - `C-c l r' 打开 RefTeX 目录/引用导航；`C-c l e/m' 插入环境/宏。
;; - LaTeX Buffer 中 `TAB' 可展开 CDLaTeX 缩写；`C-c =' 打开 RefTeX 目录。
;; - 编译与预览必须有 TeX 引擎；preview-latex 还建议安装 Ghostscript。
;; - macOS 可选择 MacTeX（完整）或 BasicTeX（精简），安装后重新启动 Emacs 读取 PATH。
;;; init-latex.el ends here
