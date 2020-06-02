<?php
  require_once('sql_functions.php');  //$server, $user, $pwd, $db, $conn;

  class participant {
    public $id = NULL;
    public $lang = NULL;
    public $year = NULL;
    public $concepts = NULL;
    public $design = NULL;
    public $comments = NULL;
    public $event1 = NULL;
    public $event2 = NULL;
    public $event3 = NULL;
    public $event4 = NULL;
    public $event5A = NULL;
    public $event5B = NULL;
    public $event5C = NULL;
    public $event6A = NULL;
    public $event6B = NULL;
    public $event6C = NULL;
    public $event8A = NULL;
    public $event8B = NULL;
    public $event8C = NULL;
    public $event10 = NULL;
    public $event11 = NULL;
    public $answer1 = NULL;
    public $answer2 = NULL;
    public $answer3 = NULL;
  }
  class event {
    public $id;
    public $event;
    public $time;
    public $task;
    public $entry;
  }
  
  global $conn;
  $sql = "SELECT participants.id, lang, year, concepts, design, comments FROM participants JOIN survey on participants.id=survey.id";
  $sth = $conn->prepare($sql);
  $sth->execute();
  $result = $sth->fetchAll(PDO::FETCH_CLASS, "participant");
  
  $sql = "SELECT id, event, time, task, entry FROM events WHERE event != '7'";
  $sth = $conn->prepare($sql);
  $sth->execute();
  $events = $sth->fetchAll(PDO::FETCH_CLASS, "event");
  
  foreach ($events as $row => $event) {
    foreach ($result as $i => $field) {
      if ($event->id === $field->id) {
        $index = $i;
        break;
      }
      $index = FALSE;
    }
    if ($index===FALSE) {
      continue;
    }
    switch ($event->event) {
      case 1:
        $result[$index]->event1 = $event->time;
        break;
      case 2:
        $result[$index]->event2 = $event->time;
        break;
      case 3:
        $result[$index]->event3 = $event->time;
        break;
      case 4:
        $result[$index]->event4 = $event->time;
        break;
      case 5:
        if ($event->task == 0) {
          $result[$index]->event5A = $event->time;
        } elseif ($event->task == 1) {
          $result[$index]->event5B = $event->time;
        } elseif ($event->task == 2) {
          $result[$index]->event5C = $event->time;
        }
        break;
      case 6:
        if ($event->task == 0) {
          $result[$index]->event6A = $event->time;
        } elseif ($event->task == 1) {
          $result[$index]->event6B = $event->time;
        } elseif ($event->task == 2) {
          $result[$index]->event6C = $event->time;
        }
        break;
      case 8:
        if ($event->task == 0) {
          $result[$index]->event8A = $event->time;
          $result[$index]->answer1 = $event->entry;
        } elseif ($event->task == 1) {
          $result[$index]->event8B = $event->time;
          $result[$index]->answer2 = $event->entry;
        } elseif ($event->task ==   2) {
          $result[$index]->event8C = $event->time;
          $result[$index]->answer3 = $event->entry;
        }
        break;
      case 10:
        $result[$index]->event10 = $event->time;
        break;
      case 11:
        $result[$index]->event11 = $event->time;
        break;
    }
  }
  
  echo json_encode( $result );
?>
