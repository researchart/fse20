<?php require_once("header.php"); ?>
  <div class="container">
    <div class="row">
       <h2 id="question-num" ></h2>
    </div>
    <div class="row">
      <h1> Survey </h1>
    </div>
    <form action="" method="post" name="frmSurvey">
        <div id="content">
        </div>
        <div id="errorAlert" class="alert alert-danger" aria-hidden="true" style="display: none;">
          <strong> Error: </strong> Please select a value for each option.
        </div>
        <div class="row">
          <div class="col-md-5 col-md-offset-5">
            <button id="nextButton" type="button" class="btn btn-success nxtbutton">Next</button>
          </div>
        </div>
        <div class="row bottom-buffer">
        </div>
    </form>
  </div>

<?php require_once("footer.php"); ?>
