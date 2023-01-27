<?php 


/* INSTRUCTIONS README
 * you can configure as many account reviews as you want for
 * each type of connector technology. Each configuration will upload a feed
 * to eramba */


/* the eramba server where you want to puload feeds */
$eramba_hostname = "https://eramba.cloud.eramba.org";
$eramba_username = "api";
$eramba_password = "2RoC!dbZ7jJHiAfvDQ";



/* AWS feeds are configured here 
 * you can add as many arrays you want, each would be 
 * a feed you want to put into the eramba instace confgiured
 * above
 */


$aws_configs = array(

	array(
		'feed_id' => '',
		'feed_title' => '',
		'feed_description' => '',
		'feed_title' => '',
		'aws_region' => '',
		'aws_profile' => '',
		'aws_tmp_file' => ''
	)

);



$region = "eu-west-1";
$profile = "aws_log_parser";
$tmp_csv_file_name = "tmp.csv";
$feed_id = "1";
$feed_title = "AWS eramba account";
$feed_description = "accounts used in AWS eramba";
$feed_type = "1";

?>
