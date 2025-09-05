#!/usr/bin/env node
/**
 * @file main.mjs
 * @description A command-line script that parses ZSH alias and function definitions
 * from a list of shell files (supplied as an argument) using the
 * `@google/genai` package, caches the results, and allows searching for them
 * using fuzzy matching. Uses Yargs for argument parsing. Exports the main
 * function for potential re-use.
 */

import { fileURLToPath } from 'node:url';
import path from 'node:path';
import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import process from 'node:process';
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';
import { GoogleGenAI } from '@google/genai';
import Fuse from 'fuse.js';

// --- Configuration ---
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const GEMINI_MODEL = 'gemini-2.0-flash';

/**
 * Calculates the MD5 hash of the content of multiple files.
 * @param {string[]} filepaths - An array of paths to the files.
 * @returns {Promise<string|null>} The combined MD5 hash of the file contents, or null if an error occurs.
 */
async function calculateCombinedFileHash(filepaths) {
  const hasher = crypto.createHash('md5');
  try {
    for (const filepath of filepaths) {
      const data = await fs.readFile(filepath);
      hasher.update(data);
    }
    return hasher.digest('hex');
  } catch (error) {
    console.error('Error calculating combined file hash:', error);
    return null;
  }
}

/**
 * Loads cached alias and function data from the cache file if the source
 * shell files have not been modified since the cache was created.
 * @param {string} cacheFileName - The name of the cache file
 * @param {string[]} filepaths - An array of paths to the source shell files used for caching.
 * @param {boolean} cacheBust - If to force the cache to be ignored
 * @returns {Promise<Array<object>|null>} An array of alias and function objects if the cache is valid, otherwise null.
 */
async function loadCachedData(cacheFileName, filepaths, cacheBust) {
  try {
    const cacheContent = await fs.readFile(cacheFileName, 'utf-8');
    const cacheData = JSON.parse(cacheContent);
    const currentHash = await calculateCombinedFileHash(filepaths);
    if (cacheData?.sourceHash === currentHash && !cacheBust) {
      return cacheData.items || [];
    }
  } catch (error) {
    if (error.code !== 'ENOENT') {
      console.error('Error loading or parsing cache file:', error);
    }
  }
  return null;
}

/**
 * Fetches ZSH aliases and functions (and their keywords from comments)
 * from a list of shell files using the `@google/genai` package and a JSON schema
 * for structured output.
 * @param {string[]} filepaths - An array of paths to the shell files to parse.
 * @returns {Promise<Array<object>|null>} An array of alias and function objects extracted from the Gemini API, or null if an error occurs.
 */
async function fetchAndParseShellFiles(filepaths) {
  let allShellContent = '';
  for (const filepath of filepaths) {
    try {
      const shellContent = await fs.readFile(filepath, 'utf-8');
      allShellContent += `\n---\nFile: ${filepath}\n${shellContent}`;
    } catch (error) {
      console.error(`Error reading shell file: ${filepath}`, error);
      return null;
    }
  }

  const prompt = `You are a helpful assistant that extracts ZSH aliases and shell function definitions, along with their associated keywords from preceding comments, from the following text. The text may contain content from multiple files, separated by '---'. If there are no associated keywords, please add some to the output based on your understanding of the alias.

For example, here is an alias:

\`\`\`
# check git status
alias gs="git status"
\`\`\`

When you parse this you should produce JSON that looks like this:

\`\`\`
{
  name: 'gs',
  type: 'alias',
  definition: 'git status',
  keywords: 'check git status'
}
\`\`\`

And here is a function:

\`\`\`
# pick a branch that is on gerrit as a CL
function pickclbranch() {
  branch_name=$(git cl status --no-branch-color --date-order | awk '/ : / {print $0}' | fzf | awk '{print $1}')
  git checkout $branch_name
}
\`\`\`

When you parse this you should produce JSON that looks like this:

\`\`\`
{
  name: 'pickclbranch',
  type: 'function',
  definition: "function pickclbranch() {\n  branch_name=$(git cl status --no-branch-color --date-order | awk '/ : / {print $0}' | fzf | awk '{print $1}')\n  git checkout $branch_name\n}",
  keywords: 'pick a branch that is on gerrit as a CL'
}
\`\`\`

Important: make sure you include the entire function definition and maintain the right level of indentation in the definition string.

Your task is to process this text and return a JSON data structure as an array of objects. Each object should represent either an alias or a function and have the following keys:
- "type": Either "alias" or "function".
- "name": The name of the alias or function.
- "definition": The full command or function definition.
- "keywords": A string containing the keywords from the comment(s) immediately preceding the alias or function.

Here is the shell file content:
\`\`\`
${allShellContent}
\`\`\`

Return only the JSON output`;

  const jsonSchema = {
    type: 'array',
    items: {
      type: 'object',
      properties: {
        type: {
          type: 'string',
          enum: ['alias', 'function'],
          description: 'The type of item',
        },
        name: {
          type: 'string',
          description: 'The name of the alias or function',
        },
        definition: {
          type: 'string',
          description: 'The full command or function definition',
        },
        keywords: {
          type: 'string',
          description: 'Keywords from preceding comments',
        },
      },
      required: ['type', 'name', 'definition', 'keywords'],
    },
  };

  const key = process.env.GEMINI_API_KEY;
  if (!key) {
    throw new Error('No $GEMINI_API_KEY found');
  }
  const ai = new GoogleGenAI({ apiKey: key });
  try {
    const result = await ai.models.generateContent({
      model: GEMINI_MODEL,
      contents: prompt,
      config: {
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
      },
    });
    const structuredData = JSON.parse(result.text);
    return structuredData;
  } catch (error) {
    console.error(
      'Error interacting with Gemini API or parsing response:',
      error,
    );
    console.error('Raw Response:', result.text);
    return null;
  }
}

