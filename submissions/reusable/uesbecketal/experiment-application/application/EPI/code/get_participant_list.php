<?php
  require_once('sql_functions.php');  //$server, $user, $pwd, $db, $conn;

  class participant {
    public $id = NULL;
    public $lang = NULL;
    public $year = NULL;
  }

  global $conn;
  $sql = "SELECT participants.id, lang, year, major FROM participants JOIN survey on participants.id=survey.id WHERE participants.valid = 1";
  $sth = $conn->prepare($sql);
  $sth->execute();
  $result = $sth->fetchAll(PDO::FETCH_CLASS, "participant");

  echo json_encode( $result );
?>
