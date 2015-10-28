#!/bin/bash

OFF=0
BOLD=1
UNDERSCORE=4
BLINK=5
REVERSE=7
CONCEALED=8

FG=3
BG=4
BLACK=0
RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6
WHITE=7

function chcolor
#Change color, usage: chcolor "$OFF;$FG$CYAN"
{
    echo -e -n "\033[${1}m"
}

function title
{
    chcolor "$OFF;$FG$GREEN"
    echo "$titl" ; echo
    chcolor "$OFF;$FG$WHITE"
}

function menu
{
    local titl=$1
    local prompt=$2
    local prefix=$3
    local param=$4
    shift 4

    while [ 1 ] ; do
	clear
	title $titl
	PS3="$prompt"

	local ifs_save=$IFS
	IFS=''
	select i in $* exit ; do
	    IFS=$ifs_save
	    if [ "$i" == "exit" ] ; then
		return
	    fi
	    ${prefix}_$(echo $i | sed 's/ /_/g') $param
	    break
	done
    done
}

#function 
