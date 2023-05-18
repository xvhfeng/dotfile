#!/bin/bash

function read-passwd() {
awk -F '=' "/\[$2\]/{a=1}a==1" $1 \
    | sed -e '1d' -e '/^$/d' -e '/^\[.*\]/,$d' \
    -e "/^$3=.*/! d" -e "s/^$3=//"
}
