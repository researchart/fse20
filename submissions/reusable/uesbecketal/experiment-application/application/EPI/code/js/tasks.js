var numTasks;
var task;
var timerInterval;
var idCount = 0;
var tries = 0;
var dir = 'tmp/';
var taskStage = '';
var iTraceEventTime = -1;

$(document).ready(function(){
    $.ajax({
        url:"code/get_study_status.php",
        complete: function (response) {
            var status = JSON.parse(response.responseText);
            numTasks = status.total_tasks;
            taskStage = status.task_stage;
            $.ajax({
                url:"code/get_current_task.php",
                async: false,
                success: setUpTask,
                complete: setUpDisplay
            });
        }
    });
    $(document).ajaxError(function(){
      alert("An AJAX error occured!");
    });
    $("#sampleButton").click(function() {
        displayCode();
    });
    $("#checkButton").on('click', function(){
//        $("#pleaseWaitDialog").modal(); // show loading animation
//        $(this).button('loading');
        $("#checkButton").button('loading');
        checkTask(12);
    });
    $("#hidetimerbutton").click(function() {
      if($("#task-timer").is(":visible")) {
        $("#task-timer").hide();
        $("#hidetimerbutton").html("Show Timer");
      }
      else{
        $("#task-timer").show();
        $("#hidetimerbutton").html("Hide Timer");
      }
    });
    $("#modalButton").click(function(){
        goToNextTask();
    });
    $("#entry-area").keyup(function(){
      addID();
    });
  $(document).delegate('#entry-area', 'keydown', function(e) {
//    $("#entry-area *").keydown(function(e) {
      var keyCode = e.keyCode || e.which;
      

      if (keyCode == 9) {
        e.preventDefault();

        var selection = window.getSelection();
        var object = selection.anchorNode.parentNode; 
        if (object.id === "entry-area"){
          object = selection.anchorNode;
        }
        var id = object.id;
        var start = selection.anchorOffset;
        var focusNode = selection.focusNode.parentNode;
        if (focusNode.id === "entry-area") {
          focusNode = selection.focusNode;
        }
        var end = selection.focusOffset;
        var focusNodeId = focusNode.id;
        var idnum = parseInt(id.split('-')[1]);
        var focusidnum = parseInt(focusNodeId.split('-')[1]);
        // if selected the other way around, flip all the things
        if (focusidnum && idnum && focusidnum < idnum) {
          var tempobj = object;
          object = focusNode;
          focusNode = tempobj;
          var tempId = id;
          id = focusNodeId;
          focusNodeId = tempId;
          var tempIdNum = idnum;
          idnum = focusidnum;
          focusidnum = tempIdNum;
        }


        if (start > end) {
          var temp = end;
          end = start;
          start = temp;
        }
        var objecthtml = $(object).html();
        if (object === focusNode) {
          $(object).html($(object).html().substring(0, start)
              + "\t"
              + $(object).html().substring(end));
          var selection = window.getSelection();
          selection.collapse(selection.anchorNode.childNodes[0],start+1);
        } else {
          if (idnum) {
            var idDiff = focusidnum - idnum;
            var i = 0;
            for (i = 0; i <= idDiff; i++) {
              var currentid = idnum + i;
              var idstring = "#inputline-" + currentid;
              $(idstring).html("\t" + $(idstring).html());
            }
            var newposStart = start+1;
            if (newposStart > object.childNodes[0].length) {
              newposStart = object.childNodes[0].length-1;
            }
            var newposEnd = end+1;
            if (newposEnd > focusNode.childNodes[0].length) {
              newposEnd = focusNode.childNodes[0].length-1;
            }
            selection.setBaseAndExtent(object.childNodes[0], newposStart, focusNode.childNodes[0], newposEnd);
          }
        }
      }
      if (keyCode == 38) {

//         var pos = this.selectionStart;
         this.value = (e.keyCode == 38?1:-1)+parseInt(this.value,10);
         var protoObject = getSelectedNode();
         var object = null;
         if (protoObject.previousSibling){
           object = protoObject.previousSibling;
         } else {
           object = protoObject;
         }


         var selection = window.getSelection();
         var selectionNode = object.childNodes[0];
         var startPos = selection.anchorOffset;
         if (selectionNode.length < startPos) {
            startPos = selectionNode.length;
         }
         if (e.shiftKey) {
           selection.extend(selectionNode, 1);
         } else {
           selection.collapse(selectionNode , startPos);
         }
         ignoreKey = true; setTimeout(function(){ignoreKey=false},1);
         e.preventDefault();
      }
    })
    $("#entry-area").on('keypress', function(e) {
      // log keycode in output field
      logEvent(24, $("#entry-area").val(), e.which);
    });
    document.querySelector("code[contenteditable]").addEventListener("paste", function(e) {
       console.log("I got triggered");
       console.log(e);
         e.preventDefault();
         var domparser = new DOMParser();
             var text = e.clipboardData.getData("text/plain");
             var array = text.split('\n');
             var i = 0;
             var node = getSelectedNode();
             var selection = window.getSelection();

             if (node.nextSibling){
               for(i = array.length-1; i >= 0; i--){
                 var html = '<pre class="inputline" id="iii' + i+ '" contenteditable="true">' + array[i] + '</pre>';

                 if(node.nextSibling.insertAdjacentHTML){
                   node.nextSibling.insertAdjacentHTML('beforebegin', html);
                 } else {
                   node.prepend(html);
                 }
               }
               var idnum = array.length-1;
               var idstr = "#iii"+ idnum;
               var newnode = $(idstr)[0];
               var found = true;
               while (!newnode || newnode.childNodes.length == 0) {
                  idnum = idnum -1;
                  idstr = "#iii"+(idnum);
                  if ($(idstr).length <= 0) {
                    found = false;
                    break;
                  }
                  newnode = $(idstr)[0];
               }
               if(found) {
                 selection.collapse(newnode.childNodes[0], newnode.childNodes[0].length);
               }
             } else {
               for (i = array.length-1; i >= 0; i--){
                 var html = '<pre class="inputline" id="iii' + i+ '" contenteditable="true">' + array[i] + '</pre>';
                 node.insertAdjacentHTML('afterend', html);
               }
               var idnum = array.length-1;
               var idstr = "#iii"+ idnum;
               var newnode = $(idstr)[0];
               if (newnode && newnode.childNodes){
                  selection.collapse(newnode.childNodes[0], newnode.childNodes[0].length);
               } else {
                 idstr = "#iii" + (idnum-1);
                 newnode = $(idstr)[0];
                 if (newnode && newnode.childNodes) {
                  selection.collapse(newnode.childNodes[0], newnode.childNodes[0].length);
                 }
               }
             }
      // log paste event and put clipboard data in output
      var clipboard = e.clipboardData || window.clipboardData;
      var data = clipboard.getData('Text');
      logEvent(26, $("#entry-area").val(), data);

    });

    $("#entry-area").on('click', function() {
      // log click event
      logEvent(25, $("#entry-area").val(), $("#task-output").val());
    });
    // for some reason, you can't access the clipboardData from jQuery so just JavaScript here
//    document.getElementById("entry-area").addEventListener('paste', function (e) {
      // log paste event and put clipboard data in output
//      var clipboard = e.clipboardData || window.clipboardData;
//      var data = clipboard.getData('Text');
//      logEvent(26, $("#entry-area").val(), data);
//    });

});

