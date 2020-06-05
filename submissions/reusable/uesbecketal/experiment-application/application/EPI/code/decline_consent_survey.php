<?php
  session_start();
  require_once('sql_functions.php');
  insertTimeEventSurvey($_SESSION['uuid'], 16);
  $_SESSION['page'] = "declined.php";
  header("Location: ../declined.php");
?>
