import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  appendApprovalRationaleGuidance,
  approvalRationaleForToolCall,
} from './index.ts';

function assistant(content: unknown[]) {
  return { role: 'assistant', content } as never;
}

describe('appendApprovalRationaleGuidance', () => {
  it('tells the model to reserve rationales for rejected approval-required calls', () => {
    assert.equal(
      appendApprovalRationaleGuidance('Base instructions.'),
      `Base instructions.

Permission approval protocol:
- Do not write an \`Approval rationale:\` paragraph speculatively or to narrate ordinary work.
- Include one only when the permissions extension previously rejected this tool call with \`Approval explanation required\`, then retry that approval-required operation with the rationale immediately before its tool call.`,
    );
  });
});

describe('approvalRationaleForToolCall', () => {
  it('uses the labelled text before the matching tool call', () => {
    const rationale = approvalRationaleForToolCall(
      [
        assistant([
          {
            type: 'text',
            text: 'Approval rationale:\nThis removes the obsolete fixture.\nIt is needed to complete the requested cleanup.',
          },
          {
            type: 'toolCall',
            id: 'remove-fixture',
            name: 'bash',
            arguments: {},
          },
        ]),
      ],
      'remove-fixture',
    );

    assert.equal(
      rationale,
      'This removes the obsolete fixture. It is needed to complete the requested cleanup.',
    );
  });

  it('does not use text after the tool call or from a different call', () => {
    const messages = [
      assistant([
        {
          type: 'text',
          text: 'Approval rationale: This belongs to a different operation.',
        },
        { type: 'toolCall', id: 'other', name: 'bash', arguments: {} },
      ]),
      assistant([
        { type: 'toolCall', id: 'target', name: 'bash', arguments: {} },
        { type: 'text', text: 'Approval rationale: This arrives too late.' },
      ]),
    ];

    assert.equal(approvalRationaleForToolCall(messages, 'target'), undefined);
  });
});
