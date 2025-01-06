#!/usr/bin/env node

const yargs = require("yargs/yargs");
const { hideBin } = require("yargs/helpers");
const path = require("path");
const fs = require("fs");

/**
 * A function that runs to change the font used in WezTerm to a random one.
 * Stores the font in `$HOME/.font-picker.json` file.
 */

const FONTS_IN_ROTATION = [
  "Cartograph CF",
  "Berkeley Mono",
  "Comic Code",
  "DM Mono",
  "MonoLisa script",
  "Dank Mono",
  "Monaspace Argon",
  "Monaspace Neon",
  "Monaspace Xenon",
  "Fantasque Sans Mono",
  "IntelOne Mono",
];

const argv = yargs(hideBin(process.argv))
  .option("force", {
    alias: "f",
    description:
      "Force a re-run. Else this will not run if it has run already today",
    type: "boolean",
    default: false,
  })
  .help().argv;

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

function datesEqualDay(date1, date2) {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  );
}

function runAndUpdateFile(existingContents, { force }) {
  const lastRunDateTime = existingContents.lastRunDate ?? null;
  if (lastRunDateTime && !force) {
    const lastRunDate = new Date(lastRunDateTime);
    if (datesEqualDay(lastRunDate, new Date())) {
      console.log(
        "Already run today; bailing.\nRun with --force to force me to make a new choice",
      );
      process.exit(1);
    }
  }
  // exclude current font
  const choices = FONTS_IN_ROTATION.filter(
    (f) => f !== existingContents.current,
  );
  const randomIndex = Math.floor(Math.random() * choices.length);

  const date = new Date().getTime();
  const newContents = {
    lastFontChoice: FONTS_IN_ROTATION[randomIndex],
    lastRunDate: date,
  };
  fs.writeFileSync(FILE_LOCATION, JSON.stringify(newContents), {
    encoding: "utf8",
  });
  console.log(
    `Font for today chosen! You will be using ${newContents.lastFontChoice}.`,
  );
  console.log("Use shift-ctrl-c to reload WezTerm's config.");
  console.log("Not keen? Re-run with --force.");
  process.exit(0);
}

function run() {
  const contents = getContents();
  runAndUpdateFile(contents, { force: argv.force });
}

run();
