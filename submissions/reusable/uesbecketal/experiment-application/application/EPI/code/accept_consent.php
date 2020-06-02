<?php
  session_start();
  require_once('sql_functions.php');
  insertTimeEvent($_SESSION['id'], $_SESSION['uuid'], 2);

  $_SESSION['page'] = "survey_1.php";
  header("Location: ../survey_1.php");
?>
