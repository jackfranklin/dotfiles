export interface RetryDecisionInput {
  exitCode: number;
  error?: string;
  output: string;
  toolCount: number;
  retryAfterTools?: boolean;
  cancelled: boolean;
}

/**
 * Retry only failures that are safe to replay. A fresh child has no checkpoint,
 * so a child that already used tools may be replayed only when its agent is
 * explicitly read-only. Failures before a tool begins are safe to retry once.
 */
export function shouldRetrySubagentFailure(input: RetryDecisionInput): boolean {
  if (input.cancelled || (input.exitCode === 0 && !input.error)) return false;
  if (input.toolCount === 0) return true;
  if (!input.retryAfterTools) return false;

  const text = `${input.error ?? ''}\n${input.output}`.toLowerCase();
  return /codex error:.*(?:retry|error occurred while processing)/s.test(text)
    || /\b(?:408|409|429|5\d\d)\b/.test(text)
    || /\b(?:rate limit|server error|temporarily unavailable|timed? out|network error|econn(?:reset|refused)|socket hang up)\b/.test(text);
}

export async function waitForRetry(delayMs: number, signal: AbortSignal | undefined): Promise<boolean> {
  if (signal?.aborted) return false;
  return new Promise((resolve) => {
    const timer = setTimeout(done, delayMs);
    const abort = () => done(false);
    function done(retry = true) {
      clearTimeout(timer);
      signal?.removeEventListener('abort', abort);
      resolve(retry);
    }
    signal?.addEventListener('abort', abort, { once: true });
  });
}
