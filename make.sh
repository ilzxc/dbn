#!/bin/sh

pegjs lang/dba.pegjs
coffee -c -b -o build/browser src/browser/*
coffee -c -b -o build/backend src/backend/*
cp build/backend/main.js index.js
cp build/browser/main.js app.js
# browserify build/browser/main.js -o app.js
# uglifyjs build/backend/main.js > index.js
# uglifyjs build/browser/main.js > app.js
