<?php
  if (session_status() == PHP_SESSION_NONE) {
    session_start();
  }
  function getEmail() {
    return $_SESSION["email"];
  }
  function getTaskString() {
    echo "Task: " . ($_SESSION["currentTask"] + 1) . " of " . $_SESSION["totalTasks"];
  }
  function includeTasksJS() {
    if (basename($_SERVER["PHP_SELF"]) == "tasks.php") {
        echo '<script src="code/js/tasks.js"></script>';
    }
  }
  function includeSurveyJS() {
    if (basename($_SERVER["PHP_SELF"]) == "survey_3.php") {
        echo '<script src="code/js/extrasurvey.js"></script>';
    }
  }
  function courseCredit() {
    $result = getCreditInfo($_SESSION['id']);
    if ($result['name'] != "") {
      echo "<h4>Your course credit information is recorded as follows:</h4>";
      echo "<p>";
      echo "<b>ID:</b> ".$_SESSION['id']."<br>";
      echo "<b>Name:</b> ".$result['name']."<br>";
      echo "<b>Course Num:</b> ".$result['courseNum']."<br>";
      echo "<b>Course Name:</b> ".$result['courseName']."<br>";
      echo "<b>Instructor:</b> ".$result['instructor']."<br>";
      echo "<h4>Your instructor will be notified.</h4>";
      echo "<h4>You may print this page as your proof of completion.</h4>";
      echo "</p>";
    }
  }
?>
