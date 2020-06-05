var index;
var data;
var task;
$(document).ready(function(){
  GetData();
  console.log(data);
  FillOutTable();
});
function GetData() {
  $.ajax({
    url: '../code/get_participant_list.php',
    type: 'GET',
    async: false,
    complete: function (response) {
      data = JSON.parse(response.responseText);
    }
  });
}

function FillOutTable() {
  var i;
  for (i = 0; i < data.length; i++) {
    var lang = "";
    if (data[i].lang == 1) {
      lang = "hybrid";
    } else if (data[i].lang == 2) {
      lang = "polyglot";
    } else if (data[i].lang == 3) {
      lang = "object";
    } else if (data[i].lang == 0) {
      lang = "error"
    }

    var tablerow = "<tr>"
    tablerow += "<td> " + data[i].id + " </td>";
    tablerow += "<td> " + lang  + " </td>";
    tablerow += "<td> " + data[i].year + " </td>";
    tablerow += "<td> " + data[i].major + " </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=0'> task0 </a> </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=1'> task1 </a> </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=2'> task2 </a> </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=3'> task3 </a> </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=4'> task4 </a> </td>";
    tablerow += "<td> <a href='codereview.php?id=" + data[i].id + "&task=5'> task5 </a> </td>";
    tablerow += "</tr>";
    $("#participants").append(tablerow);
  }
}
