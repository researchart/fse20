<?php
    session_start();
    require_once('sql_functions.php');

    set_include_path(get_include_path() . PATH_SEPARATOR . 'phpseclib');

    include('Net/SSH2.php');
    include('Crypt/RSA.php');
    include('Net/SCP.php');

    $ssh = new Net_SSH2('superkitty');
    $key = new Crypt_RSA();
    $key->loadKey(file_get_contents('id_rsa'));
    if (!$ssh->login('daleiden', $key)) {
        exit('Login Failed');
    }

    $id = (int) $_SESSION['id'];
    $currenttask = (int) $_SESSION['currentTask']+1;
    $group = $_SESSION['group'];
    $tries = $_POST['tries'];
    $ldir = $_POST['dir']; 
    $fname = getFileName($id, $currenttask, $group, $tries);

    $rdir = "tmp/";
    $scp = new Net_SCP($ssh);
    $executable = $rdir . str_replace(".cu", "", $fname);
    $checkfile = "check".$currenttask."_".$group.".cu";
        
    #to activate ability to compile, uncomment these lines:
    $scp->put($rdir.$fname, $ldir.$fname, SOURCE_LOCAL_FILE);
    if ($currenttask == 1) {
        $result = $ssh->exec('nvcc -o '.$executable.' '.$rdir.$fname);
    } else {
        $result = $ssh->exec('nvcc -o '.$executable.' '.$rdir.$fname.' '.$rdir.$checkfile);
    }
    if ($result == "") {
        echo $ssh->exec($executable);
    } else {
        echo $result;
    }
    #echo "Experiment currently disabled";
    
?>
