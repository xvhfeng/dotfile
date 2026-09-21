;;; -*- lexical-binding: t -*-

;;; 中文导读：图形界面字体模块。分别为拉丁文字、中文/CJK、符号和 Emoji 选择字体
;;; 与字号，并在新 frame 创建后重新应用，使 daemon 模式中新窗口也得到一致字体。
;;; 字体设置只在 `display-graphic-p' 为真时由 init.el 加载。

;; Font download link
;; [IBM Plex Mono](https://github.com/IBM/plex)
;; [Iosevka SS13](https://github.com/be5invis/Iosevka)
;; [LXGW WenKai Mono](https://github.com/lxgw/LxgwWenKai)
;; [Maple Mono](https://github.com/subframe7536/maple-font)
;; [Sarasa Mono SC](https://github.com/be5invis/Sarasa-Gothic)

(require 'cl-lib)                                              ; 引入 Common Lisp 扩展库（提供 cl-loop、cl-defmethod 等高级语法）

;; Default: 配置默认英文字体（等宽）
(cl-loop for font in '("IBM Plex Mono" "JetBrains Mono" "Iosevka SS13" "Cascadia Mono") ; 遍历预设的英文字体优先级列表
         when (find-font (font-spec :family font))             ; 检测当前操作系统中是否存在该字体
         return (set-face-attribute 'default nil :family font :height 140)) ; 匹配到首个存在的字体即应用，并设字号为 14pt (140)

;; Chinese: 配置汉字/中文字体与放缩比例
(cl-loop for font in '("LXGW WenKai Mono" "Sarasa Mono SC"      ; 依次按优先级检索：霞鹜文楷等宽、等线 SC、微软雅黑、等线、黑体
                       "Microsoft YaHei" "DengXian" "Simhei")
         for spec = (font-spec :family font)
         when (find-font spec)
         return (progn
                  (setq face-font-rescale-alist `((,font . 1.3))) ; 放大中文字体比例至 1.3 倍，使中英文混排时高度一致且能完美对齐
                  (set-fontset-font t 'han spec)))             ; 将汉字 (han) 字符集的字体指定为匹配到的中文字体

;; Symbol: 配置标点与标准符号字体
(cl-loop for font in '("Segoe UI Symbol" "Apple Symbols" "Symbol") ; 跨平台适配 Windows、macOS 与 Linux 的标准符号字体
         for spec = (font-spec :family font)
         when (find-font spec)
         return (set-fontset-font t 'symbol font))              ; 将 symbol 字符集指定为该字体

;; Emoji: 配置彩色表情符号字体
(cl-loop for font in '("Segoe UI Emoji" "Apple Color Emoji" "Noto Color Emoji") ; 跨平台适配 Emoji 字体
         for spec = (font-spec :family font)
         when (find-font spec)
         return (set-fontset-font t 'emoji spec))               ; 将 emoji 字符集指定为该字体

;; Nerd Fonts: 配置图标与特种符号 Unicode 码位映射
(cl-loop for font in '("Symbols Nerd Font Mono")               ; 使用专用图标字体
         for spec = (font-spec :family font)
         when (find-font spec)
         return (progn
                  (set-fontset-font t '(#xe000 . #xf8ff) spec)  ; 将经典 PUA 图标码位 (0xE000-0xF8FF) 映射至该图标字体
                  (set-fontset-font t '(#xf0000 . #xfffff) spec))) ; 将扩展 PUA 图标码位 (0xF0000-0xFFFFF) 映射至该图标字体

;; Extra: 为特定单字与框线绘制字符强制设定专用字体 (Maple Mono)
(cl-loop for font in '("Maple Mono Normal")
         for spec = (font-spec :family font)
         when (find-font spec)
         return (progn
                  (setq face-font-rescale-alist `((,font . 0.95))) ; 针对 Maple Mono 整体缩小至 0.95 倍
                  (cl-loop for char in '(?λ ?┌ ?─ ?│ ?├ ?╰ ?►)  ; 针对希腊字母 λ 和制表符/管道符
                           do (set-fontset-font t char spec nil 'prepend)))) ; 强制优先 (prepend) 使用该字体渲染

;; Font Ligature: (注释代码: 原用于配置代码连字/Font Ligature 组合函数，现已注释停用)
;; (cl-loop for chars in '("::" "..." "->" "=>" "<=" ">=" "!==" "!=" "===" "==")
;;          for key = (aref chars 0)
;;          do (set-char-table-range
;;              composition-function-table  key
;;              (nconc (char-table-range composition-function-table key)
;;                     `(,(vector (regexp-quote chars) 0 'font-shape-gstring)))))

;; 在消息区/scratch 打印本配置当前系统可用的字体族，便于排查缺字或图标问题。
(defun nn-print-install-font ()
  (interactive)                                                ; 声明为交互式命令 (可 M-x 运行)
  (with-current-buffer (scratch-buffer)                        ; 在 *scratch* 缓冲区中输出
    (let ((sorted
           (sort (delete-dups (delete "" (font-family-list)))   ; 获取系统全量字体列表，去重去空后进行字母序排序
                 #'string<))
          prev)
      (dolist (f sorted)
        ;; 过滤掉同名字体的变体（如防止粗体/斜体重复输出，只保留首个字体族名）
        (unless (and prev (string-prefix-p (concat prev " ") f))
          (insert f "\n")                                      ; 插入字体族名称并换行
          (setq prev f))))
    (goto-char (point-min))))                                  ; 将光标移至缓冲区顶部
    
(provide 'init-font)
