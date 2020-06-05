var index;
var data;
var task;
$(document).ready(function(){
    $("#prev").click(function(){
      if (index === 0)
          index = data.length-1;
      else
          index--;
      LoadParticipant(index);
    });
    $("#next").click(function(){
      if (index === data.length-1)
          index = 0;
      else
          index++;
      LoadParticipant(index);
    });
    $("#T1").click(function() {
      task=1;
      LoadAnswer();
    });
    $("#T2").click(function() {
      task=2;
      LoadAnswer();
    });
    $("#T3").click(function() {
      task=3;
      LoadAnswer();
    });
});
$(window).load(function() {
      index=0;
      task=1;
      GetData();
      LoadParticipant(index);
});
function GetData() {
  $.ajax({
    url: '../code/get_data.php',
    type: 'GET',
    async: false,
    complete: function (response) {
      data = JSON.parse(response.responseText);
    }
  });
}
function LoadParticipant(i) {
  $("#idDisplay").text(i+1+" / "+data.length);
  $("#id").text(data[i].id);
  $("#language").text(data[i].lang);
  $("#event1ts").text(data[i].event1);
  $("#event2ts").text(data[i].event2);
  $("#event3ts").text(data[i].event3);
  $("#event4ts").text(data[i].event4);
  $("#event8Ats").text(data[i].event8A);
  $("#event8Bts").text(data[i].event8B);
  $("#event8Cts").text(data[i].event8C);
  $("#event10ts").text(data[i].event10);
  $("#event11ts").text(data[i].event11);
  $("#year").text(data[i].year);
  $("#concepts").text(data[i].concepts);
  $("#design").text(data[i].design);
  $("#comments").text(data[i].comments);
  LoadAnswer(task);
}
function LoadAnswer() {
  if (task===1) {
      $("#entry-area").text(data[index].answer1);
  } else if (task===2) {
      $("#entry-area").text(data[index].answer2);
  } else if (task===3) {
      $("#entry-area").text(data[index].answer3);
  }
}