function logEventURL(url, event, entry, output) {
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url: url,
        type: 'POST',
        async: true,
        data: {
            'event':event,
            'entry':entry,
            'output':output,
            'eyetrackerTime' : iTraceEventTime},
        complete: function (response) {
        }
    });

}

function logEvent(event, entry, output) {
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url:"code/insertCodeEvent.php",
        type: 'POST',
        async: true,
        data: {
            'event':event,
            'entry':entry,
            'output':output,
            'eyetrackerTime' : iTraceEventTime},
        complete: function (response) {
        }
    });
}

function setUpDisplay() {
    if (taskStage === "sample") {
        displaySample();
    } else if (taskStage === "coding") {
        displayCode();
    }
}

function getCaretPosition(editableDiv) {
  var caretPos = 0,
    sel, range;
  if (window.getSelection) {
    sel = window.getSelection();
    if (sel.rangeCount) {
      range = sel.getRangeAt(0);
      if (range.commonAncestorContainer.parentNode == editableDiv) {
        caretPos = range.endOffset;
      }
    }
  } else if (document.selection && document.selection.createRange) {
    range = document.selection.createRange();
    if (range.parentElement() == editableDiv) {
      var tempEl = document.createElement("span");
      editableDiv.insertBefore(tempEl, editableDiv.firstChild);
      var tempRange = range.duplicate();
      tempRange.moveToElementText(tempEl);
      tempRange.setEndPoint("EndToEnd", range);
      caretPos = tempRange.text.length;
    }
  }
  return caretPos;
}

