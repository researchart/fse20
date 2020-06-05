<html>
  <head>
    <!--<script type="text/javascript" src="http://localhost/~Rocket_Space_Station/enum2.json"></script>--> 
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>

    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <style type="text/css">
      td {
      width: 50px;
      }</style>

    
    <script type="text/javascript">
      $(function()
      {
      $.getJSON('type.json',function(data)
          {
      console.log('success');
      $.each(data,function(i,quest)
      {
        console.log("in first loop");
        var questionContainer = "<div id='Question"+i+"'>";
	questionContainer += "</div>";
        $("#content").append(questionContainer); //adding question container to the content container

      // Add concept div for concept and description paragraphs to Question+i div
        var conceptContainer = "<div id='conceptBox"+i+"'>";
        conceptContainer += "</div>";
      $("#Question"+i).append(conceptContainer);

      var htmlTableString = "";
      htmlTableString +=  "<table id='Question"+i+"Table'>";
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
        htmlTableString += "<hr>";

	console.log(htmlTableString);
      
	$("#Question"+i).append(htmlTableString);
	
        // Add table to Question+i div
        // table should have header row already in it
       console.log("test: " + quest);
        var conceptString = "<p>";
	    conceptString += quest.concept;
	    conceptString += "</p>";
        var descriptionString = "<p>";
	    descriptionString += quest.description;
	descriptionString += "</p>";
      $("#conceptBox"+i).append(conceptString);
      $("#conceptBox"+i).append(descriptionString);
       $.each(quest.options,function(j,opt)
        {
          console.log("option:" + opt.option);
      
          var htmlstring = " <tr>\n";
          htmlstring += "<td>"+opt.option+"</td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='10' id='q10'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='9' id='q9'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='8' id='q8'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='7' id='q7'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='6' id='q6'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='5' id='q5'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='4' id='q4'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='3' id='q3'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='2' id='q2'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='1' id='q1'/></td>";
          htmlstring += "<td><input type='radio' name='radQ"+i+"-"+j+"' value='0' id='q0'/></td>";
          htmlstring += "</tr> ";
      
          $("#Question"+i+"Table").append(htmlstring);

        });
      });
      })
      .error(function()
        {
             console.log('error');
        });
  });
  
</script>
  </head>
  <body>
    <h1> Type Survey </h1>
    <form action="" method="post" name="frmSurvey">

      <div id="content">
	
   
    </div>
    </form>


</body>
</html>
