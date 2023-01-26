<?php

require 'vendor/autoload.php';
require 'credentials.php';

use Aws\Iam\IamClient;
use GuzzleHttp\Client;


/*
 * copy the file credentials.php.template
 * to credentials.php and complete all fields before you run this script
 *
 

/* first we pull accounts and their roles from AWS 
 * into an array that we can then easily push into a
 * csv file */

$fp = fopen($tmp_csv_file_name, 'w');

$aws = IamClient::factory(array(
	'region' => $region,
	'version' => 'latest',
	'profile' => $profile,
));

$result = $aws->listUsers([
]);

foreach($result['Users'] as $users) {

	$username = $users['UserName'];

	$tmp_array_groups = array();
	$result_groups = $aws->listGroupsForUser([
		'UserName' => $users['UserName'],
	]);

	foreach($result_groups['Groups'] as $groups) {
		$group_name = $groups['GroupName'];
		array_push($tmp_array_groups,$group_name);
	}
	$tmp_string_groups = implode("|",$tmp_array_groups);
	if ( empty($tmp_string_groups) ) { 
		$tmp_string_groups = "na";
	}
	$tmp_csv_row = array($username,$tmp_string_groups,"na");
	fputcsv($fp,$tmp_csv_row);

}

fclose($fp);




$client = new GuzzleHttp\Client();

$response = $client->request('POST', "$eramba_hostname/api/account-reviews/account-review-feeds/$feed_id", [

	'auth' => [$eramba_username, $eramba_password],
	'multipart' => [
		[
			'name'     => $tmp_csv_file_name,
			'contents' => file_get_contents($tmp_csv_file_name),
		]
	]
]);

$code = $response->getStatusCode(); // 200
$reason = $response->getReasonPhrase(); // OK

echo "$code / $reason\n";

unlink($tmp_csv_file_name);

?>
