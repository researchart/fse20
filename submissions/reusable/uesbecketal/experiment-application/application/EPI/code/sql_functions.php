<?php
  require_once('config.php');  //$server, $user, $pwd, $db, $conn;
  $conn = null;
  if (!$conn) {
    connect();
  }
  function connect() {
    global $server, $user, $pwd, $db, $conn;
    try {
      $conn = new PDO("mysql:host=$server;dbname=$db", $user, $pwd);
      $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
      die("Connection to database failed: " . $e->getMessage());
    }
  }
  function disconnect() {
    global $conn;
    $conn = null;
  }
  function setLanguage($id, $lang) {
    global $conn;
    $sql = "UPDATE participants SET lang='".$lang."' WHERE id ='".$id."'";
    $conn->exec($sql);
  }
  function getNextLanguage($year) {
    global $conn;
    $sql = "SELECT nextLanguage FROM language WHERE year ='".$year."'";
    $query = $conn->query($sql);
    $result = $query->fetch();
    return $result['nextLanguage'];
  }

  function getAssignedLanguages($year) {
    global $conn;
    $sql = "SELECT Lang1, Lang2, Lang3 FROM language WHERE year=:year";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':year' => $year));
    $langs= $statement->fetch();
    return $langs;
  }
  
 function resetAllLanguages($year) {
    global $conn;
    $sql = "UPDATE language SET Lang1 = 0, Lang2 = 0, Lang3 = 0 WHERE year=:year";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':year' => $year));
  }

 function updateLang1($year) {
    global $conn;
    $sql = "UPDATE language SET Lang1 = 1 WHERE year=:year";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':year' => $year));
  }

 function updateLang2($year) {
    global $conn;
    $sql = "UPDATE language SET Lang2 = 1 WHERE year=:year";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':year' => $year));
  }

  function updateLang3($year) {
    global $conn;
    $sql = "UPDATE language SET Lang3 = 1 WHERE year=:year";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':year' => $year));
  }


  function setNextLanguage($year, $nextLanguage) {
    global $conn;
    $sql = "UPDATE language SET nextLanguage='".$nextLanguage."' WHERE year='".$year."'";
    $conn->exec($sql);
  }
  function insertTimeEvent($id, $uuid, $num) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event) VALUES (:id, :uuid, :event)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid, ':event' => $num));
  }
  function insertTimeEventSurvey($id, $uuid, $num) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event) VALUES (:id, :uuid, :event)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid, ':event' => $num));
}

  function insertUser($email) {
    global $conn;
    $sql = "INSERT INTO participants (email) VALUES (:email)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':email' => $email));
    return getID($email);
  }

  function getFileName($id, $task, $group, $tries) {
      return $id."_".$task."_".$group."_".$tries.".cu";
  }

  function duplicateEmail($email) {
    global $conn;
    $sql = "SELECT id FROM participants WHERE email=:email";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':email' => $email));
    return ($statement->rowCount() > 0) ? true : false;
  }
  function getID($email) {
    global $conn;
    $sql = "SELECT id FROM participants WHERE email=:email";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':email' => $email));
    $participant = $statement->fetch();
    error_log("Participant ID check: ". $participant['id']);
    return $participant['id'];
  }
  function getCreditInfo($id) {
    global $conn;
    $sql = "SELECT name, courseNum, courseName, instructor FROM participants WHERE id='".$id."'";
    $query = $conn->query($sql);
    $participant = $query->fetch();
    return $participant;
  }
  function insertCodeEvent($id, $uuid, $event, $task, $entry, $output, $eyetrackerTime) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event, task, entry, output, eyetrackertime) VALUES (:id,:uuid,:event,:task,:entry,:output,:eyetrackertime)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid, ':event' => $event, ':task' => $task, ':entry' => $entry, ':output' => $output, ':eyetrackertime' => $eyetrackerTime));
  }

  function insertSurveyEvent($id, $uuid, $event, $task, $unfilled = 0) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event, task, entry) VALUES (:id, :uuid, :event, :task, :entry)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid,':event' => $event, ':task' => $task, ':entry' => $unfilled));
  }


  function duplicateExtraSurvey ($uuid, $qid) {
    global $conn;
    $sqlsel = "SELECT value FROM extrasurvey WHERE uuid=:uuid AND qid=:qid";
    $statementsel = $conn->prepare($sqlsel);
    $statementsel->execute(array(':uuid' => $uuid, ':qid' => $qid));

    return ($statementsel->rowCount() > 0) ? true : false;
  }
  function insertExtraSurvey($uuid, $qid, $option, $value) {
    global $conn;
    $sql = "INSERT INTO extrasurvey (uuid, qid, optionname, value) VALUES (:uuid,:qid,:option,:value)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':uuid' => $uuid, ':qid' => $qid, ':option' => $option, ':value' => $value));
  }

  function insertSampleSwitchEvent($id, $uuid, $event, $task, $entry, $eyetrackerTime) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event, task, entry, eyetrackertime) VALUES (:id,:uuid,:event,:task,:entry,:eyetrackertime)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid, ':event' => $event, ':task' => $task, ':entry' => $entry, ':eyetrackertime' => $eyetrackerTime ));
  }

  function insertTaskTimeEvent($id, $uuid, $event, $task, $eyetrackerTime) {
    global $conn;
    $sql = "INSERT INTO events (id, uuid, event, task, eyetrackertime) VALUES (:id, :uuid, :event, :task, :eyetrackertime)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':id' => $id, ':uuid' => $uuid, ':event' => $event, ':task' => $task, ':eyetrackertime' => $eyetrackerTime));
  }

  function insertSurvey1($id, $uuid, $totalxp, $jobxp, $education, $institution, $major, $degree, $year, $gpa, $origin, $language, $fluency, $colorBlind, $lowVisual, $blind, $lowAural, $deaf, $motorImpaired, $learning) {
    global $conn;
    $sql = "INSERT INTO survey ";
    $sql .= "(id, uuid, totalxp, jobxp, education, institution, major, degree, year, gpa, origin, language, fluency, colorBlind, lowVisual, blind, lowAural, deaf, motorImpaired, learning)";
    $sql .= " VALUES ( :id, :uuid, :totalxp, :jobxp, :education, :institution, :major, :degree, :year, :gpa, :origin, :language, :fluency, :colorBlind, :lowVisual, :blind, :lowAural, :deaf, :motorImpaired, :learning)";
    $statement = $conn->prepare($sql);
    $statement->execute(array(
      ':id' => $id,
      ':uuid' => $uuid,
      ':totalxp' => $totalxp,
      ':jobxp' => $jobxp,
      ':education' => $education,
      ':institution' => $institution,
      ':major' => $major,
      ':degree' => $degree,
      ':year' => $year,
      ':gpa' => $gpa,
      ':origin' => $origin,
      ':language' => $language,
      ':fluency' => $fluency,
      ':colorBlind' => $colorBlind,
      ':lowVisual' => $lowVisual,
      ':blind' => $blind,
      ':lowAural' => $lowAural,
      ':deaf' => $deaf,
      ':motorImpaired' => $motorImpaired,
      ':learning' => $learning
    ));
  }

  function insertSurvey2($id, $age, $gender, $internxp, $lang1, $lang2, $lang3, $lang4, $lang5, $lang6, $lang7, $lang8, $lang9, $lang10, $lang11, $lang12, $lang13, $lang14, $lang15, $lang16, $lang17, $lang18, $lang19, $lang20, $lang21, $lang22, $lang23, $lang24, $course1, $course2, $course3, $course4, $course5, $course6, $course7, $course8, $course9, $course10, $course11, $course12, $course13, $course14, $course15, $course16, $course17, $course18, $course19, $course20) {
    global $conn;
    $sql =  "UPDATE survey ";
    $sql .= "SET ";
      $sql .= "age= :age, gender= :gender, internxp= :internxp, ";
      $sql .= "lang1= :lang1, lang2= :lang2, lang3= :lang3, lang4= :lang4, lang5= :lang5, ";
      $sql .= "lang6= :lang6, lang7= :lang7, lang8= :lang8, lang9= :lang9, lang10= :lang10, ";
      $sql .= "lang11= :lang11, lang12= :lang12, lang13= :lang13, lang14= :lang14, lang15= :lang15, ";
      $sql .= "lang16= :lang16, lang17= :lang17, lang18 = :lang18, lang19 = :lang19, lang20 = :lang20, lang21 = :lang21, ";
      $sql .= "lang22 = :lang22, lang23 = :lang23, lang24 = :lang24, ";
      $sql .= "course1= :course1, course2= :course2, course3= :course3, course4= :course4, course5= :course5, ";
      $sql .= "course6= :course6, course7= :course7, course8= :course8, course9= :course9, course10= :course10, ";
      $sql .= "course11= :course11, course12= :course12, course13= :course13, course14= :course14, course15= :course15, ";
      $sql .= "course16= :course16, course17= :course17, course18= :course18, course19= :course19, course20= :course20 ";
    $sql .= "WHERE id= :id";

    
    $arr = array(
      ':age' =>  intval($age, 10),
      ':gender' => $gender,
      ':internxp' => $internxp,
      ':lang1' => $lang1,
      ':lang2' => $lang2,
      ':lang3' => $lang3,
      ':lang4' => $lang4,
      ':lang5' => $lang5,
      ':lang6' => $lang6,
      ':lang7' => $lang7,
      ':lang8' => $lang8,
      ':lang9' => $lang9,
      ':lang10' => $lang10,
      ':lang11' => $lang11,
      ':lang12' => $lang12,
      ':lang13' => $lang13,
      ':lang14' => $lang14,
      ':lang15' => $lang15,
      ':lang16' => $lang16,
      ':lang17' => $lang17,
      ':lang18' => $lang18,
      ':lang19' => $lang19,
      ':lang20' => $lang20,
      ':lang21' => $lang21,
      ':lang22' => $lang22,
      ':lang23' => $lang23,
      ':lang24' => $lang24,
      ':course1' => $course1,
      ':course2' => $course2,
      ':course3' => $course3,
      ':course4' => $course4,
      ':course5' => $course5,
      ':course6' => $course6,
      ':course7' => $course7,
      ':course8' => $course8,
      ':course9' => $course9,
      ':course10' => $course10,
      ':course11' => $course11,
      ':course12' => $course12,
      ':course13' => $course13,
      ':course14' => $course14,
      ':course15' => $course15,
      ':course16' => $course16,
      ':course17' => $course17,
      ':course18' => $course18,
      ':course19' => $course19,
      ':course20' => $course20,
      ':id' => $id);
    $statement = $conn->prepare($sql);
    $statement->execute($arr);

  }
  function insertCredit($id, $name, $courseNum, $courseName, $instructor) {
    global $conn;
    $sql = "UPDATE participants SET ";
    $sql .= "name=:name,";
    $sql .= "courseNum=:courseNum,";
    $sql .= "courseName=:courseName,";
    $sql .= "instructor=:instructor";
    $sql .= " WHERE id=:id";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':name' => $name, ':courseNum' => $courseNum, ':courseName' => $courseName, ':instructor' => $instructor, ':id' => $id));
  }
  function insertFeedback($id, $concepts, $design, $comments, $codeswitch) {
    global $conn;
    $sql = "UPDATE survey SET ";
    $sql .= "concepts=:concepts,";
    $sql .= "design=:design, ";
    $sql .= "comments=:comments, ";
    $sql .= "codeswitch=:codeswitch";
    $sql .= " WHERE id=:id";
    $statement = $conn->prepare($sql);
    $statement->execute(array(':concepts' => $concepts, ':design' => $design, ':comments' => $comments, ':codeswitch' => $codeswitch, ':id' => $id));
  }
?>
