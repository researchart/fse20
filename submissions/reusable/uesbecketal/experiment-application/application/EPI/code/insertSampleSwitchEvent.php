<?php
  session_start();
  require_once('sql_functions.php');
  $id = (int) $_SESSION['id'];
  $event = $_POST['event'];
  $task = (int) $_SESSION['currentTask'];
  $samplename= $_POST['samplename'];
  $eyetrackerTime = $_POST['eyetrackerTime'];
  $uuid = $_SESSION['uuid'];
  error_log("Switch event: " . $id . " " . $event . " " . $task . " entry:" . $samplename);
  insertSampleSwitchEvent($id, $uuid, $event, $task, $samplename,$eyetrackerTime);
  echo $id, $event, $task, $samplename;
?>
