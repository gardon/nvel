<?php

require_once "static_config.php";
$config = static_config();

list($lang, $path_raw) = parse_path($_GET['q']);
$path = explode('/', $path_raw);
$lang = empty($lang) ? $lang : '/' . $lang;

if (empty($path[0]) && !empty($lang)) {
  $path[0] = 'index';
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
  // Todo: find a way to respect Content-language header.
  readfile($url);
  die();
}

function parse_path($query) {
  $matches = [];
  if (preg_match('#(|index|about|chapters(?:/[0-9]+)?)/?$#', $query, $matches)) {
    list(, $path) = $matches;
    $prefix = explode('/', str_replace($path, '', $query));
    if (count($prefix) == 1 || (count($prefix) == 2 && empty($prefix[1]))) {
      $lang = $prefix[0];
      return [$lang, $path];
    }
    return FALSE;
  }
  else {
    return FALSE;
  }
}

function test_parse_path() {
  $test = [
    'index' => ['', 'index'],
    'en' => ['en', ''],
    'pt-br/' => ['pt-br', ''],
    'chapters' => ['', 'chapters'],
    'en/about' => ['en', 'about'],
    'pt-br/chapters/4' => ['pt-br', 'chapters/4'],
    'chapters/94' => ['', 'chapters/94'],
    'en/other/' => FALSE,
    'pt-br/about/us' => FALSE,
    'en/user/login' => FALSE,
    'user/login' => FALSE,
    // any loose string is parsed as a language.
    'something' => ['something', ''],
  ];
  foreach ($test as $input => $result) {
    //list($a, $b) = parse_path($input);
    if (parse_path($input) == $result) {
      print "Passed.\n";
    }
    else {
      print "Failed $input: expected [" . implode (', ', $result) . "] got [" . implode(', ', parse_path($input)) . "]\n";
    }
  }
}
