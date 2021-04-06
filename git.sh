#!/bin/bash

set -e
set -u
cd $(dirname $0)
exclude=0
action="none"

while [ $# -gt 0 ]; do
    case $1 in
    status|push|pull|diff) action=$1; shift;;
    -x) exclude=1; shift;;
    *) echo "bad argument '$1'"; exit 1;;
    esac
done
if [ $action == "none" ]; then
    echo "Usage: $0 [-x] status|push|pull|diff"
    exit 1
fi

#for i in $( find -maxdepth 1 -type d | grep -v '^\.$' | grep -v 'examen' ); do
prev_skipped=0
for i in $( find -maxdepth 1 -type d | grep -v '^\.$' ); do
    if [ $exclude -eq 1 ]; then
        if echo $i | grep -e ozt-dbperf -e ozt-tile >/dev/null; then
            if [ $prev_skipped -eq 0 ]; then
                echo -n "== skipping $i"
                prev_skipped=1
            else
                #echo -n ", $i"
                echo -n "."
            fi
            continue
        fi
    fi
    if [ $prev_skipped -eq 1 ]; then
        echo
    fi
    prev_skipped=0
    #echo
    echo ========== $i =============
    cd $i
    set +e
    case $action in
    diff) git diff | cat ;;
    status) git status | grep -v -e "Your branch is up to date with 'origin/master'." -e "nothing to commit, working tree clean" ;;
    *) git $action ;;
    esac
    set -e
    cd ..
done
