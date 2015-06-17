#!/usr/bin/env node

process.stdin.resume();
process.stdin.on('data', function(data) {
  try {
    json = JSON.parse(data.toString());
    console.log(JSON.stringify(json, null, 2));
  } catch(err) {
    console.log(data.toString());
  }
});

process.stdin.on('end', function() { process.exit(0) });

