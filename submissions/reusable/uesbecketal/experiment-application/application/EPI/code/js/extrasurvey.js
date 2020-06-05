var _currentQuestion;
var _questionJSON;
var _totalQuestions;
var _totalOptions;

$(document).ready(function() {
  $.ajax({
          url: 'code/get_survey_status.php',
          complete: function (response) {
            var status = JSON.parse(response.responseText);
            _currentQuestion = status.surveyquestion;
            createFormTables();
          }
    });

});

function createFormTables() {
  $.getJSON('code/enum.json',function(data) { //potentially change to .php page to load data on server first
    _questionJSON = data;
//    _currentQuestion = 0;
    _totalQuestions = data.length;
    if (_currentQuestion >= _totalQuestions){
        $.ajax({
          url: 'code/insertTimeEventSurvey.php',
          type: 'POST',
          data: { "event" : 19},
        }); // ending message

        window.location.replace("survey_2.php");
    }
    createQuestion(_currentQuestion);
    changeTaskNum(_currentQuestion+1, _totalQuestions);
    if (_currentQuestion === _totalQuestions -1) {
      $("#nextButton").html("Complete");
    }

  })
  .error(function() {
    console.log('error');
  });
  $("#nextButton").click( function () {
        submit();
  });
}

function submit() {
  var i;
  var results = [];
  var unfilledRows = 0;
  var rows = $('tr', "#Question"+_currentQuestion+"Table");
  var rowlist = [];
  resetErrors(rows);
  for (i = 0; i < _totalOptions; i++) {
    var groupName = "radN"+i
    var valueCurrentRow = $("input:radio[name='"+groupName+"']:checked").val();
    var optionname = "O" +i;
    var questionid = _questionJSON[_currentQuestion].QID;
    if(valueCurrentRow) {
      results.push({
        "option" : optionname,
        "QID" : questionid,
        "value" : valueCurrentRow
      });
    } else {
      var currentrow = rows.eq(i+2);
      currentrow.addClass("redrow");

      rowlist.push(currentrow);
      unfilledRows = unfilledRows + 1;
    }
  }
  if (unfilledRows > 0) {
    $("#errorAlert").show();
    $("#errorAlert").attr("aria-hidden", "false");
    $.ajax({
          url: 'code/insertSurveyError.php',
          type: 'POST',
          data: { "unfilledRows" : unfilledRows}
    }); // submission of error event
    return;
  } else {
    console.log("starting validation");
    $.ajax({
          url: 'code/validate_survey3.php',
          type: 'POST',
          data: { "results" : results},
          complete : function (response) {
          }
    }); // submission of values
    if (_currentQuestion >= _totalQuestions - 1){
      $.ajax({
          url: 'code/insertTimeEventSurvey.php',
          type: 'POST',
          data: { "event" : 19},
      }); // ending message
      window.location.replace("survey_2.php");
    } else {
      nextQuestion();
    }
  }
}

function resetErrors(rowlist) {
    rowlist.removeClass("redrow");
    $("#errorAlert").hide();
    $("#errorAlert").attr("aria-hidden","true");
}
function changeTaskNum(current, total) {
  $("#question-num").html("Question: " + current + " of " + total); 
}


function nextQuestion() {
  _currentQuestion = _currentQuestion + 1;
  if (_currentQuestion < _totalQuestions) {
    $("#content").empty();
    createQuestion(_currentQuestion);
    changeTaskNum(_currentQuestion+1, _totalQuestions);
    if (_currentQuestion === _totalQuestions -1) {
      $("#nextButton").html("Complete");
    }
    window.scrollTo(0,0);
  } else {
    // finish up
  }
}

function createQuestion(questionnumber) {
    question = _questionJSON[questionnumber];
    $("#content").append(createQuestionContainer(questionnumber));
    $("#Question"+questionnumber).append(createConceptContainer(questionnumber));
    $("#Question"+questionnumber).append(createQuestionTable(questionnumber));
    $("#conceptBox"+questionnumber).append(createConceptString(question.concept));
    $("#conceptBox"+questionnumber).append(createDescriptionString(question.description));
    createQuestionRows(question,questionnumber);
}

function createQuestionRows(question, i) {
  $.each(question.options,function(j,option) {
    $("#Question"+i+"Table").append(createOptionRow(i,j,option.option));
    _totalOptions = question.options.length;
  });
}

function createOptionRow(i,j,option) {
  var htmlstring = "<tr>";
  htmlstring += "<td>"+option+"</td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-00' value='0' id='q0'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-01' value='1' id='q1'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-02' value='2' id='q2'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-03' value='3' id='q3'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-04' value='4' id='q4'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-05' value='5' id='q5'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-06' value='6' id='q6'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-07' value='7' id='q7'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-08' value='8' id='q8'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-09' value='9' id='q9'/></td>";
  htmlstring += "<td><input type='radio' name='radN"+j+"' id='radQ"+j+"-10' value='10' id='q10'/></td>";
  htmlstring += "</tr>";
  return htmlstring;
}

function createConceptString(concept) {
  var conceptString = "<div class='row'> <p>";
  conceptString += concept;
  conceptString += "</p> </div>";
  return conceptString;
}

function createDescriptionString(description) {
  var descriptionString = "<div class='row'> <p>";
  descriptionString += description;
  descriptionString += "</p> </div>";
  return descriptionString;
}


function createQuestionTable(i) {
  var htmlTableString = "";
//  htmlTableString += "<div class='col-md-4 col-md-offset-1';
  htmlTableString += "<div class='row'>";
  htmlTableString += "<table id='Question"+i+"Table' class='col-md-6 surveytable table table-striped table-hover'>";
  htmlTableString += "<tr>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td>low</td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td> </td>";
  htmlTableString += "<td>high</td>";
  htmlTableString += "</tr>";
  htmlTableString += "<tr>";
  htmlTableString += "<td><size='200'></td>";
  htmlTableString += "<td><label for='q0'>0</label></td>";
  htmlTableString += "<td><label for='q1'>1</label></td>";
  htmlTableString += "<td><label for='q2'>2</label></td>";
  htmlTableString += "<td><label for='q3'>3</label></td>";
  htmlTableString += "<td><label for='q4'>4</label></td>";
  htmlTableString += "<td><label for='q5'>5</label></td>";
  htmlTableString += "<td><label for='q6'>6</label></td>";
  htmlTableString += "<td><label for='q7'>7</label></td>";
  htmlTableString += "<td><label for='q8'>8</label></td>";
  htmlTableString += "<td><label for='q9'>9</label></td>";
  htmlTableString += "<td><label for='q10'>10</label></td>";
  htmlTableString += "</tr>";
  htmlTableString += "</table>";
  htmlTableString += "<br/>";
  htmlTableString += "</div>";
  htmlTableString += "<hr>";
  return htmlTableString;
}

function createQuestionContainer(i) { 
  var questionContainer = "<div id='Question"+i+"'>";
  questionContainer += "</div>";
  return questionContainer;
}

function createConceptContainer(i) {
  var conceptContainer = "<div id='conceptBox"+i+"'>";
  conceptContainer += "</div>";
  return conceptContainer;
}
