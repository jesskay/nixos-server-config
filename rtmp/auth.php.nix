user : pass : ''
  <?php
  if(empty($_POST['user']) || empty($_POST['pass'])) {
    header('HTTP/1.1 400 Bad Request');
    die('Invalid query.');
  } else if(strcmp($_POST['user'], '${user}')==0 && strcmp($_POST['pass'], '${pass}')==0) {
    echo('Great! Valid user/pass!');
  } else {
    header('HTTP/1.1 403 Forbidden');
    die('Bad user/pass.');
  }
  ?>
''
