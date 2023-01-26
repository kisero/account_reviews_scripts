#!/bin/bash

# Author: kristijan.sabic@eramba.org
# Tested on: Ubuntu 16.x 
# Description: This script pulls from AWS the list of IAM users and shows their last login as the description field.
# you need to make sure aws cli is installed on the system and your keys are correctly stored, otherwise the command will fail


# make sure you have awscli command, otherwise dont run this
CMD=`command -v aws`
if ! [ -x "$CMD" ] ; then
	echo "We could not find the command aws ... exiting";
	exit;
fi

# to query users in AWS you need a key
# check amazon how to get keys and where to store them on your linux
TMP_FILE=`mktemp`;
AWS_ACCOUNTS=`$CMD iam list-users --output text > $TMP_FILE`

IFS=$'\n'
for i in `cat $TMP_FILE`; do

	ACCOUNT=`echo $i | awk '{print $2}' | sed s/"arn:aws:iam::430979167908:user\\/"// | sed s/"\,$"//`;	
	LAST_LOGIN=`echo $i | awk '{print $4}'`;

	# i need to check if the last login is valid .. if not, the user never loged in
	# this is the format i should expect: 2018-04-14T18:27:34Z
	if ! [[ $LAST_LOGIN =~ ^[0-9] ]]; then
		LAST_LOGIN_MSG="The account was never used";
	else
		LAST_LOGIN_MSG="Last login on $LAST_LOGIN"	
	fi

	# now i want to pull all group policies that this user has attached
	TMP_FILE_POLICIES=`mktemp`;
	$CMD iam list-attached-user-policies --user-name $ACCOUNT > $TMP_FILE_POLICIES;
	ACCOUNT_POLICIES=`cat $TMP_FILE_POLICIES | grep PolicyName | cut -f 2 -d: | sed s/^" "//g | sed s/\"//g | sed s/,$// | awk -v ORS=\| '{print \$1}'`
	
	if ! [ -z $ACCOUNT_POLICIES ]; then
		ACCOUNT_POLICIES=`echo $ACCOUNT_POLICIES | sed s/\,//`; 
		ACCOUNT_POLICIES=`echo $ACCOUNT_POLICIES | sed s/\|$//`; 
	fi

	# remove the temporal file
	if [ -f $TMP_FILE_POLICIES ] ; then
		rm -f $TMP_FILE_POLICIES
	fi
	
	echo $ACCOUNT,$ACCOUNT_POLICIES,$LAST_LOGIN_MSG;
done

# remove the temporal file
if [ -f $TMP_FILE ] ; then
	rm -f $TMP_FILE
fi

