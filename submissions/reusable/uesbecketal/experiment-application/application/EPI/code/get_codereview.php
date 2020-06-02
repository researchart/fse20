<?php
  require_once('sql_functions.php');  //$server, $user, $pwd, $db, $conn;

  class event {
    public $id = NULL;
    public $entry = NULL;
    public $output = NULL;
    public $time = NULL;
    public $event = NULL;
  }
  
  $pid = $_POST["id"];
  $taskid = $_POST["task"];

  error_log("Participant id: " . $pid);
  error_log("Task id: " . $taskid);

  global $conn;
  $sql = "SELECT events.id as id, lang, year, entry, output, time, event FROM events JOIN participants ON events.id = participants.id JOIN survey on participants.id=survey.id WHERE events.id = :pid AND task =:taskid AND event IN (12,7,8,13) ORDER BY time ASC";
  $sth = $conn->prepare($sql);
  $sth->execute(array(':pid' => $pid, ':taskid' => $taskid));
  $result = $sth->fetchAll(PDO::FETCH_CLASS, "event");

  echo json_encode( $result );
?>
