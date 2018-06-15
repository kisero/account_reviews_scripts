#!/bin/bash

# Author: kristijan.sabic@eramba.org
# Tested on: Ubuntu 16.4 MariaDb 10.x 
# Description: This script drops a file on /tmp/mysql_accounts_for_server_$servername.csv with the list of accounts and grants 
# You can define one or more MySQL/MariaDB servers on the file database_db.txt.
# This file must have each server as a row and with this exact syntax: server(space)username(space)password
# for example:
# localhost root root

# you need to define a database_db.txt file with three columns separated by a space
# where each column (all mandatory) is: server username password
DB_CREDENTIALS="database_db.txt";
if ! [ -f $DB_CREDENTIALS ]; then 
	echo "cant continue, the file with the servers and credentials is not there....exiting"
	exit;
fi

# you need mysql client otherwise things wont work
MYSQL_CLIENT=`command -v mysql`
if ! [ -x "$MYSQL_CLIENT" ] ; then
	echo "We could not find the mysql client... exiting";
	exit;
fi

# for every mysql server on that file, i pull the users and store the output
# on the output file defined here
OUTPUT="/tmp/"

IFS=$'\n'
for i in `cat $DB_CREDENTIALS`; do
	SERVER=$(echo $i | awk '{print $1}');
	USER=$(echo $i | awk '{print $2}');
	PASS=$(echo $i | awk '{print $3}');

	# remove old file
	if [ -f "$OUTPUT/mysql_accounts_for_server_$SERVER.csv" ]; then
		rm "$OUTPUT/mysql_accounts_for_server_$SERVER.csv"
	fi

	# get list of users from the server 
	CMD="$MYSQL_CLIENT -s -h $SERVER -u $USER -p$PASS -e  \"Select User, Host FROM  mysql.user;\"";

	for accounts in `eval $CMD | grep -v User`; do
		ACCOUNT=`echo $accounts | awk '{print $1}'`;		
		HOST=`echo $accounts | awk '{print $2}'`;		

		# get the "grants" for each one of this users
		TMP_FILE=`mktemp`;
		GRANTS_CMD=`$MYSQL_CLIENT -s -h $SERVER -u $USER -p$PASS -e  "SHOW GRANTS FOR '$ACCOUNT'@'$HOST'" | sed s/\'//g | sed -e :a -e '$!N; s/\n/|/; ta'`;
		#echo "$GRANTS_CMD";

		# remove tmp files
		if [ -f $TMP_FILE ] ; then
			rm -f $TMP_FILE
		fi

		echo "$ACCOUNT@$HOST","$GRANTS_CMD","None" >> "$OUTPUT/mysql_accounts_for_server_$SERVER.csv"
	done
done


