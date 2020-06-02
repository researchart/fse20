<?php
  session_start();
  require_once('sql_functions.php');

  $results = $_POST['results'];
  if (!duplicateExtraSurvey($_SESSION['uuid'], $results[0]['QID'])){
    foreach ($results as $value) {
      insertExtraSurvey($_SESSION['uuid'], $value['QID'], $value['option'], $value['value']);
    }
    insertSurveyEvent($_SESSION['id'], $_SESSION['uuid'], 18, $_SESSION['question']+1);
  } else {
    echo "Error, question already filled in";
  }
  $_SESSION['question'] = $_SESSION['question'] + 1;
  error_log("Question : " . $_SESSION['question']);
  echo $_SESSION['question']
?>
