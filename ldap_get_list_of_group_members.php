<?php 

# author: kisero@gmail.com
# what it does: 
#	1/ it connects to an LDAP directory based on settings defined ina configuration file (ldap_config.php) 
# 	2/ pulls the list of users and their last login 
#	3/ outputs in CSV format: account,NULL,last_login

# check if the config file is there
# and load it
# otherwise exit with an error
$config_file_path="ldap_credentials/ldap_config.php";
if ( file_exists($config_file_path) ) {
	include($config_file_path);
} else {
	echo "We could not find an ldap config file at ($config_file_path), exiting\n";
}

# make sure server, port, username, password, base directory, filter and account/lastlogin attributes all have
# some defined values, they are all mandatory
foreach ($ldap_config as $var) {
	if ( empty($var) ) {
		echo "We found LDAP configurations to be empty, please review the config file and try again, exiting\n";
		exit;
	}
}

# now we try to connect to the ldap server, if it does not work 
# we know server, port, user or pass is wrong
$ldap_server=$ldap_config['server'];
$ldap_port=$ldap_config['port'];

$ldapconn = ldap_connect($ldap_server, $ldap_port) 
	or die("Could not connect to serer ($ldaphost) on port ($port) .. check settings, exiting");

if ($ldapconn) {

	$ldap_username=$ldap_config['username'];
	$ldap_password=$ldap_config['password'];
	
	ldap_set_option($ldapconn, LDAP_OPT_PROTOCOL_VERSION, 3);
	ldap_set_option($ldapconn, LDAP_OPT_REFERRALS, 0);

	$ldapbind = ldap_bind($ldapconn, $ldap_username, $ldap_password);

	if (!$ldapbind) {
		echo "LDAP bind failed, credentials are wrong .. exiting\n";
		exit;
	}
}

# if we made it all the way here, connection worked and so we can now 
# make the query based on the config we got
if ($ldapbind) {

	$ldap_base_directory=$ldap_config['base_directory'];
	$ldap_filter=$ldap_config['filter'];
	$ldap_account_attribute=$ldap_config['account_attribute'];
	$ldap_lastlogon_attribute=$ldap_config['lastlogon_attribute'];

	$ldap_query=ldap_search($ldapconn, $ldap_base_directory, $ldap_filter, array($ldap_account_attribute,$ldap_lastlogon_attribute));

	if (!$ldap_query) {
		echo "error with the filter query, exiting\n";
		exit;
	}

	# this gets the response from the query
	$info = ldap_get_entries($ldapconn, $ldap_query);

	# this parses the response on a CSV format
	foreach($info as $id) {
	
		$login=$id[strtolower($ldap_account_attribute)]['0'];
		$ad_time=intval($id[strtolower($ldap_lastlogon_attribute)]['0']);

		if ( !empty($login) ) {
			if ($ad_time > 0) {
				$pretty_date="Last successful logon on ".date('d-M-Y',$ad_time/10000000-11676009600)."";
			} else {
				$pretty_date="Unknown or never logged in";
			}
	
			echo "$login,NULL,$pretty_date\n";
		}
	}

} else {
	echo "we lost the bind, this should not happen..exiting\n";
	exit;
}

?>
