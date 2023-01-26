#!/bin/bash
# Author: kristijan.sabic@eramba.org
# Tested on: Ubuntu 16.4, Centos ...
# Description: this script assumes you have pre-shared keys with linux systems you define in an array 
# and connects to them and pull their accounts (from /etc/passwd) and their respective descriptions
# it will store the output on a file under /tmp/

# define the list of servers you want to pull accounts
# these servers must have pre-shared keys so we can execute commands without 
# being asked for passwords
SERVER_LIST=(
        "root@demo-e.eramba.org" 
)

# make sure you have ssh command, otherwise dont run this
SSH=`command -v ssh`
if ! [ -x "$SSH" ] ; then
	echo "We could not find the command ssh ... exiting";
	exit;
fi

#command to execute remotely
# should work with ubuntu 16.x
CMD_ACCOUNTS="cat /etc/passwd | /usr/bin/awk -F : '{print \$1}'"
CMD_GROUPS="cat /etc/group"
CMD_LAST="for i in `cat /etc/passwd | cut -f1 -d:` ; do last --time-format iso -n1 $i  ; done"

# path where we'll store the output of every server
OUTPUT="/tmp/"

for i in ${SERVER_LIST[@]}; do

	# remove all previous files
	rm -f "$OUTPUT/accounts_linux_server_$i.csv"
	rm -f "$OUTPUT/groups_linux_server_$i.csv"
	rm -f "$OUTPUT/last_login_linux_server_$i.csv"

	# fetch data from the server using ssh
	echo $i
        $SSH $i $CMD_ACCOUNTS > $OUTPUT/accounts_linux_server_$i.csv
        $SSH $i $CMD_GROUPS > $OUTPUT/groups_linux_server_$i.csv
        $SSH $i $CMD_LAST> $OUTPUT/last_login_linux_server_$i.csv

	# now i need to build a single file that includes
	# user accounts and their groups
	for accounts in `cat $OUTPUT/accounts_linux_server_$i.csv` ; do 

		# remove old files
		rm -f $OUTPUT/accounts_linux_server_$i.csv;

		# i'll try to get from which groups the user accounts has assigned
		FIND_GROUPS=`grep $accounts $OUTPUT/groups_linux_server_$i.csv | cut -f1 -d: | awk -v ORS=\| '{print \$1}'`;
		if ! [ -z $FIND_GROUPS ]; then
			FIND_GROUPS=`echo $FIND_GROUPS | sed s/\,//g`;
			FIND_GROUPS=`echo $FIND_GROUPS | sed s/\|$//g`;
		else
			FIND_GROUPS="Member of no group";
		fi

		# try to fetch last login
		LAST_LOGIN_ACCOUNT=`grep ^$accounts $OUTPUT/last_login_linux_server_$i.csv | uniq | awk '{print $4}'` 
		if ! [ -z $LAST_LOGIN_ACCOUNT ] ; then
			LAST_LOGIN_ACCOUNT_MSG="Last login at $LAST_LOGIN_ACCOUNT";
		else
			LAST_LOGIN_ACCOUNT_MSG="No last login information available";
		fi
	
		# store all in a file
		echo "$accounts,$FIND_GROUPS,$LAST_LOGIN_ACCOUNT_MSG" >> $OUTPUT/accounts_eramba_feed_$i.csv
	done


	# delete this files
	rm -f $OUTPUT/accounts_linux_server_$i.csv
	rm -f $OUTPUT/groups_linux_server_$i.csv
	rm -f $OUTPUT/last_login_linux_server_$i.csv
done    

