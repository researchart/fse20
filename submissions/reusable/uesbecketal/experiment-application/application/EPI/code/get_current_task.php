<?php
  session_start();
  $currentTask = $_SESSION["currentTask"];
  $tasks = $_SESSION["task"];
  echo json_encode( $tasks[$currentTask] );
?>
