<?php
  session_start();
  require_once('sql_functions.php');
  $event = $_POST['event'];
//  insertTimeEventSurvey($_SESSION['id'], $_SESSION['uuid'], $event);
  $_SESSION['page'] = "feedback.php";
?>
