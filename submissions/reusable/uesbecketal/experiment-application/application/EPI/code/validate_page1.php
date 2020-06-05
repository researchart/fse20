<?php
  session_start();
  require_once('sql_functions.php');
  if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = (int) $_SESSION['id'];
    $totalxp = filter_var($_POST['totalxp'] , FILTER_VALIDATE_INT);
    $jobxp = filter_var($_POST['jobxp'] , FILTER_VALIDATE_INT);
    $education = filter_var($_POST['education'] , FILTER_SANITIZE_STRING);
    $institution = filter_var($_POST['institution'] , FILTER_SANITIZE_STRING);
    $major = filter_var($_POST['major'] , FILTER_SANITIZE_STRING);
    $degree = filter_var($_POST['degree'] , FILTER_SANITIZE_STRING);
    $year = filter_var($_POST['year'] , FILTER_SANITIZE_STRING);
    $gpa = filter_var($_POST['gpa'] , FILTER_SANITIZE_STRING);
    $origin = filter_var($_POST['origin'] , FILTER_SANITIZE_STRING);
    $language = filter_var($_POST['language'] , FILTER_SANITIZE_STRING);
    $fluency = filter_var($_POST['fluency'] , FILTER_VALIDATE_INT);
    error_log("fluency: " . $fluency);
    if (empty($fluency)) {
      $fluency = -1;
    }
    error_log("fluency2: " . $fluency);
    $colorBlind = isset($_POST['colorBlind']) ? 1 : 0;
    $lowVisual = isset($_POST['lowVisual']) ? 1 : 0;
    $blind = isset($_POST['blind']) ? 1 : 0;
    $lowAural = isset($_POST['lowAural']) ? 1 : 0;
    $deaf = isset($_POST['deaf']) ? 1 : 0;
    $motorImpaired = isset($_POST['motorImpaired']) ? 1 : 0;
    $learning = isset($_POST['learning']) ? 1 : 0;
    $_SESSION['year'] = $year;
    $uuid = $_SESSION['uuid'];
    insertSurvey1($id, $uuid, $totalxp, $jobxp, $education, $institution, $major, $degree, $year, $gpa, $origin, $language, $fluency, $colorBlind, $lowVisual, $blind, $lowAural, $deaf, $motorImpaired, $learning);
    
    insertTimeEvent($_SESSION['id'], $_SESSION['uuid'], 4);

    $_SESSION['page'] = "survey_2.php";
    header("Location: ../survey_2.php");
  }
?>
