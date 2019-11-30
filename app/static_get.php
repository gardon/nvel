<?php

require_once "static_config.php";
$config = static_config();

$path = explode('/', $_GET['q']);

$index = 0;
$lang = '';
switch ($path[1]) {
  case 'index':
  case 'about':
  case 'chapters':
    $index = 1;
    $lang = '/' . $path[0];
    array_shift($path);
    break;
}

switch ($path[0]) {
  case 'index':
  case 'about':
    $url = $config['backend_url'] . $lang;
    break;
  case 'chapters':
    if (count($path) == 1) {
      $url = $config['backend_url'] . $lang;
      break;
    }
    elseif (count($path) == 2 && is_numeric($path[1])) {
      $url = $config['backend_url'] . $lang . '/node/' . $path[1];
      break;
    }
    // Intentionally fallback to default fom here
  default:
    header("HTTP/1.0 404 Not Found", true, 404);
    die();
}

redirect($url);

function redirect($url) {
  readfile($url);
  die();
}
