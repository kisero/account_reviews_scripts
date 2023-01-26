<?php

require 'vendor/autoload.php';

use Aws\S3\S3Client;
use GuzzleHttp\Client;

/* first we pull accounts and their roles from AWS */


//Create an S3Client
$iam_client = new Aws\S3\S3Client([
    'version' => 'latest',
    'region' => 'us-east-2'
]);



?>