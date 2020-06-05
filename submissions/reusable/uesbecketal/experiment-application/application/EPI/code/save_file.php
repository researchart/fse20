<?php
    session_start();
    require_once('sql_functions.php');
    $dir = $_POST['dir'];
    $id = $_SESSION['id'];
    $currenttask = (int) $_SESSION['currentTask']+1;
    $group = $_SESSION['group'];
    $tries = $_POST['tries'];
    $fname = getFileName($id, $currenttask, $group, $tries);
    $file = fopen($dir.$fname, "w");
    $txt = $_POST['code'];
    //echo $fname . PHP_EOL;
    //echo $txt . PHP_EOL;
    fwrite($file, $txt);
    fclose($file);
?>
