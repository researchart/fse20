<?php
    $language = $_POST['language'];
    $taskCfg = json_decode(file_get_contents("../code/studyConfig.json"));
    $i = 0;
    foreach ($taskCfg->tasks as $taskRec) {
      $task[$i]['taskNum'] = $taskRec->taskNum;
      switch($language) {
        case 1:
          $task[$i]['codeSample'] = $taskRec->codeSampleL1;
          break;
        case 2:
          $task[$i]['codeSample'] = $taskRec->codeSampleL2;
          break;
      }
      $task[$i]['taskDesc'] = $taskRec->taskDesc;
      $task[$i]['taskOutput'] = $taskRec->taskOutput;
      $task[$i]['timeSample'] = $taskRec->timeSample;
      $task[$i]['timeTask'] = $taskRec->timeTask;
      $i++;
    }
    echo json_encode( $task );
?>