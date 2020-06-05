<?php
  session_start();
  $currentTask = $_SESSION["currentTask"] + 1;
  if ($currentTask >= $_SESSION["totalTasks"]) {
    $_SESSION["task_status"] = "complete";
    $_SESSION["task_stage"] = null;
    exit();
  }
  $_SESSION["task_stage"] = "coding";
  $_SESSION["currentTask"] = $currentTask;
  $tasks = $_SESSION["task"];
  echo json_encode( $tasks[$currentTask] );
?>
