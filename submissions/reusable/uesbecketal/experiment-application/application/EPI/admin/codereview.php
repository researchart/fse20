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
    <script src="../code/js/codereview.js"></script>
  </head>
  
  <body>
      <div id="wrapper">
        <div class="container-fluid">
            <div class="row">
              <h1>Code Review</h1>
              <div><a href="overview.php">Back to Overview</a></div>
              <div id="generalInfo"> </div>
            </div>
            <div class="info">
              <div>
                <div id="number">
                </div>
                <div id="time">
                </div>
                <div id="event">
                </div>
              </div>
              <div >
                  <button id="prev" type="button" class="btn btn-primary">Previous</button>
                  <button id="next" type="button" class="btn btn-primary">Next</button>
              </div>
              <div >
                  <button id="prevSig" type="button" class="btn btn-primary">Previous Big</button>
                  <button id="nextSig" type="button" class="btn btn-primary">Next Big</button>
              </div>
            </div>
            <div class="row">
              <pre> <code id="codeplace"> </code> </pre>
            </div>
            <div class="row">
              <pre id="output" style="color: grey"> </pre>
            </div>
        </div>
      </div>

<?php require_once("../footer.php"); ?>
