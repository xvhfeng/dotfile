;;; init-texinfo.el --- Texinfo editing, preview and export -*- lexical-binding: t; -*-

(declare-function texinfo-format-buffer "texinfmt" (&optional nosplit))
(declare-function texinfo-format-region "texinfmt" (beginning end))
(declare-function texinfo-show-structure "texinfo" (&optional nodes-too))
(declare-function texinfo-all-menus-update "texnfo-upd" (&optional update-nodes))
(declare-function texinfo-every-node-update "texnfo-upd")
(defvar texinfo-region-buffer-name)
(defvar tex-start-of-header)
(defvar tex-end-of-header)

(defconst my/texinfo-export-buffer "*Texinfo Export*"
  "Buffer used to report asynchronous Texinfo export output.")

(defun my/texinfo-ensure-buffer ()
  "Signal a user-facing error unless the current Buffer is Texinfo."
  ;; AUCTeX remaps the built-in `texinfo-mode' to its enhanced
  ;; `Texinfo-mode'; support both implementations without coupling them.
  (unless (or (derived-mode-p 'texinfo-mode)
              (derived-mode-p 'Texinfo-mode)
              (memq major-mode '(texinfo-mode Texinfo-mode)))
    (user-error "当前 Buffer 不是 Texinfo 文件")))

(defun my/texinfo-source-file ()
  "Save and return the current Texinfo source file."
  (my/texinfo-ensure-buffer)
  (unless buffer-file-name
    (user-error "请先保存当前 Texinfo Buffer，再执行导出"))
  (when (buffer-modified-p)
    (save-buffer))
  (expand-file-name buffer-file-name))

(defun my/texinfo-converter ()
  "Return the installed GNU Texinfo converter, or report how to install it."
  (or (executable-find "texi2any")
      (executable-find "makeinfo")
      (user-error
       (concat "没有找到 texi2any/makeinfo。macOS 可安装 GNU Texinfo，"
               "例如执行 brew install texinfo，并确保其 bin 目录在 PATH 中"))))

(defun my/texinfo-preview-buffer ()
  "Render the current Texinfo Buffer into a temporary Info preview."
  (interactive)
  (my/texinfo-ensure-buffer)
  ;; texinfmt uses header delimiters declared by Emacs' built-in tex-mode.
  ;; AUCTeX's enhanced Texinfo-mode does not load that library itself.
  (require 'tex-mode)
  (require 'texinfmt)
  (save-current-buffer
    (save-restriction
      (widen)
      (texinfo-format-region (point-min) (point-max))))
  ;; Show the rendered result without moving editing commands away from source.
  (display-buffer texinfo-region-buffer-name))

(defun my/texinfo-export-info ()
  "Format and save the current Texinfo document as an Info file."
  (interactive)
  (my/texinfo-source-file)
  (require 'tex-mode)
  (require 'texinfmt)
  (let (output-buffer output-file)
    (save-restriction
      (widen)
      (save-current-buffer
        (texinfo-format-buffer)
        (setq output-buffer (current-buffer)
              output-file buffer-file-name)
        (save-buffer)))
    (display-buffer output-buffer)
    (message "Texinfo Info 已导出：%s" output-file)))

(defun my/texinfo--export (format extension &optional no-split require-tex)
  "Export current Texinfo file as FORMAT with EXTENSION.
When NO-SPLIT is non-nil, generate a single output file.  When REQUIRE-TEX
is non-nil, verify that texi2dvi is installed before starting."
  (let* ((source (my/texinfo-source-file))
         (converter (my/texinfo-converter))
         (output (concat (file-name-sans-extension source) extension))
         (log-buffer (get-buffer-create my/texinfo-export-buffer)))
    (when (and require-tex (not (executable-find "texi2dvi")))
      (user-error
       "PDF 导出还需要 texi2dvi 和 TeX 引擎；请安装 GNU Texinfo 与 MacTeX/BasicTeX"))
    (when-let ((old-process (get-buffer-process log-buffer)))
      (when (process-live-p old-process)
        (user-error "已有 Texinfo 导出任务正在运行")))
    (with-current-buffer log-buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (format "正在导出 %s\n源文件：%s\n目标文件：%s\n\n"
                        format source output))))
    (let ((process
           (make-process
            :name "texinfo-export"
            :buffer log-buffer
            :command (append (list converter (concat "--" format))
                             (when no-split '("--no-split"))
                             (list "--output" output source))
            :noquery t
            :sentinel
            (lambda (proc _event)
              (when (memq (process-status proc) '(exit signal))
                (if (zerop (process-exit-status proc))
                    (message "Texinfo %s 已导出：%s" format output)
                  (display-buffer (process-buffer proc))
                  (message "Texinfo %s 导出失败，请查看 %s"
                           format my/texinfo-export-buffer)))))))
      (display-buffer log-buffer)
      process)))

(defun my/texinfo-export-html ()
  "Export the current Texinfo document as one HTML file."
  (interactive)
  (my/texinfo--export "html" ".html" t))

(defun my/texinfo-export-text ()
  "Export the current Texinfo document as plain text."
  (interactive)
  (my/texinfo--export "plaintext" ".txt"))

(defun my/texinfo-export-epub ()
  "Export the current Texinfo document as EPUB 3."
  (interactive)
  (my/texinfo--export "epub3" ".epub"))

(defun my/texinfo-export-pdf ()
  "Export the current Texinfo document as PDF."
  (interactive)
  (my/texinfo--export "pdf" ".pdf" nil t))

(defun my/texinfo-mode-setup ()
  "Enable comfortable prose editing in Texinfo buffers."
  (visual-line-mode 1)
  (outline-minor-mode 1)
  (setq-local fill-column 80
              sentence-end-double-space nil
              ;; Emacs' built-in texinfmt expects these buffer-local markers.
              ;; Set them explicitly because AUCTeX's Texinfo-mode omits them.
              tex-start-of-header "%\\*\\*start"
              tex-end-of-header "%\\*\\*end"))

(use-package texinfo
  :straight nil
  :mode (("\\.texi\\'" . texinfo-mode)
         ("\\.texinfo\\'" . texinfo-mode)
         ("\\.txi\\'" . texinfo-mode))
  :hook ((texinfo-mode . my/texinfo-mode-setup)
         (Texinfo-mode . my/texinfo-mode-setup)))

(with-eval-after-load 'general
  (my-leader-def
    "i p" '("preview as Info" . my/texinfo-preview-buffer)
    "i f" '("export Info" . my/texinfo-export-info)
    "i h" '("export HTML" . my/texinfo-export-html)
    "i t" '("export plain text" . my/texinfo-export-text)
    "i e" '("export EPUB" . my/texinfo-export-epub)
    "i P" '("export PDF" . my/texinfo-export-pdf)
    "i s" '("show document structure" . texinfo-show-structure)
    "i m" '("update all menus" . texinfo-all-menus-update)
    "i n" '("update all nodes" . texinfo-every-node-update)
    "i i" '("insert node" . texinfo-insert-@node)
    "i b" '("insert block" . texinfo-insert-block)
    "i x" '("insert matching @end" . texinfo-insert-@end)))

(provide 'init-texinfo)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `.texi'、`.texinfo'、`.txi' 文件自动进入 texinfo-mode，并启用自动换行和大纲折叠。
;; - `C-c i p' 使用 Emacs 内置格式器预览全文，不需要外部 Texinfo 工具。
;; - `C-c i f' 导出并保存 Info 文件；源文件必须包含 `@setfilename'。
;; - `C-c i h/t/e/P' 分别导出 HTML、纯文本、EPUB 3、PDF。
;; - HTML/文本/EPUB 需要 texi2any 或 makeinfo；PDF 还需要 texi2dvi 和 TeX 引擎。
;; - `C-c i s' 查看文档结构；`C-c i m/n' 更新菜单/节点。
;; - `C-c i i/b/x' 插入节点、块或与当前块匹配的 `@end'。
;; - Texinfo 模式原生帮助可用 `C-h m' 查看；`M-q' 按 80 列整理当前段落。
;;; init-texinfo.el ends here