/**
 * Generates a deterministic JSON cache filename based on the list of input files.
 * The filename will always have the prefix "what_alias_cache_" and the suffix ".json".
 * The cache file will be created in the same directory as the script.
 * @param {string[]} filepaths - An array of paths to the shell files.
 * @returns {string} The deterministic cache filename.
 */
function generateCacheFilename(filepaths) {
  const sortedPaths = [...filepaths].sort(); // Sort to ensure order doesn't matter
  const combinedPaths = sortedPaths.join(',');
  const hash = crypto.createHash('md5').update(combinedPaths).digest('hex');
  const cachePrefix = 'what_alias_cache_';
  const cacheSuffix = '.json';

  let baseDir;
  try {
    const __filename = fileURLToPath(import.meta.url);
    baseDir = path.dirname(__filename);
  } catch (error) {
    // Handle the case where import.meta.url is not available (e.g., in CommonJS)
    baseDir = process.cwd(); // Default to current working directory
    console.warn(
      'Could not determine script directory, using current working directory for cache file.',
    );
  }

  return path.join(baseDir, `${cachePrefix}${hash}${cacheSuffix}`);
}

/**
 * Saves the extracted alias and function data to the cache file, along with the
 * combined hash of the source shell files and a timestamp.
 * @param {string} cacheFileName - The name of the cache file
 * @param {string[]} filepaths - An array of paths to the source shell files used for caching.
 * @param {Array<object>} items - An array of alias and function objects to cache.
 * @returns {Promise<void>}
 */
async function cacheParsedData(cacheFileName, filepaths, items) {
  const sourceHash = await calculateCombinedFileHash(filepaths);
  const cacheData = {
    sourceHash,
    items,
    timestamp: Date.now(),
  };
  try {
    await fs.writeFile(
      cacheFileName,
      JSON.stringify(cacheData, null, 2),
      'utf-8',
    );
    console.log('Alias and function data cached successfully.');
  } catch (error) {
    console.error('Error saving cache data:', error);
  }
}

/**
 * Finds the closest matching aliases or functions to a search string using fuzzy matching.
 * @param {Array<object>} itemsData - An array of alias and function objects to search within.
 * @param {string} searchString - The string to search for.
 * @param {number} [maxResults=3] - The maximum number of closest matches to return.
 * @returns {Array<object>} An array of the top matching alias or function objects.
 */
function findClosestMatches(itemsData, searchString, maxResults = 10) {
  const options = {
    keys: ['name', 'keywords'],
    findAllMatches: true,
    shouldSort: true,
    includeScore: true, // remember: a lower score is better!
    // threshold: 0.6, // Adjust as needed
  };
  const fuse = new Fuse(itemsData, options);
  const results = fuse.search(searchString);
  return results.slice(0, maxResults).map((result) => result.item);
}

/**
 * Recursively finds all files with a specific extension within a directory,
 * optionally filtering them by a provided function.
 *
 * @async
 * @param {string} dirPath - The absolute or relative path to the directory to search.
 * @param {string} extension - The desired file extension (e.g., '.txt', 'js', '.json').
 * The leading dot is optional and will be added if missing.
 * @param {(filePath: string) => boolean} [filterFn=(filePath) => true] - An optional
 * function that takes the full file path as an argument. If it returns `false`,
 * the file will be excluded from the results. Defaults to including all found files.
 * @returns {Promise<string[]>} A promise that resolves with an array of full file paths
 * matching the extension and filter. Returns an empty array if the
 * directory doesn't exist or is inaccessible.
 * @throws {Error} Throws errors for issues other than directory not found or access denied.
 */
