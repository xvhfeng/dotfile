;;; init-theme.el --- Tokyo Night 主题配置 -*- lexical-binding: t; -*-

(defun my/theme-apply-visibility ()
  "提高光标与当前行在深色主题中的可见性。"
  (require 'hl-line)
  ;; 默认使用方块光标；Which-Key 等专用 Buffer 仍可自行隐藏光标。
  (setq-default cursor-type 'box)
  ;; 紫红色与 Tokyo Night Moon 的蓝灰背景形成高对比。
  (set-face-attribute 'cursor nil
                      :background "#ff5ea0"
                      :foreground "#1f2335")
  ;; 使用更亮的蓝紫色区分当前行与普通背景。
  (set-face-attribute 'hl-line nil
                      :background "#2a2f4a"
                      :extend t))

;; 中文说明：主题单独成模块并紧随 init-base 加载，使后续界面与插件能继承
;; Tokyo Night 的颜色；只在主题包成功加载后切换，不因网络或安装问题中断启动。
(condition-case err
    (use-package tokyo-night
      ;; 中文说明：上游仓库未提供 ELPA 的 *-pkg.el，显式收集所有 .el，
      ;; 让 straight 正确将主题文件加入 custom-theme-load-path。
      :straight (:host github :repo "bbatsov/tokyo-night-emacs" :files ("*.el"))
      :demand t
      :config
      ;; 中文说明：关闭此前已启用主题，避免 EF 等旧主题与 Tokyo Night 面孔叠加。
      (mapc #'disable-theme custom-enabled-themes)
      ;; 中文说明：默认使用最深的夜间变体；可通过 M-x tokyo-night-select 切换。
      (load-theme 'tokyo-night-moon t))
  (error
   ;; 中文说明：首次安装失败时保留现有界面，不让主题问题阻断 Emacs 启动。
   (message "Tokyo Night 未加载：%s" (error-message-string err))))

(my/theme-apply-visibility)

(provide 'init-theme)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 默认启用 `tokyo-night' 深色主题。
;; - 可用 `M-x tokyo-night-select' 切换 night、storm、moon、day 四种变体。
;; - 主题包不可用时，启动会给出中文提示并保留已有主题。
;;; init-theme.el ends here
