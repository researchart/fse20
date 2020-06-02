<?php 
  require_once("header.php");
  require_once('code/sql_functions.php');
?>
<div class="container-fluid">
  <h1>Study Complete</h1>
  <h3>Thank you for your participation in the study.</h3>
  <br>
  <?php 
    courseCredit();
    disconnect();
  ?>
</div>
<?php require_once("footer.php"); ?>
