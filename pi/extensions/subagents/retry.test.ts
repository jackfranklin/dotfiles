import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { shouldRetrySubagentFailure } from './retry.ts';

const base = {
  exitCode: 1,
  output: '',
  toolCount: 0,
  cancelled: false,
};

describe('subagent retry policy', () => {
  it('retries an unexpected failure before a tool begins', () => {
    assert.equal(shouldRetrySubagentFailure(base), true);
  });

  it('retries a Codex transient error after a read-only review', () => {
    assert.equal(
      shouldRetrySubagentFailure({
        ...base,
        error:
          'Codex error: An error occurred while processing your request. You can retry your request.',
        toolCount: 64,
        retryAfterTools: true,
      }),
      true,
    );
  });

  it('does not replay an implementation after it has used tools', () => {
    assert.equal(
      shouldRetrySubagentFailure({
        ...base,
        error:
          'Codex error: An error occurred while processing your request. You can retry your request.',
        toolCount: 1,
      }),
      false,
    );
  });

  it('does not retry cancellation or a completed child', () => {
    assert.equal(shouldRetrySubagentFailure({ ...base, cancelled: true }), false);
    assert.equal(
      shouldRetrySubagentFailure({ ...base, exitCode: 0, toolCount: 3, retryAfterTools: true }),
      false,
    );
  });
});
