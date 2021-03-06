#!/bin/bash

project_name=$1

function applypatch(){
    git_dir=`echo $(dirname $1) | sed 's/\/build\/aosp_diff\/'${project_name}'//g'`
    cd $git_dir
    date_value=`grep "Date: " $1`
    patchexist=`git log --pretty=format:"Date: %aD" | grep "$date_value"`

    file=$1
    if [ -z "$patchexist" ] ; then
        git am $1 >& /dev/null
        if [ $? == 0 ]; then
            echo "  patch appied   : ${file#*/build/aosp_diff/}"
        else
            echo "  conflict found : ${file#*/build/aosp_diff/}"
            git am --abort >& /dev/null
        fi
    fi
}

function scan_patch_files(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ] ; then
            scan_patch_files $1"/"$file
        else
            if [ ${file##*.} = "patch" ] ; then
                applypatch $1"/"$file
            fi
        fi
    done
}

if [ $# -ne 0 ] ; then
    echo "Apply patches ..."

    scan_patch_files $(pwd)"/build/aosp_diff/"$project_name

    echo "Apply patches done."
fi
