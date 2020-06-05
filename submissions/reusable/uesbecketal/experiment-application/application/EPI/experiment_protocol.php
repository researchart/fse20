<?php require_once("header.php"); ?>
<!--temporary for testing-->
<?php  $_SESSION["task_status"] = "not started"; ?>
<script>
    $(document).ready(function(){
        deleteCookie("tasktimer");
        deleteCookie("sampletimer");
    });
    function deleteCookie(name) {
      document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    }
</script>
    <div class="container">
      <h1>Experiment Protocol</h1>
      <p>Please read the following protocol carefully so that you understand what will happen during the study.</p>
      
      <h4>Study Information</h4>
      <div>
          <p>In this study, you will be attempting to write computer programs in a programming language that you might not be familiar with. Try to solve as much of the given assignment as possible. Potentially, this can help to improve programming languages. Keep in mind that in this study we are investigating programming languages, not you or your programming abilities.
          </p>
      </div>
      <div>
      <h4>Study Scenario:</h4>
        <p>Imagine that you have recently completed a degree in computer science. You have just started your first job, where you are told that you will be writing computer programs in a programming language that you might not be familiar with. Your coworker provides you with a code sample that you have to modify in order to solve the tasks at hand.
        </p>
      </div>
      <h4>Before Each Task</h4>
      <div>
          <p>Before the first task, you will be shown code samples to solve the problems. The sample will be displayed on the left part of the task screen for you to review.  A timer will be shown on the screen to inform you how long you have to review the sample. When the timer is up, an assignment will appear in the top portion of the screen, along with an editable text editor box where you can type your solution.  You are encouraged to maximize your browser window for the study for best viewing and to reduce distractions.  There are a total of <b>six</b> tasks in this study, lasting no more than 45 minutes each.
        </p>
      </div>
      <div class="panel panel-default">
        <div class="panel-body" id="during-task">
          <h4>During Each Task</h4>
              <p>During each task, you will attempt to solve the assignment in the style of programming language suggested in the code sample.  A timer will be displayed indicating the remaining time for the particular task.  You will continue to have access to the code samples you previously viewed. There are several rules that are important to follow during these tasks:</p>
            <ol>
              <li>Follow the assignment instructions carefully.</li>
              <li>You have a set time to finish each task.</li>
              <li>Use all of the allotted time to try and finish as much of each task as possible.</li>
              <li>You may use the code samples to complete the tasks.</li>
              <li>You are not allowed to use any help except the code samples. <b>Do not use the internet.</b></li>
              <li>Do not use your computer for anything else but completing this task (e.g. do not check email, Facebook or play games).</li>
              <li><b>Turn off your cell phone and TV to reduce distractions.</b></li>
              <li>If you do not know what to do, try anyway and give it your best shot.</li>
            </ol>
        </div>
      </div>
      <h4>After Each Task</h4>
      <div>
          <p>After each task, your response will be saved and you will proceed to review the next code samples.  Follow through the entire study until you receive a confirmation of completion at the end.  There are a total of <b>six</b> tasks in this study.</p>
      </div>
      <h4>The Code Samples</h4>
      <div>
        <p>The code samples given to you are valid computer code. You may use the samples to solve the tasks given to you. In order to do so, you may only need to <b>use pieces of the examples</b>. It may be necessary to <b>combine and rearrange</b> some of the code samples. You may also need to <b>modify the samples</b> to fit the task (e.g. <b>change certain numbers, change names of identifiers, or change the position of certain lines of code)</b>.</p>
      </div>
      
      <div class="row">
        <div class="col-lg-9"> <!--left column-->
          <div class="panel panel-default">
            <div class="panel-body" id="best-shot">
              <h3>If you do not know what to do, try anyway and give it your best shot.</h3>
            </div>
          </div>
        </div>
        <div class="col-lg-3"> <!--right column-->
          <form role="form" action="code/begin_tasks.php" method="post">
            <p align="right">
              <br>
              <button type="submit" class="btn btn-success">Begin Timed Portion</button>
            </p>
          </form>
        </div>
      </div>
      
    </div>

<?php require_once("footer.php"); ?>
