<?php
  session_start();
  require_once('sql_functions.php');
  insertTimeEvent($_SESSION['id'], $_SESSION['uuid'], 3);
  $_SESSION['page'] = "declined.php";
  header("Location: ../declined.php");
?>