function getSelectedNode()
{
  if (document.selection)
    return document.selection.createRange().parentElement();
  else
  {
    var selection = window.getSelection();
    if (selection.rangeCount > 0)
      return selection.getRangeAt(0).startContainer.parentNode;
  }
}

function addID(){  
    idCount = 0;
//    var previousIDs = [];

    $('#entry-area pre').each(function() {


        var thisID = $(this).attr( 'id' );

        // let's check if we have duplicates:
        //var index = 0, len = previousIDs.length, isDuplicate = false;

        //for( index = 0; index < len; index++ ){
        //    if ( thisID === previousIDs[index] ) { 
       //         isDuplicate = true; 
        //        break;
         //   }
        //}


        // now change the ID if needed:
        //if (  isDuplicate    ||    ! thisID  ){

//            var t = //GenerateID();
            var newID = 'inputline-' + idCount;

            $(this).attr('id', newID);
            $(this).attr('contenteditable', 'true');
            if ($(this).html() === "<br>"){
              $(this).empty();
              $(this).text(" ");
            } else if (!$(this).html().endsWith("\n")){
              $(this).append("\n");
              
            }
        //    previousIDs.push( newID );

      //  }else{
      //      previousIDs.push( thisID );
       // }

        idCount++;
    });
}


function GenerateID() 
{
    var str = 'abcdefghijklmnopqrstuvwxyz0123456789';

    var char = '', 
        genID = '';
    
    while(genID.length < 5)
    {
        char = str.charAt(Math.floor(Math.random() * str.length)); 
        genID += char;
    }
    
    return genID;
}

function wrapWordsInSpan(lineOfText, idString) {
  var arrayOfWords = lineOfText.split(" ");
  var wrappedWords = "";
  var wordnum = 0;
  for (wordnum = 0; wordnum < arrayOfWords.length; wordnum++) { 
    wrappedWords += "<span class='wrapperSpan' id='"+ idString + wordnum + "'>";
    wrappedWords += arrayOfWords[wordnum];
    wrappedWords += "</span>&nbsp;";
  }
  return wrappedWords;
}

function setUpTask(response) {
  task = JSON.parse(response);
  var i = 0;
  for (i = 0; i < task.codeSample.length; i++){
    addSampleTab("Sample " + (i + 1)  , i);
    addSampleDisplayArea(i);
    var id = "#smplA"+i;
    $(id).empty();
    $.get("documents/" + task.codeSample[i], function(result) {
        var test = result.split("\n");
        var j = 0;
        
        for(j = 0; j < test.length; j++) {
          var linecode= "<pre class='sampleline' id='smplA" + i + "-line-"+j+"'>"
            
          linecode += wrapWordsInSpan(test[j], "sample-" + i + "-line-" + j + "-word-" );
          
          linecode += "</pre>";
          $(id).append(linecode);
        }
    })
//    $(id).load("documents/" + task.codeSample[i]);
  }
  $("#task-num").html("Task: " + task.taskNum + " of " + task.totaltasks); 
  $("#task-output").load("documents/" + task.taskOutput);
  $("#timerSample").text(task.timeSample + ":00");
  $("#timerTask").text(task.timeTask + ":00");

  $.get("documents/" + task.template, function(result) {
      var linesTemplate = result.split("\n");
      $("#entry-area").empty();
      var k = 0;
      for (k = 0; k < linesTemplate.length; k++){
        var linecode= "<pre class='inputline' id='inputline-"+k+"'>"+linesTemplate[k]+"\n</pre>";
        $("#entry-area").append(linecode);
      }
//      $("#entry-area").val(result);
  });
}

