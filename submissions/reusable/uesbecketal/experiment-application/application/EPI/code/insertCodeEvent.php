<?php
  session_start();
  require_once('sql_functions.php');
  $id = (int) $_SESSION['id'];
  $task = (int) $_SESSION['currentTask'];
  
  $event = $_POST['event'];
  $entry = $_POST['entry'];
  $output = $_POST['output'];
  $eyetrackerTime = $_POST['eyetrackerTime'];

  $timer = $_POST['timer'];
  $timerID = $_POST['timerID'];
  if ($whichtimer == "sample") {
    $_SESSION['sampletimer'] = $timer;
  }
  if ($whichtimer == "task") {
    $_SESSION['tasktimer'] = $timer;
  }

  insertCodeEvent($id, $_SESSION['uuid'], $event, $task, $entry, $output, $eyetrackerTime);
  echo $id, $event, $task, $entry, $eyetrackerTime;
?>
