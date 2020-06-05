<?php
  session_start();
  require_once('sql_functions.php');
  error_log("hiho");
  if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = (int) $_SESSION['id'];
    $concepts= $_POST['concepts'];
    $design= $_POST['design'];
    $comments= $_POST['comments'];
    $codeswitch = $_POST['codeswitch'];
    insertFeedback($id, $concepts, $design, $comments, $codeswitch);
    insertTimeEvent($_SESSION['id'], $_SESSION['uuid'], 11);
  }
  $_SESSION['page'] = "finished.php";
?>