function addSampleTab(name, id) {
  if (id == 0){
    var tag = "<li id='smplT"+id+"' role='presentation' class='active'> <a id='smplL"+id+"'href='#smplA"+id+"' aria-controls='#smplA"+id+"' role='tab' data-toggle='tab'>" + name + "</a></li>"
  } else {
    var tag = "<li id='smplT"+id+"' role='presentation'> <a id='smplL"+id+"'href='#smplA"+id+"' aria-controls='#smplA"+id+"' role='tab' data-toggle='tab'>" + name + "</a></li>"
  }
  $("#sampletab").append(tag);
  $("#smplT"+id).click(function () {
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url: 'code/insertSampleSwitchEvent.php',
        type: 'POST',
        data: { 'event': '14', 'samplename' : name, 'eyetrackerTime': iTraceEventTime},
    });
  });
}

function addSampleDisplayArea(id) {
  if (id == 0) {
    $("#tabpanel").append("<pre class='samplepre'> <code class='tab-pane form-control display-area codeSample active' id='smplA"+id+"' >empty</code> </pre>");
  } else {
    $("#tabpanel").append("<pre class='samplepre'> <code class='tab-pane form-control display-area codeSample ' id='smplA"+id+"' >empty</code> </pre>");
  }
  $("#smplA"+id).on('scroll', function() {
    //send scroll event
    if (taskStage === "sample") {
       logEvent(22, "sample", "sample");
    } else {
       logEvent(22, $("#entry-area").val(), $("#task-output").val());
    } 
  });
  $("#smplA"+id).on('click', function() {
    //send click event
    if (taskStage === "sample") {
       logEvent(23, "sample", "sample");
    } else {
       logEvent(23, $("#entry-area").val(), $("#task-output").val());
    } 
  });
}

function showModal() {
  $(".modal-title").html("Success!");
  $(".modal-body").html("<p> You have successfully solved the task! </p><p> Click the button below to go to the next part of the experiment</p>");
  $("#modal").modal();
}

function showTimeupModal() {
  $(".modal-title").html("Time up!");
  $(".modal-body").html("<p> The time for this task ran out. Please move on to the next task </p><p> To move on please click the button below</p>");
  $("#modal").modal();
}

/**
 * Check if code is correct by using checkCode.php, if yes, go to next page
 */
function checkTask(num) {
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url: 'code/checkCode.php',
        type: 'POST',
        async: true,
        data: { 'event': num, 'entry': $("#entry-area").text(), 'eyetrackerTime' : iTraceEventTime},
        complete: function(response) {
          output = JSON.parse(response.responseText);
          var joinedtext = output.outputText.join("\n");
          insertOutputText(joinedtext);

          $("#checkButton").button('reset'); // stop showing loading animation
          if (output.returncode === 0) {
            showModal();
          } else {
            if (num === 13) {
              showTimeupModal();

            }
          }
        }
    });
}

function insertOutputText(outputText) {
    $("#task-output").empty();
    var textArray = outputText.split("\n");
    var j = 0
    for(j = 0; j < textArray.length; j++) {
      var linecode = "<pre class='outputline' id='output-line-"+j+"'>"
      linecode += wrapWordsInSpan(textArray[j], "w-output-line-"+j+"-word-");
      linecode += "</pre>";
      $("#task-output").append(linecode);
    }
}


function goToNextTask() {
    clearWorkingArea();
    getNextTask();
    if (task == numTasks) {
        $.ajax({
          url: 'code/gotoFeedback.php',
          type: 'POST',
          async: true,
          complete: function (response) {
            window.location.replace("feedback.php");
          }
        });

    } else {
        displayCode();
    }
}

function clearWorkingArea() {
    $("#entry-area").text('');
    $("#tabpanel").empty();
    $("#sampletab").empty();
    deleteCookie("tasktimer");
    deleteCookie("sampletimer");
}

