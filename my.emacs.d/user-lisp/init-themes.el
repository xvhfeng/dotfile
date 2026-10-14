;;; -*- lexical-binding: t -*-

;;;========================================================================
;;; 配置emacs使用的主题
;;;========================================================================

(use-package ef-themes
    :straight (:host github :repo "protesilaos/ef-themes")
  :demand t
  :config
  ;; 设置 toggle 命令在 ef-spring (亮色) 与 ef-autumn (暗色) 之间切换
  ;; (setq ef-themes-to-toggle '(ef-spring ef-autumn))

(setq ef-themes-italic-constructs t    ; 开启关键字/注释斜体
      ef-themes-bold-constructs t)     ; 开启重点语法粗体
  
  ;; 默认加载 ef-spring
  (load-theme 'ef-spring t))

(message "themes loaded!")
(provide 'init-themes)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 启动时加载亮色 `ef-spring'，并允许主题对重点语法使用粗体和斜体。
;; - 临时切换主题可运行 `M-x load-theme'；清除已加载主题可运行 `M-x disable-theme'。
;; - 若需固定暗色主题，把末尾的 `ef-spring' 改成已安装的 EF theme 名称。
;; - 本模块没有全局快捷键，主题选择由 Emacs 的标准命令完成。
