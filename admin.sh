#!/bin/bash

#Config parameters
DBFILE="./test.udb"

#When you don't have a user database
if [ ! -e $DBFILE ] ; then
    echo "root:root1:123" > $DBFILE
fi
#DB file format
#username:passwd:pin

function write_password
#writes a password / pin / user combo into the databasefile
{
    local user=$1
    local passwd=$2
    local pin=$3
    #If we have the user already, delete it
    sed "/^$user.*/d" -i "$DBFILE" &> /dev/null
    #Write the new password
    echo "$user:$passwd:$pin" >> $DBFILE
    if [ $? -ne 0 ] ; then
	echo "Can't write database."
	exit 1
    fi
}

function user_selector
{
    local savedps3=$PS3
    PS3="Please select a user: "
    local selusertrg=$1

    select selecteduser in $(cat $DBFILE | cut -d ':' -f 1) ; do
	eval $selusertrg=$selecteduser
	break
    done
    PS3=$savedps3
}

function get_userline
{
    local user=$1
    local target=$2
    while read line ; do
	echo $line | cut -d ':' -f 1 | grep $user &>/dev/null
	if [ $? -eq 0 ] ; then
	    eval $target="$line"
	    return 0
	fi
    done < "$DBFILE"
    return 1
}

function get_pin
{
    local user=$1
    local target=$2
    get_userline "$user" line
    eval $target=$(echo "$line" | cut -d ':' -f 3)
}

function check_user
#Checks if given user is in the database
{
    local user=$1
    get_userline "$user" line
    return $?
}

PASSWD=2
PIN=3
function auth
#Checks passwd or pin
#ONLY WORKS ON EXISTING USER, check that before
{
    local user=$1
    local usrinp=$2
    local tochk=$3 #Can be PASSWD or PIN
    get_userline $user userline
    if [ "$(echo $userline | cut -d ':' -f $tochk)" == "$usrinp" ] ; then
	return 0
    fi
    return 1
}

function auth_passwd
#check if user provided validpasswd
{
    local user=$1
    local passwd=$2
    auth "$user" "$passwd" $PASSWD
}

function auth_pin
{
    local user=$1
    local pin=$2
    auth "$user" "$pin" $PIN
}

function validate
{
    #5 char
    local inp=$1
    local len=$2
    if [ ${#inp} -ne $len ] ; then
	return 1
    fi
}

function validate_username
{
    local user="$1"
    if [ $user == "root" ] ; then
	return 0
    fi
    validate "$user" 5
}

function validate_passwd
{
    local passwd=$1
    validate "$passwd" 5
}

function validate_pin
{
    local pin=$1
    echo $pin | grep "^[[:digit:]]\{3\}$" &> /dev/null
}

function validated_input
{
    local inptxt=$1
    local errtxt=$2
    local validator=$3
    local target=$4
    local doublecheck=$5
    local readextra=$6
    while [ 1 ] ; do
	local inp
	read -p "$inptxt " $readextra inp
	inp=$(echo $inp | tr [:upper:] [:lower:])
	echo
	$validator "$inp"
	if [ $? -ne 0 ] ; then
	    echo "$errtxt"
	    continue
	fi
	if [ "$doublecheck" == "true" ] ; then
	    local inp2
	    read -p "Please repeat: " $readextra inp2
	    inp=$(echo $inp | tr [:upper:] [:lower:])
	    echo
	    if [ "$inp2" != "$inp" ] ; then
		echo "Mismatch !"
		continue
	    fi
	fi
	break
    done
    eval $target=$inp
}

function create_user
{
    validated_input \
	"Please provide a username:" \
	"Please note that username must be 5 characters long" \
	validate_username \
	user
    
    check_user $user
    if [ $? -eq 0 ] ; then
	echo "User $user already exists !"
	return 1
    fi
 
    validated_input \
	"Please provide a password:" \
	"Please note that password must be 5 charachters long" \
	validate_passwd \
	passwd \
	"true" \
	-s

    validated_input \
	"Please provide a pin:" \
	"Please note that pin must be 3 digits" \
	validate_pin \
	pin \
	"true" \
	-s
    write_password "$user" "$passwd" "$pin"
    echo "New user created."
}

function input_user_and_check
{
    local target=$1
    echo "Please provide your username:"
    local userinp
    read userinp
    userinp=$(echo $userinp | tr [:upper:] [:lower:])
    validate_username $userinp
    if [ $? -ne 0 ] ; then 
	echo "Invalid username."	
	return 1
    fi
    check_user $userinp
    if [ $? -ne 0 ] ; then 
	echo "No such user." #can be a security issue, that an attacker can check if we have a given username	
	return 1
    fi
    eval $target=$userinp
}

function reset_passwd
{
    input_user_and_check user || return 1
    echo "Welcome $user"
    echo "Please provide your pin:"
    local pin
    read pin
    validate_pin $pin
    if [ $? -ne 0 ] ; then 
	echo "Invalid pin."
	return 1
    fi
    auth_pin "$user" "$pin"
    if [ $? -ne 0 ] ; then 
	echo "Wrong pin."
	return 1
    fi
    
    validated_input \
	"Please provide a NEW password:" \
	"Please note that password must be 5 charachters long" \
	validate_passwd \
	passwd \
	"true" \
	-s
    
    write_password "$user" "$passwd" "$pin" 
    echo "Password updated."
}
function loginuser
{
    local usernametarget=$1
    local usergiven=$2
    if [ -z $usergiven ] ; then
	input_user_and_check usergiven || return 1
    fi
    local passwd
    read -s -p "Please provide your passwd:" passwd
    passwd=$(echo $passwd | tr [:upper:] [:lower:])
    echo
    validate_passwd $passwd
    if [ $? -ne 0 ] ; then 
	echo "Invalid passwd."
	return 1
    fi
    auth_passwd "$usergiven" "$passwd"
    if [ $? -ne 0 ] ; then 
	echo "Wrong passwd."
	return 1
    fi

    eval $usernametarget=$usergiven
}

function change_passwd
{
    local user=$1
    local rootordered=$2
    if [ -z $rootordered ] ; then
        loginuser user "$user" || return 1
    fi

    validated_input \
	"Please provide a NEW password:" \
	"Please note that password must be 5 charachters long" \
	validate_passwd \
	passwd \
	"true" \
	-s

    get_pin "$user" pin
    write_password "$user" "$passwd" "$pin"
}
