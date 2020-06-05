<?php
  session_start();
  require_once('sql_functions.php');
  if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $email = filter_var($_POST["email"], FILTER_SANITIZE_EMAIL);
    filter_var($email, FILTER_VALIDATE_EMAIL);
    $_SESSION["email"]=$email;
    if (duplicateEmail($email)) {
      $_SESSION['page'] = "duplicate.php";
      header("Location: ../duplicate.php");
      exit();
    } 

    $_SESSION['id'] = insertUser($email);


    insertTimeEvent($_SESSION['id'], $_SESSION['uuid'],  1);
    $_SESSION['page'] = "informed_consent.php";
    error_log("page: " . $_SESSION['page']);
    header("Location: ../informed_consent.php");
    exit();
  }
?>
