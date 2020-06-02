<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Language Study</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
    <link rel="stylesheet" href="../css/style.css" type="text/css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <script src="../code/js/result.js"></script>
  </head>
  
  <body>
      <div id="wrapper">
        
  <div class="container-fluid">
    <div class="row">
      <div class="col-lg-4">
        <h2>Participant Results</h2>
      </div>
      <div class="col-lg-4" align="center">
        <br>
        <button type="button" class="btn btn-default" id="prev">
          <span class="glyphicon glyphicon-chevron-left"></span>
        </button>
        <button type="button" class="btn btn-default" id="next">
          <span class="glyphicon glyphicon-chevron-right"></span>
        </button>
      </div>
      <div class="col-lg-4" align="right">
        <h2>ID: <span id="idDisplay"></span></h2>
      </div>
    </div>
    <div class="row" id="assignment-div"> <!--Task Assignment Area-->
      <div class="col-lg-6"> <!--Description-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-4 no-pad">
            <h4>Participant Info:</h4>
          </div>
          <div class="col-lg-4 no-pad">
          </div>
          <div class="col-lg-4 no-pad">
          </div>
        </div>
        <div class="row no-pad"> <!--Task Description Text Area-->
          <div class="col-lg-12">
            <br>
            <table class="table" style="width:100%">
              <thead>
                <tr>
                  <th>Item</th>
                  <th>Value</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>ID:</td>
                  <td><span id="id"></span></td>
                </tr>
                <tr>
                  <td>Language</td>
                  <td><span id="language"></span></td>
                </tr>
                <tr>
                  <td>Year:</td>
                  <td><span id="year"></span></td>
                </tr>
              </tbody>
            </table>
            <table class="table" style="width:70%">
              <thead>
                <tr>
                  <th>Event</th>
                  <th>Timestamp</th>
                  <th>Time</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Start:</td>
                  <td><span id="event1ts"></span></td>
                  <td><span id="event1time"></span></td>
                </tr>
                <tr>
                  <td>Accept Consent:</td>
                  <td><span id="event2ts"></span></td>
                  <td><span id="event2time"></span></td>
                </tr>
                <tr>
                  <td>Decline Consent:</td>
                  <td><span id="event3ts"></span></td>
                  <td><span id="event3time"></span></td>
                </tr>
                <tr>
                  <td>Classification End:</td>
                  <td><span id="event4ts"></span></td>
                  <td><span id="event4time"></span></td>
                </tr>
                <tr>
                  <td>Sample Start:</td>
                  <td><span id="event5ts"></span></td>
                  <td><span id="event5time"></span></td>
                </tr>
                <tr>
                  <td>Code Start:</td>
                  <td><span id="event6ts"></span></td>
                  <td><span id="event6time"></span></td>
                </tr>
                <tr>
                  <td>Task 1 End:</td>
                  <td><span id="event8Ats"></span></td>
                  <td><span id="event8Atime"></span></td>
                </tr>
                <tr>
                  <td>Task 2 End:</td>
                  <td><span id="event8Bts"></span></td>
                  <td><span id="event8Btime"></span></td>
                </tr>
                <tr>
                  <td>Task 3 End:</td>
                  <td><span id="event8Cts"></span></td>
                  <td><span id="event8Ctime"></span></td>
                </tr>
                <tr>
                  <td>Survey End:</td>
                  <td><span id="event10ts"></span></td>
                  <td><span id="event10time"></span></td>
                </tr>
                <tr>
                  <td>End:</td>
                  <td><span id="event11ts"></span></td>
                  <td><span id="event11time"></span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <div class="col-lg-6"> <!--Task Output-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-6 no-pad">
            <h4><br>Answer:</h4>
          </div>
          <div class="col-lg-6 no-pad">
            </br>
            <ul class="nav nav-pills">
              <li data-toggle="tab" class="active"><a href="#" id="T1">Task 1</a></li>
              <li><a data-toggle="tab" href="#" id="T2">Task 2</a></li>
              <li><a data-toggle="tab" href="#" id="T3">Task 3</a></li>
            </ul>
          </div>
        </div>
        <div class="row col-pad"> <!--User Entry Text Area-->
          <textarea class="form-control" rows=22 id="entry-area"></textarea>
        </div>
        <div class="row col-pad">
          <h4>Concepts:</h4>
          <textarea class="form-control" rows=22 id="concepts"></textarea>
        </div>
        <div class="row col-pad">
          <h4>Design:</h4>
          <textarea class="form-control" rows=22 id="design"></textarea>
        </div>
        <div class="row col-pad">
          <h4>Comments:</h4>
          <textarea class="form-control" rows=22 id="comments"></textarea>
        </div>
      </div>
    </div>  
  </div>

<?php require_once("../footer.php"); ?>
