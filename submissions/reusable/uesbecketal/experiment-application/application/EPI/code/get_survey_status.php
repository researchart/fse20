<?php
session_start();
require_once('sql_functions.php');

$status = [ "surveyquestion" => $_SESSION["question"] ];

error_log("SurveyQuestion: " . $_SESSION["question"]);

echo json_encode( $status);

?>
