#/usr/bin/env bash

case $1 in
	"-c")
		# 打开外接显示器(--auto:最高分辨率)，与笔记本液晶屏幕显示同样内容（克隆）
		xrandr --output VGA1 --same-as LVDS1 --auto
		;;
	"-cs")
		# 打开外接显示器(分辨率为1280x1024)，与笔记本液晶屏幕显示同样内容（克隆）
		xrandr --output VGA1 --same-as LVDS1 --mode 1280x1024
		;;
	"-el")
		# 打开外接显示器(--auto:最高分辨率)，设置为右侧扩展屏幕
		xrandr --output VGA1 --left-of LVDS1 --auto 
		;;
	"-er")
		# 打开外接显示器(--auto:最高分辨率)，设置为右侧扩展屏幕
		xrandr --output VGA1 --right-of LVDS1 --auto
		;;
	"-f")
		# 关闭外接显示器
		xrandr --output VGA1 --off
		;;
	"-oe")
		# 打开外接显示器，同时关闭笔记本液晶屏幕（只用外接显示器工作）
		xrandr --output VGA1 --auto --output LVDS1 --off
		;;
	"-oo")
		# 关闭外接显示器，同时打开笔记本液晶屏幕 （只用笔记本液晶屏）
		xrandr --output VGA1 --off --output LVDS1 --auto
		;;
	"")
		echo "-c: 打开外接显示器(--auto:最高分辨率)，与笔记本液晶屏幕显示同样内容（克隆）"
		echo "-cs: 打开外接显示器(分辨率为1280x1024)，与笔记本液晶屏幕显示同样内容（克隆）"
		echo "-er: 打开外接显示器(--auto:最高分辨率)，设置为右侧扩展屏幕"
		echo "-el: 打开外接显示器(--auto:最高分辨率)，设置为left侧扩展屏幕"
		echo "-f: 关闭外接显示器"
		echo "-oe: 打开外接显示器，同时关闭笔记本液晶屏幕（只用外接显示器工作）"
		echo "-oo: 关闭外接显示器，同时打开笔记本液晶屏幕 （只用笔记本液晶屏）"
		echo "如果使用awesome，modkey+ctrl+j,modkey+ctrl+k,切换不同的screen"
		;;

	"-h")
		echo "-c: 打开外接显示器(--auto:最高分辨率)，与笔记本液晶屏幕显示同样内容（克隆）"
		echo "-cs: 打开外接显示器(分辨率为1280x1024)，与笔记本液晶屏幕显示同样内容（克隆）"
		echo "-e: 打开外接显示器(--auto:最高分辨率)，设置为右侧扩展屏幕"
		echo "-f: 关闭外接显示器"
		echo "-oe: 打开外接显示器，同时关闭笔记本液晶屏幕（只用外接显示器工作）"
		echo "-oo: 关闭外接显示器，同时打开笔记本液晶屏幕 （只用笔记本液晶屏）"
		echo "如果使用awesome，modkey+ctrl+j,modkey+ctrl+k,切换不同的screen"
		;;
esac
