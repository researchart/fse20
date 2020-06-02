<?php require_once('header.php');
    $_SESSION['page'] = "index.php";
?>

  <div class="container-fluid">
    <h1>Duplicate Email</h1>
    <br>
    <h4>'<?php echo getEmail() ?> 'is already in the system. You can only do this study once.<h4>
  </div>
<?php require_once('footer.php');?>
