<?php require_once("code/functions.php"); ?>
<?php require_once("code/sql_functions.php"); 

if(!isset($_SESSION['uuid'])) {
  $uniqueid = uniqid();
  $_SESSION['uuid'] = $uniqueid;
  setcookie("uuid", $uniqueid);
  error_log("resetting cookie");
  $_SESSION['question'] = 0;
}

if (!isset($_SESSION['page'])) {
  $_SESSION['page'] = basename($_SERVER["PHP_SELF"]);
} else {
  if (basename($_SERVER["PHP_SELF"]) != $_SESSION['page']) {
      error_log("redirecting... " . basename($_SERVER["PHP_SELF"]) . " should be: " . $_SESSION['page']);
      header("Location: ".$_SESSION['page']);
  }
}

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Language Study</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <script src="code/js/reloadfix.js"></script>
    <?php includeTasksJS() ?>
    <?php includeSurveyJS() ?>
  </head>
  
  <body ondragstart="return false;" ondrop="return false;">
      <div id="wrapper" class="wrappermargin">
