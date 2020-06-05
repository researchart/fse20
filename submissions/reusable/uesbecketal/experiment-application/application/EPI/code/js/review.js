var taskList;
$(document).ready(function(){
    $("#L1").click(function(){
      LoadTaskList(1);
      curr = $("#num").text() - 1;
      LoadTask(curr);
    });
    $("#L2").click(function(){
      LoadTaskList(2);
      curr = $("#num").text() - 1;
      LoadTask(curr);
    });
    $("#T1").click(function() {
      LoadTask(0);
    });
    $("#T2").click(function() {
      LoadTask(1);
    });
    $("#T3").click(function() {
      LoadTask(2);
    });
});
$(window).load(function() {
      LoadTaskList(1);
      LoadTask(0);
});
function LoadTaskList(num) {
  $.ajax({
    url: '../code/get_task_review.php',
    type: 'POST',
    async: false,
    data: { 'language': num},
    complete: function (response) {
      taskList = JSON.parse(response.responseText);
    }
  });
}
function LoadTask(num) {
  $("#num").text(num+1);
  task = taskList[num];
  $("#task-description").load("../documents/" + task.taskDesc);
  $("#task-output").load("../documents/" + task.taskOutput);
  $("#sample-area").load("../documents/" + task.codeSample);
}
