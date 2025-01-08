#!/usr/bin/env node
const path = require("path");
const fs = require("fs");

const FILE_LOCATION = path.join(process.env.HOME, ".font-picker.json");

const EMPTY_FILE = {
  lastRunDate: undefined,
  lastFontChoice: undefined,
};

function getContents() {
  const exists = fs.existsSync(FILE_LOCATION);
  if (!exists) {
    return EMPTY_FILE;
  }

  try {
    const content = fs.readFileSync(FILE_LOCATION, "utf8");
    return JSON.parse(content);
  } catch {
    return EMPTY_FILE;
  }
}

function run() {
  const { lastFontChoice } = getContents();
  if (!lastFontChoice) {
    console.error("Something went wrong, no font found");
  }
  console.log(`Your current font is ${lastFontChoice}.`);
}
run();
