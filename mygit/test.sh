#!/bin/bash

. read-passwd-cfg.sh
vv=$(read-passwd passwd.cnf gitee pwd)
echo $vv
