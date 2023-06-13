################################################
 #  update version script
 #  when checkin code,run this script first
################################################
#! /bin/bash

filename=version.h
type=""
if [[ $# -gt 0 ]];then
    echo "$1"
    if [ "-h" == "$1" ]; then
        echo "Usage: $0 \$1 "
        echo "  \$1: publish type for version."
        echo "       publish type:"
        echo "           rls -> release"
        echo "           test -> test"
        echo "           dev -> develop"
        exit 1
    fi
    type=`echo $1 | tr [a-z] [A-Z]`
fi

old_ver=`cat $filename  | grep '#define' | grep 'VERSION' | awk -F" " '{print($NF)} '`

echo "============================================="
echo "THANK YOU CHOOSE UPDATE VERSION SCRIPT"
echo "Version:  v0.1"
echo "AUTHOR:   Seapeak.Xu"
echo "MAIL:     xvhfeng@126.com"
echo "---------------------------------------------"


ver_publish=`echo $old_ver | awk -F"-" '{print($1)}'`
ver_date=`echo $old_ver | awk -F"-" '{print($2)}'`
ver_time=`echo $old_ver | awk -F"-" '{print($3)}'`
ver_cnt=`echo $old_ver | awk -F"-" '{print($4)}'`

curr_date=`date +%Y%m%d`
curr_time=`date +%H%M%S`

echo "current version file ->   $filename"
echo ""
echo "last version ->           $old_ver"
echo "last version publish ->   $ver_publish"
echo "last version datetime ->  $ver_date-$ver_time"
echo "last version numbs ->     $ver_cnt"

echo "now datetime ->           $curr_date-$curr_time"
echo "---------------------------------------------"

i_vdate=`expr $ver_date + 0`
i_vtime=`expr $ver_time + 0`
i_cdate=`expr $curr_date + 0`
i_ctime=`expr $curr_time + 0`
i_vcnt=`expr $ver_cnt + 0`

if [[ $i_vdate -gt $i_cdate ]];then
    echo "now -> $curr_date is before version date -> $ver_date"
    echo "Please check it"
    exit 1
fi

vers=1
if [[ $i_vdate -eq $i_cdate ]];then
    vers=$(($i_vcnt + 1))
fi

sver=`printf "%04d" $vers`

if [ "" = "$type" ];then
    type=`echo $ver_publish | tr [a-z] [A-Z]`
fi

new_version=$type-$curr_date-$curr_time-$sver

echo "====>>>> Update $old_ver to $new_version <<<<===="
echo ""

# not modify file
sed -e "s/$old_ver/$new_version/g" $filename

read -p "====>> Are you sure modify the version(y/n)? " -n 1 -r
echo    # (optional) move to a new line
echo ""
echo "---------------------------------------------"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #modify file
    sed -i "s/$old_ver/$new_version/g" $filename
    # do dangerous stuff
    echo "*****=== Update the version success!!! ===*****"
    echo ""
    echo "*****=== $new_version ===****"
    echo "" 
    echo "FINISH"
    exit 0
fi

echo "^^^^^=== Giveup updating the version ===^^^^^"
echo "FINISH"

