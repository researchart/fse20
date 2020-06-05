<?php
  session_start();
  require_once('sql_functions.php');

  // Getting info from request
  $codefilename = "Task1.java";
  $id = (int) $_SESSION['id'];
  $event = $_POST['event'];
  $eyetrackerTime = $_POST['eyetrackerTime'];
  $currenttask = (int) $_SESSION['currentTask']+1;
  $t = $_SESSION['task'];
  $tasks = $t[$currenttask-1];
  $base = $tasks['base'];
  //error_log("T: ".implode(", ", $t[0])." base: ".$base. "currenttask: ".$currenttask);
  $maxtime = 12;
  $entry = $_POST['entry'];

  // creating file path for temporary storage
  $filepath = "../tmp/".$id."/".$currenttask;
  // creates file path to store java file for compilation
  $file = $filepath."/".$tasks['fileNameCode']; //"/Task1.java";
  //error_log("file: ".$file);
   $tmpz = shell_exec("pwd");
   //error_log("pwd: ".$tmpz);
  // create folder
  exec("mkdir -p ".$filepath);
  $taskfile = fopen($file, "w") or die ("Unable to open file!");
  fwrite ($taskfile, $entry);
  // put code from website into file and run ant with ../build/build.xml with id, currentask and base as parameters
  $command = "pwd; /usr/bin/ant -f ../build/build.xml -lib '../build/lib/ant-contrib.jar' -Dtest.id=".$id." -Dtest.task=".$currenttask." -Dtest.path=".$base." -Dtest.maxtime=".$maxtime." 2>&1"; 
  error_log("command: ".$command);
  $result = exec($command, $outputarray, $returncode);

  // encode JSON out of result
  $returnJson = json_encode(array( 
    'returncode' => $returncode,
    'outputText' => $outputarray,
    'id' => $id,
    'event' => $event,
    'task' => $currenttask,
  ));
  
  if ($returncode == 0) {
    $event = 8;
  }

  //error_log($output);
  // insert data into database table
  insertCodeEvent($id, $_SESSION['uuid'], $event, $currenttask-1, $entry, implode('\n', $outputarray), $eyetrackerTime);
  echo $returnJson;
?>