function displayCode() {
    taskStage = "coding";
    $("#instruction-div").hide();
    $("#assignment-div").show();
    $("#user-div").show();
    $("#best-shot-panel").show();
    $("#sampleButton").hide();
    $("#label-sample").hide();
    $("#label-code").show();
    $("#entry-area").focus();
    $("#entry-area").height(1200);
//    $("#entry-area").height($("#sample-area").height());
    clearInterval(timerInterval);
    setCaretToPos($("#entry-area")[0], 0);
    $("#entry-area").scrollTop(0);
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url: 'code/insertTaskTimeEvent.php',
        type: 'POST',
        data: { 'event': '6', 'eyetrackerTime' : iTraceEventTime},
        complete: startTimer(task.timeTask, timerTask)
    });
}

function displaySample() {
    $("#instruction-div").show();
    $("#sampleButton").show();
    $("#label-sample").show();
    $("#label-code").hide();
    $("#assignment-div").hide();
    $("#user-div").hide();
    $("#best-shot-panel").hide();
    clearInterval(timerInterval);
    iTraceEventTime = $("#iTraceEventTime").val();
    $.ajax({
        url: 'code/insertTaskTimeEvent.php',
        type: 'POST',
        data: { 'event': '5', 'eyetrackerTime' : iTraceEventTime},
        complete: startTimer(task.timeSample, timerSample)
    });
}

function getNextTask() {
    $.ajax({
        url:"code/next_task.php",
        async: false,
        complete: function (response) {
            var res = response.status + " - " + response.statusText + "\n";
            if (!response.responseText) {
                task = numTasks;
            } else {
                setUpTask(response.responseText);
            }
        },
        error: function () {
            $("#sample-area").text("There was an error");
        }
    });
}

function startTimer(duration, timerID) {
    var start = Date.now(), diff, m, s;
    if (timerID == timerTask) {
      var cookie = getCookie("tasktimer");
      if ( cookie ) {
        start = cookie;
      } else {
        document.cookie = "tasktimer="+start;
      }
    } else {
      var cookie = getCookie("tasktimer");
      if ( cookie ) {
        start = cookie;
      } else {
        document.cookie = "sampletimer="+start;
      }
    }
    var postInterval = 5;
    var whichtimer;
    if (timerID == timerTask) {
      whichtimer = "task";
    } else {
      whichtimer = "sample";
    }
    duration *= 60;
    var nextPost = duration - postInterval;
    function timer() {
        diff = duration - (((Date.now() - start) / 1000) | 0);
        if (diff <= 0) {
            if (timerID === timerTask) {
                checkTask(13);
            } else {
                displayCode();
            }
        }
        if (diff <= nextPost) {
            iTraceEventTime = $("#iTraceEventTime").val();
            $.ajax({
                url: 'code/insertCodeEvent.php',
                type: 'POST',
                data: { 'event': '7', 'entry': $("#entry-area").text(), 'timer' : diff, 'timerId' : whichtimer, 'eyetrackerTime': iTraceEventTime},
            });
            nextPost = diff - postInterval;
        }
        m = (diff / 60) | 0;
        s = (diff % 60) | 0;
        s = s < 10 ? "0" + s : s;
        timerID.textContent= m + ":" + s;
        if (diff <= 0) {
            start = Date.now() + 1000;
        }
    };
    timer();
    timerInterval = setInterval(timer, 1000);
}

function setSelectionRange(input, selectionStart, selectionEnd) {
  if (input.setSelectionRange) {
    input.focus();
    input.setSelectionRange(selectionStart, selectionEnd);
  } else if (input.createTextRange) {
    var range = input.createTextRange();
    range.collapse(true);
    range.moveEnd('character', selectionEnd);
    range.moveStart('character', selectionStart);
    range.select();
  }
}

function setCaretToPos(input, pos) {
  setSelectionRange(input, pos, pos);
}


function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') {
          c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
          return c.substring(name.length,c.length);
      }
  }
  return "";
}

function deleteCookie(name) {
  document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
}
