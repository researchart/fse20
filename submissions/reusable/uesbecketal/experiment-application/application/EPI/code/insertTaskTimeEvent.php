<?php
  session_start();
  require_once('sql_functions.php');
  $id = (int) $_SESSION['id'];
  $event = $_POST['event'];
  $eyetrackerTime = $_POST['eyetrackerTime'];
  error_log("Task Time Event triggered: " . $_SESSION["task_stage"] . " code: " . $event);
  if ($event == 6) {
    error_log("Changing to task stage coding");
    $_SESSION["task_stage"] = "coding";
  }
  $task = (int) $_SESSION['currentTask'];
  $uuid = $_SESSION['uuid'];
  insertTaskTimeEvent($id, $uuid, $event, $task, $eyetrackerTime);
?>
