#!/bin/bash

src_info_list=$(python queue.py)

list=(${src_info_list//;/ })
#echo ${list[@]}
#echo ${list[1]}

count=0
for v in "${list[@]}"
do
    FUNC_NAME=`echo ${v} | cut -d , -f 1`
    echo $FUNC_NAME
    SRC_URL=`echo ${v} | cut -d , -f 2`
    echo $SRC_URL
    #echo "$FUNC_NAME and $SRC_URL"
	
	if [ $count -eq 0 ] ; then
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'

		apt-get update
		apt-get install azure-functions-core-tools-3 unzip -y
	fi
    source ./deploysrc.sh $FUNC_NAME $SRC_URL
	
	count=$((count++))
done