async function findFilesByExtension(
  dirPath,
  extension,
  filterFn = (_filePath) => true, // Default filter includes everything
) {
  // 1. Normalize the extension
  const normalizedExtension = extension.startsWith('.')
    ? extension
    : `.${extension}`;

  let filesFound = [];

  try {
    // 2. Read the directory contents
    const entries = await fs.readdir(dirPath, { withFileTypes: true });

    // 3. Iterate through each entry
    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);

      if (entry.isDirectory()) {
        // 4. If it's a directory, recurse, passing the filter function
        const subDirFiles = await findFilesByExtension(
          fullPath,
          normalizedExtension,
          filterFn, // Pass the filter down
        );
        filesFound = filesFound.concat(subDirFiles);
      } else if (entry.isFile()) {
        // 5. If it's a file, check extension and apply filter
        if (path.extname(fullPath) === normalizedExtension) {
          if (filterFn(fullPath)) {
            // Apply the filter function
            filesFound.push(fullPath);
          }
        }
      }
      // Ignore other types like symbolic links
    }
  } catch (err) {
    // 6. Handle potential errors
    if (
      err.code === 'ENOENT' ||
      err.code === 'EACCES' ||
      err.code === 'ENOTDIR'
    ) {
      console.warn(
        `Warning: Could not read directory ${dirPath}: ${err.message}`,
      );
      return []; // Return empty array for common issues
    } else {
      console.error(`Error processing directory ${dirPath}: ${err.message}`);
      throw err; // Re-throw unexpected errors
    }
  }

  // 7. Return the list of found and filtered files
  return filesFound;
}

/**
 * The main function of the script, which uses Yargs to parse command-line arguments,
 * loads or fetches alias and function data from the provided shell files,
 * and performs the search. This function is exported for potential re-use.
 * @param {string[]} filesToProcess - An array of paths to the shell files to process.
 * @returns {Promise<void>}
 */
export async function main(filesToProcess) {
  const argv = yargs(hideBin(process.argv))
    .usage('Usage: $0 [searchTerm] [--files <path1>,<path2>,...]')
    .positional('searchTerm', {
      describe: 'The string to search for in aliases or functions',
      type: 'string',
      required: true,
    })
    .option('cacheBust', {
      describe: 'Force the cache to be cleared',
      type: 'boolean',
      default: false,
    })
    .help()
    .alias('h', 'help').argv;

  const searchTerm = argv._.join(' ');

  if (!filesToProcess || filesToProcess.length === 0) {
    console.error('Error: Please provide a list of shell files to process.');
    process.exit(1);
  }

  const cacheFileName = generateCacheFilename(filesToProcess);

  let allItemsData = await loadCachedData(
    cacheFileName,
    filesToProcess,
    argv.cacheBust,
  );

  if (!allItemsData) {
    console.log(
      'Fetching alias and function data from Gemini API using @google/genai...',
    );
    const fetchedItems = await fetchAndParseShellFiles(filesToProcess);
    if (fetchedItems) {
      await cacheParsedData(cacheFileName, filesToProcess, fetchedItems);
      allItemsData = fetchedItems;
    } else {
      console.error('Failed to retrieve alias and function data.');
      process.exit(1);
    }
  }

  if (searchTerm) {
    const closestMatches = findClosestMatches(allItemsData, searchTerm);
    if (closestMatches.length > 0) {
      console.log(
        `\nTop ${closestMatches.length} matches for '${searchTerm}':`,
      );
      closestMatches.forEach((match) => {
        console.log(`  Type: ${match.type}`);
        console.log(`  Name: ${match.name}`);
        console.log(`  Definition: ${match.definition}`);
        console.log('-'.repeat(40));
      });
    } else {
      console.log(`No matches found for '${searchTerm}'.`);
    }
  } else {
    console.log('No search term provided.');
  }
}

// Default execution when the script is run directly
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const fishAliases = path.join(__dirname, '..', 'fish', 'config.fish');
  const fishFunctionsDir = path.join(__dirname, '..', 'fish', 'functions');

  const fishFunctionsFiles = await findFilesByExtension(
    fishFunctionsDir,
    '.fish',
    (file) => {
      const fileName = path.basename(file);
      if (fileName.startsWith('__')) {
        return false;
      }
      return true;
    },
  );
  const defaultShellFiles = [
    fishAliases,
    ...fishFunctionsFiles,
    // Add more default file paths here if needed for direct execution
  ];
  main(defaultShellFiles).catch(console.error);
}
