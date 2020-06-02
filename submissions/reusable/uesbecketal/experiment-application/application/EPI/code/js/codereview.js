var index;
var data;

$(document).ready(function(){
  GetData();
  console.log(data);
  index = 0;
  var fragment = window.location.hash;
  if (fragment){
    fragment = fragment.substring(1);
    index = fragment-1;
  }
  updateState();
  DisplayData(index);

  SetGeneralInfo();

  $("#next").click(function(){
    Next();
  });
  $("#prev").click(function(){
    Previous();
  });
  $("#nextSig").click(function(){
    NextSignificant();
  });
  $("#prevSig").click(function(){
    PreviousSignificant();
  });
  
  $(document).keydown(function(e) {
       switch(e.which) {
          case 37: // left
            Previous();
          break;

          case 39: // right
            Next();
          break;

          case 65: // a
            PreviousSignificant();
          break;

          case 68: // d
            NextSignificant();
          break;

          default: return; // exit this handler for other keys
       }
  });
});

function GetData() {
  var id = getUrlParameter("id");
  var task = getUrlParameter("task");

  console.log(id);
  console.log(task);

  $.ajax({
    url: '../code/get_codereview.php',
    type: 'POST',
    async: false,
    data: { id : id, task : task},
    complete: function (response) {
      data = JSON.parse(response.responseText);
    }
  });
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

function Next(){
    if (index < data.length - 1) {
      index += 1;
      updateState();
      DisplayData(index);
    }
}

function Previous(){
    if (index > 0) {
      index -= 1;
      updateState();
      DisplayData(index);
    }
}

function NextSignificant() {
  if (index < data.length - 1) {
    index = FindNextSignificant(index+1);
    updateState();
    DisplayData(index);
  }
}

function PreviousSignificant() {
  if (index > 0) {
    index = FindLastSignificant(index-1);
    updateState();
    DisplayData(index);
  }
}

function FindNextSignificant(i) {
  if (i == data.length
      || data[i].event == 12 
      || data[i].event == 8
      || data[i].event == 13
      || data[i].event == 22) {
    return i;
  } 
  return FindNextSignificant(i+1);
}

function FindLastSignificant(i) {
  if (i == 0
      || data[i].event == 12 
      || data[i].event == 8
      || data[i].event == 13 
      || data[i].event == 22) {
    return i;
  } 
  return FindLastSignificant(i-1);
}

function GoTo(newIndex) {
  if (newIndex >= 0 && newIndex < data.length ) {
    index = newIndex;
    updateState();
    DisplayData(index);
  }
}

function DisplayData(index) {

  // display code
  $("#codeplace").html(data[index].entry);

  // format output
  if (data[index].output) {
    var str = data[index].output.replace(/(?:\\n)/g, '<br />');
    $("#output").html(str);
  } else {
    $("#output").html("empty");
  }

  // display time
  var timediff = TimeDifference( data[0].time, data[index].time);
  $("#time").html("<div> Time in seconds: " + timediff.valueOf()/1000+ " </div> <div>Time passed: " + timediff.getMinutes() + "m " + timediff.getSeconds() + "s </div> <div> Timestamp: " + data[index].time + "</div>");
  
  // display event info
  var info = $(".info");
  var evntStr = "Event: " + data[index].event;

  if ( data[index].event == 7) {
    evntStr += " (periodicCode)";
    removeColorClasses(info);
  } else if ( data[index].event == 12) {
    evntStr += " (codeCheck)";
    removeColorClasses(info);
    info.addClass("yellowbackground");
  } else if ( data[index].event ==  8) {
    evntStr += " (codeFinished)";
    removeColorClasses(info);
    info.addClass("greenbackground");
  } else if ( data[index].event == 22) {
    evntStr += " (wrongResult)";
    removeColorClasses(info);
    info.addClass("orangebackground");
  } else if ( data[index].event == 13) {
    evntStr += " (timeUpCodeSubmit)";
    removeColorClasses(info);
    info.addClass("redbackground");
  }

  $("#event").html(evntStr);
}

function SetGeneralInfo() {
  var task = getUrlParameter("task");
  var lang = "undefined";
  if (data[index].lang == 1) {
    lang = "RBasic";
  } else if (data[index].lang == 2) {
    lang = "Tilda";
  } else if (data[index].lang == 3) {
    lang = "Tidy";
  } else if (data[index].lang == 0) {
    lang = "error"
  }

  var generalInfoString = "Task: <b>" + (Number(task)) + "</b> Year: <b>" + data[index].year + "</b> - Group: <b>" + lang+ "</b> - Major: <b>" + data[index].major + "</b>"; 

  $("#generalInfo").html(generalInfoString);
}

function removeColorClasses(element) {
  element.removeClass("yellowbackground");
  element.removeClass("greenbackground");
  element.removeClass("redbackground");
  element.removeClass("orangebackground");
}

function TimeDifference(timestart, timecurrent) {
  var startDate = new Date(timestart);
  var currentDate = new Date(timecurrent);
  return new Date(currentDate - startDate);
}

function updateState() {
  updateNumber();
  if (index === data.length - 1){
    $("#next").prop('disabled','true');
    $("#nextSig").prop('disabled','true');
  } else {
    $("#next").removeAttr('disabled'); 
    $("#nextSig").removeAttr('disabled');
  }
  if (index === 0){
    $("#prev").prop('disabled','true');
    $("#prevSig").prop('disabled','true');
  } else {
    $("#prev").removeAttr('disabled');
    $("#prevSig").removeAttr('disabled');
  }
}

function updateNumber(){ 
  $("#number").html(index+1 + " of " + data.length);
  window.location.hash = index+1;
}
