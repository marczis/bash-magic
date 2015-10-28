#!/bin/bash
#NOTE This file is not part of the solution, just used during the development to test subparts of the program.

source admin.sh
source menu.sh
source log.sh

function test_write_password
{
    rm $DBFILE
    for i in {1..10} ; do
	write_password "user$i" "pass$i" "$i"
    done
cat >> shouldbe <<EOF
user1:pass1:1
user2:pass2:2
user3:pass3:3
user4:pass4:4
user5:pass5:5
user6:pass6:6
user7:pass7:7
user8:pass8:8
user9:pass9:9
user10:pass10:10
EOF
    diff $DBFILE shouldbe
    ret=$?
    rm shouldbe
    return $ret
}

function test_check_user
{
    write_password "testuser" "pass" "124"
    check_user "testuser" || return 1
    check_user "XXADFQEADCD" && return 1
    return 0
}

function test_auth_passwd
{
    write_password "testuser" "secret" "234"
    auth_passwd "testuser" "secret" || return 1
    auth_passwd "testuser" "adfvf"  && return 1
    return 0
}

function test_auth_pin
{
    write_password "testuser" "secret" "123"
    auth_pin "testuser" "123" || return 1
    auth_pin "testuser" "000" && return 1
    return 0
}

function test_val_user
{
    validate_username "longerthanshouldbe" && return 1
    validate_username "shor" && return 1
    validate_username "okoko" || return 1
    return 0
}

function test_get_pin
{
    write_password "testuser" "secret" "123"
    get_pin "testuser" pin
    if [ "$pin" != "123" ] ; then
	return 1
    fi
    return 0
}

function test_val_passwd
{
    validate_passwd "longerthanshouldbe" && return 1
    validate_passwd "shor" && return 1
    validate_passwd "okoko" || return 1
    return 0
}

function test_val_pin
{
    validate_pin "1234" && return 1
    validate_pin "ABC" && return 1 
    validate_pin "12" && return 1
    validate_pin "123" || return 1
    return 0
}

function test_create_user
{
    create_user
}

function test_reset_passwd
{
    reset_passwd    
}

function test_change_passwd
{
    change_passwd    
}

#----------------------------------------------
function menu_First_item
{
    echo "first"
}

function menu_Second_item
{
    echo "second"
}

function submenu_Sub_First
{
    echo "Submenu first"
}
function menu_Submenu
{
    menu "SubMenuX" "Submenu: " "submenu" "Sub First"
}

function test_menu
{
    menu "TitleTitleTitle" "Main: " "menu" "First item" "Second item" "Submenu"
}

function test_log_write
{
    write_log "test1" "TestMessage"
}

function test_log_read
{
    read_log "test1"
}

function test_user_sel
{
    local x
    user_selector x
    echo "Selected $x"
}
#----------------------------------------------
#Test execution logic, do not change these, add tests before this line.
if [ -z $1 ] ; then
    exit
fi

if [ "$2" == "debug" ] ; then
    set -x
fi

test_$1
if [ $? -eq 0 ] ; then
    echo "Passed."
else
    echo "Failed."
fi
set +x

