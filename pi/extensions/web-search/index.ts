import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { Type } from 'typebox';
import { Text } from '@earendil-works/pi-tui';
import * as fs from 'node:fs';
import * as path from 'node:path';

interface SearchResult {
  title: string;
  url: string;
  snippet: string;
  publishedDate?: string;
  author?: string;
}

interface StructuredSearchArgs {
  query?: string;
  exactPhrases?: string[];
  excludeTerms?: string[];
  site?: string;
  includeDomains?: string[];
  excludeDomains?: string[];
  count?: number;
}

interface BuiltSearchQuery {
  query: string;
  baseQuery?: string;
  exactPhrases: string[];
  excludeTerms: string[];
  includeDomains: string[];
  excludeDomains: string[];
}

interface ExaSearchResponse {
  results?: Array<{
    title?: string;
    url?: string;
    text?: string;
    highlights?: string[];
    highlightScores?: number[];
    publishedDate?: string;
    author?: string;
  }>;
}

const EXT_DIR = path.dirname(new URL(import.meta.url).pathname);
const AUTH_PATH = path.join(EXT_DIR, 'auth.json');
const EXA_SEARCH_URL = 'https://api.exa.ai/search';

function loadCredentials(): { apiKey: string } | null {
  const envApiKey = process.env.EXA_API_KEY;
  if (envApiKey) return { apiKey: envApiKey };

  if (!fs.existsSync(AUTH_PATH)) return null;
  try {
    const config = JSON.parse(fs.readFileSync(AUTH_PATH, 'utf-8'));
    const apiKey = config.exa_api_key as string;
    if (apiKey) return { apiKey };
  } catch {}
  return null;
}

function stripWrappingQuotes(value: string): string {
  return value.length >= 2 && value.startsWith('"') && value.endsWith('"')
    ? value.slice(1, -1).trim()
    : value;
}

function cleanItems(values?: string[]): string[] {
  if (!values) return [];
  return values
    .map((value) => stripWrappingQuotes(value.trim().replace(/\s+/g, ' ')))
    .filter(Boolean);
}

function cleanQuery(value?: string): string | undefined {
  if (typeof value !== 'string') return undefined;
  const cleaned = value.trim().replace(/\s+/g, ' ');
  return cleaned || undefined;
}

function normalizeDomain(value?: string): string | undefined {
  if (typeof value !== 'string') return undefined;

  let domain = value
    .trim()
    .replace(/^site:/i, '')
    .trim();
  if (!domain) return undefined;

  try {
    const candidate = /^[a-z]+:\/\//i.test(domain)
      ? domain
      : `https://${domain}`;
    const url = new URL(candidate);
    if (url.hostname) domain = url.hostname;
  } catch {}

  return domain.replace(/^www\./, '').replace(/\/+$/, '') || undefined;
}

function normalizeDomains(values?: string[]): string[] {
  const domains = cleanItems(values)
    .map(normalizeDomain)
    .filter((domain): domain is string => Boolean(domain));
  return [...new Set(domains)];
}

function quoteForSearch(value: string): string {
  return `"${value.replace(/"/g, '\\"')}"`;
}

function buildSearchQuery(args: StructuredSearchArgs): BuiltSearchQuery {
  const baseQuery = cleanQuery(args.query);
  const exactPhrases = cleanItems(args.exactPhrases);
  const excludeTerms = cleanItems(args.excludeTerms);
  const includeDomains = normalizeDomains([
    ...(args.includeDomains ?? []),
    ...(args.site ? [args.site] : []),
  ]);
  const excludeDomains = normalizeDomains(args.excludeDomains);

  if (!baseQuery && exactPhrases.length === 0) {
    throw new Error("At least one of 'query' or 'exactPhrases' is required.");
  }

  const parts: string[] = [];
  if (baseQuery) parts.push(baseQuery);
  for (const phrase of exactPhrases) {
    parts.push(quoteForSearch(phrase));
  }
  for (const term of excludeTerms) {
    parts.push(`-${term.includes(' ') ? quoteForSearch(term) : term}`);
  }

  return {
    query: parts.join(' '),
    baseQuery,
    exactPhrases,
    excludeTerms,
    includeDomains,
    excludeDomains,
  };
}

function firstUsefulSnippet(
  result: NonNullable<ExaSearchResponse['results']>[number],
): string {
  const highlight = result.highlights?.find((item) => item.trim());
  if (highlight) return highlight.replace(/\s+/g, ' ').trim();

  const text = result.text?.replace(/\s+/g, ' ').trim();
  if (!text) return '';
  return text.length > 300 ? `${text.slice(0, 297)}...` : text;
}

async function exaSearch(
  built: BuiltSearchQuery,
  count: number,
  apiKey: string,
  signal?: AbortSignal,
): Promise<SearchResult[]> {
  const body: Record<string, unknown> = {
    query: built.query,
    numResults: Math.min(count, 10),
    contents: { highlights: true },
  };

  if (built.includeDomains.length > 0) {
    body.includeDomains = built.includeDomains;
  }
  if (built.excludeDomains.length > 0) {
    body.excludeDomains = built.excludeDomains;
  }

  const resp = await fetch(EXA_SEARCH_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    },
    body: JSON.stringify(body),
    signal,
  });

  if (!resp.ok) {
    const responseBody = await resp.text();
    throw new Error(`Exa API ${resp.status}: ${responseBody.slice(0, 500)}`);
  }

  const data = (await resp.json()) as ExaSearchResponse;
  return (data.results ?? [])
    .filter((result) => result.url)
    .map((result) => ({
      title: result.title || result.url || 'Untitled',
      url: result.url!,
      snippet: firstUsefulSnippet(result),
      publishedDate: result.publishedDate,
      author: result.author,
    }));
}

