#!/bin/bash

function write_log
{
    local user=$1
    shift
    local msg=$*
    echo "[ $(date +%F\ %R:%S ) ] $msg" >> $user.log
}

function read_log
{
    local user=$1
    if [ -e $user.log ] ; then
	less $user.log
    else
	echo "EMPTY LOG"
	return 1
    fi
    return 0
}
