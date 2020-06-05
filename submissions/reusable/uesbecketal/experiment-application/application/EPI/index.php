<?php
  session_start();
  $_SESSION["task_status"] = "not started";
?>
<?php
    require_once("header.php");
?>

    <div class="container-fluid">
      <h1>Scientific Computing Study on Programming Language</h1>
      <h4>Welcome to the language study task administration site. We thank you for your interest in helping advance the science of programming language design. The study is conducted using scientific methods and it is important to adhere to the guidelines in your participation.</h4>
      <br>
      <div class="panel panel-default">
        <div class="panel-body" id="time-notice">
          <p>Estimated time for this study: <b>around 2 hours up to 4.5 hours maximum</b></p>
          <p>The study is <b>timed</b> and it is important to do it in <b>one session</b> without interruption.  If you do not have the time to do the study right now, please <b>wait until you have the time and return.</b></p>
        </div>
      </div>
      <h3>Things to know before you begin:</h3>
      <ul style="list-style-type:disc">
        <li>Before you begin the study, we will ask you to review an Informed Consent Document which outlines the procedures of the study and the risks and benefits of participation.  You will have an opportunity to ask questions about the document and the procedures before you begin.</li>
        <li>Your answers are confidential and recorded in our results database without any personally identifiable information. We request an email address for contact purposes which is kept in a separate database file.</li>
        <li>If you have been offered the opportunity for extra credit in a course, you will be asked for personal information so that we may notify your instructor of your participation in the study.  This information will be kept in the separate database file with your contact information. Only the research team members will see your answers and results on the study tasks.  They will not be available to your course instructor.</li>
        <li>You may or may not be physically supervised during the study, but in either case it is important that you do not search the internet or use materials other than what is given to you as part of the study. This behavior could impact the results of the study and would make your participation pointless.</li>
        <li>Since this study involves a timed element and writing code, it requires either a desktop or laptop computer and cannot be completed on a mobile device.</li>
        <li>You have the right to terminate the study at any time, but we will not be able to utilize the data <b>unless you reach the Completion Page</b>.</li>
      </ul>
      <div class="alert alert-danger" id="browser-warning" hidden>
          <h3><strong>Warning!</strong> This study should preferably run using Chrome! There are confirmed severe bugs in Firefox.</h3>
      </div>
      <div class="alert alert-danger" id="mobile-warning" hidden>
          <h3><strong>Warning!</strong> This study should not be run on a mobile platform, you need a keyboard.</h3>
      </div>
      <script>
        $( document ).ready(function() {
          if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
            $('#mobile-warning').show();
          };

          if( /Firefox/i.test(navigator.userAgent) ) {
            $('#browser-warning').show();
          };
        });
      </script>
      <form role="form" action="code/validate_email.php" method="post">
        <div class="form-group">
          <label for="email">Enter your email address to begin:</label>
          <input type="email" class="form-control input-md" id="email" name="email" required>
        </div>
        <button type="submit" class="btn btn-primary">Begin Study</button>
      </form>
    </div>

<?php require_once("footer.php"); ?>

