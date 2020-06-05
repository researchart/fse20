<?php
  session_start();
  require_once('sql_functions.php');
  $event = 21;
  $unfilled = $_POST['unfilledRows'];
  $question = (int) $_SESSION['question'] + 1;
  insertSurveyEvent($_SESSION['id'], $_SESSION['uuid'], $event, $question, $unfilled);
?>
