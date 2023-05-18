#!/usr/bin/env sh

######################################################################
# @author      : xuhaifeng (xuhaifeng@P_HAIFENGXU-MB2)
# @file        : compose-commit-msg
# @created     : Sunday Nov 20, 2022 21:55:51 CST
#
# @description : re-buld commit message
######################################################################


# 获取当前分支
filename=version
line=$(head -n +1 .git/HEAD)
branch=${line##*/}
echo "branch: $branch"



# 获取变更号
code=`cat $filename  | grep '#define' | grep 'VERSION' | awk -F" " '{print($NF)} '`
#user=`cat .git/system-change-code.txt | grep systemChangeCode`
echo "code: $code"

# 获取当前提交者的信息
user=`git config user.name`
echo "user: $user"

if [ -z "$code" ] ; then
echo "NEED SYSTEM-CHANGE-CODE";
exit 1;
fi

# $1 参数 就是 .git/COMMIT_EDITMSG 文件
# cat $1 读取 git commit -m 输入的提交信息
# 组合提交信息
commit=$(cat $1)
echo "所有参数: $*"

echo "branch:${branch}"
echo "user:${user}"
echo "code-version: [$code]"
echo "commit-msg: $commit"

# 将组合的信息重新输出到 .git/COMMIT_EDITMSG 文件
echo "Branch: ${branch}" > "$1"
echo "User: ${user}" >> "$1"
echo "Code-version: $code" >> "$1"
echo "Message:" >> "$1"
echo "$commit" >> "$1"
