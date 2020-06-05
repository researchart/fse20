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
    <script src="../code/js/review.js"></script>
  </head>
  
  <body>
      <div id="wrapper">
        
  <div class="container-fluid">
    <div class="row">
      <div class="col-lg-4">
        <h2>Programming Task Review</h2>
      </div>
      <div class="col-lg-4" align="center">
          <h3 align="center"><b></b></h3>
      </div>
      <div class="col-lg-4" align="right">
        <h2>Task <span id="num"></span>/3</h2>
      </div>
    </div>
    <div class="row" id="assignment-div"> <!--Task Assignment Area-->
      <div class="col-lg-8"> <!--Description-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-4 no-pad">
            <h4>Task Description:</h4>
          </div>
          <div class="col-lg-4 no-pad">
            <ul class="nav nav-pills">
              <li class="active"><a data-toggle="tab" href="#" id="L1">ProcessJ</a></li>
              <li><a data-toggle="tab" href="#" id="L2">Java</a></li>
            </ul>
          </div>
          <div class="col-lg-4 no-pad">
            <ul class="nav nav-pills">
              <li data-toggle="tab" class="active"><a href="#" id="T1">Task 1</a></li>
              <li><a data-toggle="tab" href="#" id="T2">Task 2</a></li>
              <li><a data-toggle="tab" href="#" id="T3">Task 3</a></li>
            </ul>
          </div>
        </div>
        <div class="row no-pad"> <!--Task Description Text Area-->
          <div class="col-lg-12">
            <div class="form-control display-area" id="task-description" contenteditable></div>
          </div>
        </div>
      </div>
      <div class="col-lg-4"> <!--Task Output-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-6 no-pad">
            <h4>Task Sample Output:</h4>
          </div>
          <div class="col-lg-6 no-pad">
            <h4></h4>
          </div>
        </div>
        <div class="row no-pad"> <!--Task Output Text Area-->
          <div class="col-lg-12">
            <div class="form-control display-area" id="task-output" contenteditable></div>
          </div>
        </div>
      </div>
    </div>  
    <div class="row">
      <div class="col-lg-6" id="sample-div"> <!--Code Sample Area-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-6 no-pad">
            <h4 id="label-sample"><br>Code Sample:</h4>
          </div>
          <div class="col-lg-6 no-pad">
            <p align="right" style="padding-top: 15px">
            </p>
          </div>
        </div>
        <div class="row no-pad"> <!--Code Sample Text Area-->
            <div class="col-lg-12">
              <div class="form-control display-area" id="sample-area" contenteditable></div>
            </div>
        </div>
      </div>
      <div class="col-lg-6" id="user-div"> <!--User Entry Area-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-4 no-pad">
            <h4><br>Type answer below:</h4>
          </div>
          <div class="col-lg-4 no-pad">
          </div>
          <div class="col-lg-4 no-pad">
          </div>
        </div>
        <div class="row col-pad"> <!--User Entry Text Area-->
          <textarea class="form-control" rows=22 id="entry-area"></textarea>
        </div>
      </div>
    </div>
  </div>

<?php require_once("../footer.php"); ?>
