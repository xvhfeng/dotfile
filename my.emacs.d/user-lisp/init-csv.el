;;; init-csv.el --- CSV and tabular data editing -*- lexical-binding: t; -*-

(declare-function csv-align-mode "csv-mode" (&optional arg))
(declare-function csv-guess-set-separator "csv-mode" ())
(declare-function csv-header-line "csv-mode" (&optional use-current-line))
(defvar csv--header-line)
(defvar csv-header-lines)
(defvar csv-separator-chars)

(defcustom my/csv-auto-align-max-size (* 1024 1024)
  "Maximum CSV file size for automatically enabling visual alignment.

Dynamic alignment is useful for normal tables but can be expensive for very
large files.  Such files still use `csv-mode'; alignment can be enabled
manually with `my/csv-toggle-visual-alignment'."
  :type 'integer
  :group 'convenience)

(defun my/csv-buffer-p ()
  "Return non-nil when the current buffer uses CSV or TSV mode."
  (derived-mode-p 'csv-mode 'tsv-mode))

(defun my/csv-ensure-buffer ()
  "Report a user-facing error unless the current buffer is CSV or TSV."
  (unless (my/csv-buffer-p)
    (user-error "当前 Buffer 不是 CSV/TSV 文件")))

(defun my/csv-toggle-visual-alignment ()
  "Toggle non-destructive, on-screen alignment for the current table."
  (interactive)
  (my/csv-ensure-buffer)
  (csv-align-mode (if (bound-and-true-p csv-align-mode) -1 1)))

(defun my/csv-guess-separator ()
  "Guess and apply the current table's field separator."
  (interactive)
  (my/csv-ensure-buffer)
  (csv-guess-set-separator)
  (message "CSV 分隔符已自动识别为：%s"
           (mapconcat (lambda (char)
                        (key-description (vector char)))
                      csv-separator-chars
                      " ")))

(defun my/csv-toggle-header-line ()
  "Toggle a sticky first-row header and matching sort protection."
  (interactive)
  (my/csv-ensure-buffer)
  (if (bound-and-true-p csv--header-line)
      (progn
        (csv-header-line)
        (setq-local csv-header-lines 0)
        (message "CSV 表头已关闭"))
    (setq-local csv-header-lines 1)
    (csv-header-line)
    (message "CSV 首行已设为固定表头；排序时会跳过该行")))

(defun my/csv-mode-setup ()
  "Configure readable and efficient editing for CSV and TSV buffers."
  (hl-line-mode 1)
  (setq-local truncate-lines t)
  ;; Guess first so semicolon- and pipe-separated data also align correctly.
  (ignore-errors (csv-guess-set-separator))
  (when (<= (buffer-size) my/csv-auto-align-max-size)
    (csv-align-mode 1)))

;; csv-mode supports quoted fields and arbitrary one-character separators.  It
;; also registers .csv and .tsv itself; explicit entries keep file detection
;; predictable before package autoloads have been regenerated.
(use-package csv-mode
  :straight t
  :mode (("\\.csv\\'" . csv-mode)
         ("\\.tsv\\'" . tsv-mode)
         ("\\.tab\\'" . tsv-mode))
  ;; tsv-mode derives from csv-mode, so one parent hook covers both modes.
  :hook (csv-mode . my/csv-mode-setup)
  :custom
  (csv-align-min-width 1)
  (csv-confirm-region t)
  (csv-invisibility-default nil))

(with-eval-after-load 'general
  (my-leader-def
    "v a" '("切换视觉对齐" . my/csv-toggle-visual-alignment)
    "v A" '("对齐缓冲区字段" . csv-align-fields)
    "v u" '("撤销字段对齐" . csv-unalign-fields)
    "v s" '("按文本字段排序" . csv-sort-fields)
    "v n" '("按数字字段排序" . csv-sort-numeric-fields)
    "v r" '("反转行" . csv-reverse-region)
    "v t" '("转置行与列" . csv-transpose)
    "v k" '("剪切字段" . csv-kill-fields)
    "v y" '("粘贴字段" . csv-yank-fields)
    "v i" '("插入列" . csv-insert-column)
    "v g" '("识别字段分隔符" . my/csv-guess-separator)
    "v e" '("设置字段分隔符" . csv-set-separator)
    "v H" '("切换首行表头固定" . my/csv-toggle-header-line)
    "v h" '("显示或隐藏分隔符" . csv-toggle-invisibility)
    "v d" '("切换降序排序" . csv-toggle-descending)
    "v w" '("设置显示列宽" . csv-align-set-column-width)))

(provide 'init-csv)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `.csv' 自动进入 csv-mode；`.tsv'、`.tab' 自动进入 tsv-mode。
;; - 小于 1 MiB 的表格默认只在屏幕上动态对齐，不修改文件内容；大文件跳过
;;   自动对齐以保证性能，可用 `C-c v a' 手动开关。
;; - `C-c v a' 开关动态对齐；`C-c v A/u' 把字段写入式对齐/撤销写入式对齐。
;; - `C-c v s/n' 按指定列进行文本/数字排序；`C-c v r' 反转所选行。
;; - `C-c v t' 转置行列；`C-c v k/y' 剪切/粘贴字段；`C-c v i' 插入列。
;; - `C-c v g/e' 自动识别/手工指定分隔符，支持逗号、Tab、分号、竖线等格式。
;; - `C-c v H' 固定/取消首行表头；启用后排序自动跳过首行。`C-c v d' 切换
;;   升序/降序；`C-c v h' 显示/隐藏分隔符；`C-c v w' 设置当前显示列宽。
;; - `csv-align-mode' 只是显示效果，保存时不会写入空格；需要修改实际空格时才用
;;   `csv-align-fields'，之后可用 `csv-unalign-fields' 恢复。
;; - 模式自带字段索引显示；完整原生命令和默认按键可用 `C-h m' 查看。
;;; init-csv.el ends here