function formatResults(results: SearchResult[]): string {
  if (results.length === 0) return 'No results found.';
  return results
    .map((result, index) => {
      const metadata = [result.author, result.publishedDate]
        .filter(Boolean)
        .join(' · ');
      return [
        `${index + 1}. ${result.title}`,
        `   ${result.url}`,
        metadata ? `   ${metadata}` : undefined,
        result.snippet ? `   ${result.snippet}` : undefined,
      ]
        .filter(Boolean)
        .join('\n');
    })
    .join('\n\n');
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: 'web_search',
    label: 'Web Search',
    description:
      'Search the web via Exa. Build one search per call from a base query string, exact phrases, exclusions, and optional domain filters. Returns title, URL, snippet/highlight, author, and published date when available.',
    promptSnippet:
      'Search the web via Exa with query, exactPhrases, excludeTerms, site/includeDomains/excludeDomains, and count. Use one tool call per search angle.',
    promptGuidelines: [
      'Use exactPhrases for exact phrase matching instead of embedding quote marks inside the main query string.',
      'Use one web_search tool call per search angle instead of batching multiple searches into one call.',
      'Use web_search site or includeDomains when the user wants results from specific domains.',
    ],

    parameters: Type.Object({
      query: Type.Optional(
        Type.String({
          description:
            'Base search query as a normal string. Prefer this for the main search wording.',
        }),
      ),
      exactPhrases: Type.Optional(
        Type.Array(Type.String(), {
          description:
            'Exact phrases to match. Each item becomes a quoted phrase in the final search query.',
        }),
      ),
      excludeTerms: Type.Optional(
        Type.Array(Type.String(), {
          description:
            'Terms or phrases to exclude. Multi-word items are excluded as exact phrases.',
        }),
      ),
      site: Type.Optional(
        Type.String({
          description:
            'Optional single site/domain restriction, such as example.com or a full URL.',
        }),
      ),
      includeDomains: Type.Optional(
        Type.Array(Type.String(), {
          description:
            'Optional list of domains to include. Results will only come from these domains.',
        }),
      ),
      excludeDomains: Type.Optional(
        Type.Array(Type.String(), {
          description:
            'Optional list of domains to exclude from search results.',
        }),
      ),
      count: Type.Optional(
        Type.Number({
          description: 'Number of results to return (default: 5, max: 10)',
          minimum: 1,
          maximum: 10,
        }),
      ),
    }),

    async execute(_toolCallId, params: StructuredSearchArgs, signal) {
      const creds = loadCredentials();
      if (!creds) {
        throw new Error(
          `Missing Exa credentials. Set EXA_API_KEY, or create ${AUTH_PATH} from auth.example.json. Get a key from https://dashboard.exa.ai/api-keys`,
        );
      }

      const count = params.count ?? 5;
      const built = buildSearchQuery(params);
      const results = await exaSearch(built, count, creds.apiKey, signal);

      return {
        content: [
          {
            type: 'text' as const,
            text: formatResults(results),
          },
        ],
        details: {
          provider: 'exa',
          composedQuery: built.query,
          query: built.baseQuery,
          exactPhrases: built.exactPhrases,
          excludeTerms: built.excludeTerms,
          includeDomains: built.includeDomains,
          excludeDomains: built.excludeDomains,
          resultCount: results.length,
        },
      };
    },

    renderCall(args, theme, context) {
      const text =
        (context.lastComponent as Text | undefined) ?? new Text('', 0, 0);
      const { count, ...searchArgs } = args as StructuredSearchArgs;

      try {
        const built = buildSearchQuery(searchArgs);
        const display =
          built.query.length > 70
            ? `${built.query.slice(0, 67)}...`
            : built.query;
        const lines = [
          theme.fg('toolTitle', theme.bold('search ')) +
            theme.fg('accent', `"${display}"`),
        ];
        if (built.includeDomains.length > 0) {
          lines.push(
            theme.fg('dim', `  include: ${built.includeDomains.join(', ')}`),
          );
        }
        if (built.excludeDomains.length > 0) {
          lines.push(
            theme.fg('dim', `  exclude: ${built.excludeDomains.join(', ')}`),
          );
        }
        if (count && count !== 5) {
          lines.push(theme.fg('dim', `  count: ${count}`));
        }
        text.setText(lines.join('\n'));
        return text;
      } catch {
        text.setText(
          theme.fg('toolTitle', theme.bold('search ')) +
            theme.fg('error', '(invalid query)'),
        );
        return text;
      }
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      const text =
        (context.lastComponent as Text | undefined) ?? new Text('', 0, 0);

      if (isPartial) {
        text.setText(theme.fg('warning', 'Searching…'));
        return text;
      }

      if (context.isError) {
        const msg =
          result.content.find((content) => content.type === 'text')?.text ||
          'Error';
        text.setText(theme.fg('error', msg));
        return text;
      }

      const details = result.details as {
        composedQuery?: string;
        resultCount?: number;
      };
      const status = theme.fg(
        'success',
        `${details?.resultCount ?? 0} results`,
      );
      if (!expanded) {
        text.setText(status);
        return text;
      }

      const content =
        result.content.find((item) => item.type === 'text')?.text || '';
      const preview =
        content.length > 500 ? `${content.slice(0, 500)}...` : content;
      const queryLine = details?.composedQuery
        ? theme.fg('dim', `query: ${details.composedQuery}`)
        : '';
      text.setText(
        [status, queryLine, theme.fg('dim', preview)]
          .filter(Boolean)
          .join('\n'),
      );
      return text;
    },
  });
}
