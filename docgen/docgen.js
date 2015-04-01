#! /usr/bin/env node

var markdox = require('markdox');

markdox.process('./../src/lks/bmputils/BmpOutputOptions.as', './_output.md', function(){
  console.log('"docgen/_output.md" created.');
});

