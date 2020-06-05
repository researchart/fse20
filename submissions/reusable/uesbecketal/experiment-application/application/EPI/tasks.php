<?php require_once("header.php"); ?>

  <div class="modal fade" id="modal" role="dialog" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
    
      <!-- Modal content-->
      <div class="modal-content">
        <div class="modal-header">
          <h4 class="modal-title">Success!</h4>
        </div>
        <div class="modal-body">
          <p>You have successfully solved the task!</p>
          <p>Click the button below to go to the next part of the experiment.</p>
        </div>
        <div class="modal-footer">
          <button id="modalButton" type="button" class="btn btn-default" data-dismiss="modal">Move On</button>
        </div>
      </div>
      
    </div>
  </div>



  <div class="container-fluid">
    <div class="row">
      <div class="col-lg-3">
        <h2>Programming Tasks</h2>
      </div>
      <div class="col-lg-6" align="center">
          <h3 align="center"><b>Do not use your browser navigation controls.</b></h3>
          <!--<h4 align="center">This works best in fullscreen mode, Windows(F11) | Mac(Cmd-Shift-F).</h4>-->
      </div>
      <div class="col-lg-3">
          <h2 id="task-num" align="right"><?php getTaskString() ?></h2>
      </div>
    </div>

    <div class="panel panel-default" id="best-shot-panel">
      <div class="panel-body" id="best-shot">
          <h3 align="center">If you do not know what to do, try anyway and give it your best shot.</h3>
      </div>
    </div>

    <div class="row" id="instruction-div"> <!--Instruction Area-->
      <div class="col-lg-6">
        <p align="justify">
          The code sample below is valid computer code. You may use the sample to solve the tasks given to you. In order to do so, you may only need to <b>use pieces of the example</b>. It may be necessary to <b>combine and rearrange</b> some of the code samples. You may also need to <b>modify the samples</b> to fit the task, e.g. <b>change certain numbers, change names of identifiers, or change the position of certain lines of code</b>.
          <br><br>
          When you are finished, click the green button to view the task assignment and begin programming. This will happen automatically when the timer expires. The code sample will remain on the screen.
        </p>
        <h4 id="sample-timer" align="center"><br>Time Remaining: <span id=timerSample></span></h4>
      </div>
    </div>

    </div>
    <div class="row">
      <div class="col-lg-6" id="sample-div"> <!--Code Sample Area-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-6 no-pad">
            <h4 id="label-sample"><br>Code Sample:</h4>
            <h4 id="label-code"><br>Code Sample (unchanged):</h4>
            <ul id="sampletab" class="nav nav-tabs">
            </ul>
          </div>
          <div class="col-lg-6 no-pad">
            <p align="right" style="padding-top: 15px">
              <button type="button" class="btn btn-success" id="sampleButton">Ready to Begin</button>
            </p>
          </div>
        </div>
        <div class="row no-pad"> <!--Code Sample Text Area-->
            <div id="tabpanel" class="col-lg-12 tab-content">
            </div>
        </div>
      </div>
      <div class="col-lg-6" id="user-div"> <!--User Entry Area-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-4 no-pad">
            <h4><br>Type answer below:</h4>
          </div>
          <div class="col-lg-4 no-pad">
            <h4 id="task-timer" align="center"><br>Time Remaining: <span id=timerTask></span></h4>
          </div>
          <div class="col-lg-4 no-pad hidetimerdiv">
            <button type="button" class="btn btn-success" id="hidetimerbutton">Hide Timer</button>
          </div>
        </div>
        <div class="row col-pad"> <!--User Entry Text Area-->
          <pre id="entrypre" class="userentrypre">
            <code autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" contenteditable="true" class="form-control" id="entry-area">
            </code>
          </pre>
<!--          <textarea class="form-control" rows=22 id="entry-area"></textarea>-->
        </div>
        <p align="right" style="padding-top: 15px">
          <button type="button" class="btn btn-danger" data-loading-text="Processing..." autocomplete="off" id="checkButton">Check Task</button>
        </p>
      <div class="col-lg-6"> <!--Task Output-->
        <div class="row-fluid"> <!--Heading-->
          <div class="col-lg-6 no-pad">
            <h4>Task Output:</h4>
          </div>
          <div class="col-lg-6 no-pad">
            <h4></h4>
          </div>
        </div>
       </div>
        <div class="row no-pad"> <!--Task Output Text Area-->
          <div class="col-lg-12">
            <code class="form-control display-area code" id="task-output" contenteditable=false></code>
          </div>
        </div>
      </div>
    </div>
  </div>
  <input id="iTraceEventTime" class="hidden" value=-1 />
<?php require_once("footer.php"); ?>
