#!/bin/sh

PHP="php"
ELM="elm make"

${ELM} src/App.elm --output=app/main.js
${PHP} minify.php app/main.js
