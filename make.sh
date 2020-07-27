#!/bin/sh

PHP="php"
ELM="./node_modules/elm/bin/elm make"

npm install
${ELM} src/App.elm --output=app/main.js
${PHP} minify.php app/main.js
