<?php
  session_start();
  require_once('sql_functions.php');
  insertTimeEventSurvey($_SESSION['id'], $_SESSION['uuid'], 17);
  $_SESSION['page'] = "survey_3.php";
  header("Location: ../survey_3.php");
?>
