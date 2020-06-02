<?php
  session_start();

  $status = [
    "task_status" => $_SESSION["task_status"],
    "task_stage" => $_SESSION["task_stage"],
    "current_task" => $_SESSION["currentTask"],
    "total_tasks" => $_SESSION["totalTasks"],
    "survey_question" => $_SESSION["question"]
  ];
  error_log("Status: " . $_SESSION["task_status"]);
  error_log("Stage: " . $_SESSION["task_stage"]);
  error_log("Current Task: " . $_SESSION["currentTask"]);
  error_log("Total_tasks: " . $_SESSION["totalTasks"]);
//  if ($_SESSION["task_status"] == "in progress") {
//    $status["current_timer"]s
//  }
  echo json_encode( $status );
  
?>
