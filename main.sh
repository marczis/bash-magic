#!/bin/bash

source admin.sh
source menu.sh
source log.sh

function m_log_Read
{
    local user=$1
    read_log "$user"
    if [ $? -ne 0 ] ; then
	pressanykey
    fi
}

function m_log_Append
{
    local user=$1
    echo "Type message:"
    local ifssave=$IFS
    IFS="\n"
    local msg
    read msg
    IFS=$ifssave
    write_log "$user" "$msg"
}

function m_log_Read_of_user
{
    clear
    local x
    user_selector x
    m_log_Read $x
}

function m_log_Append_to_user
{
    clear
    local x
    user_selector x
    m_log_Append $x
}

function pressanykey
{
    echo "(Press any key to continue)"
    read -n 1 -s #Just give a chance to read the message :)
}

function m_acc_Change_password
{
    local user=$1
    local rootordered=$2
    change_passwd "$user" "$rootordered"
    if [ $? -ne 0 ] ; then
	echo "Failed to change your password."
    else
	echo "Password changed."
    fi
    pressanykey
}

function m_acc_Change_password_for_user
{
    local x
    user_selector x
    m_acc_Change_password $x "root"
}

function m_acc_Create_account
{
    create_user
    if [ $? -ne 0 ] ; then
	pressanykey
    fi
}

function m_main_Log
{
    local user=$1
    if [ "$user" == "root" ] ; then
	menu "Log menu" "Log: " "m_log" "$user" "Read" "Append" "Read of user" "Append to user"
    else
	menu "Log menu" "Log: " "m_log" "$user" "Read" "Append" 
    fi
}

function m_main_Account
{
    local user=$1
    if [ "$user" == "root" ] ; then
	menu "Account menu" "Account: " "m_acc" "$user" "Change password" "Change password for user" "Create account"
    else
	menu "Account menu" "Account: " "m_acc" "$user" "Change password"
    fi
}

#Main
#Password reset is special, work without menu
if [ "$1" == "-r" ] ; then
    reset_passwd
    exit
fi
loginuser user || exit 1

    while [ 1 ] ; do
	menu "Main menu" "Main: " "m_main" "$user" "Log" "Account"
	echo "Are you sure (Y/N)?"
	read -n 1 ans
	ans=$(echo $ans | tr [:upper:] [:lower:])
	if [ "$ans" == "y" ] ; then
	    break
	fi
    done
