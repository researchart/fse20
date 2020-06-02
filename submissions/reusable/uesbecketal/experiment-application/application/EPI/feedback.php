<?php require_once("header.php"); ?>
  <script>
  function SubmitFeedback() {
    $.ajax({
      url: 'code/validate_feedback.php',
      type: 'POST',
      data: { 'concepts': $("#concepts").val(), 'design': $("#design").val(), 'comments': $("#comments").val(), 'codeswitch': $("#codeswitch").val()},
      complete: function (response) {
        window.location.href = "finished.php";
      }
    });
  }
  </script>
  <div class="container">
    <h1>Final Feedback</h1>
    <label for="totalxp">Which of the concepts in the study did you find difficult to understand?</label>
    <textarea class="form-control" rows=10 id="concepts"></textarea>
    <br>
    <label for="totalxp">Did you feel like you had to switch between languages during the experiment and how do you think did this affect your progress while solving the tasks?</label>
    <textarea class="form-control" rows=10 id="codeswitch"></textarea>
    <br>
    <label for="totalxp">Was there anything about the design of the programming language (not the study itself) that would have made these tasks easier?</label>
    <textarea class="form-control" rows=10 id="design"></textarea>
    <br>
    <label for="totalxp">If you have any other comments or feedback, please type it here:</label>
    <textarea class="form-control" rows=10 id="comments"></textarea>
    <br>

    <p align="right">
      <button type="button" class="btn btn-success" style="align" id="finished" onclick="SubmitFeedback()">I'm finished</button>
    </p>
  </div>
<?php require_once("footer.php"); ?>
