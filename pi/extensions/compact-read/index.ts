import {
  createReadTool,
  type ExtensionAPI,
} from '@earendil-works/pi-coding-agent';
import { Container, Text } from '@earendil-works/pi-tui';

/**
 * Keeps read results in the agent context while rendering only the path in
 * Pi's interactive transcript. Expand/collapse deliberately has no effect.
 */
export default function (pi: ExtensionAPI) {
  const originalRead = createReadTool(process.cwd());

  pi.registerTool({
    name: 'read',
    label: 'read',
    description: originalRead.description,
    promptSnippet: 'Read the contents of a file.',
    promptGuidelines: ['Use read to examine files instead of cat or sed.'],
    parameters: originalRead.parameters,
    renderShell: 'self',

    async execute(toolCallId, params, signal, onUpdate) {
      return originalRead.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      return new Text(
        theme.fg('toolTitle', theme.bold('read ')) +
          theme.fg('accent', args.path),
        0,
        0,
      );
    },

    renderResult(result, _options, theme, context) {
      if (context.isError) {
        const message = result.content.find((block) => block.type === 'text')
          ?.text;
        return new Text(theme.fg('error', message ?? 'Read failed'), 0, 0);
      }

      // The result remains in session/model context; do not render it in the TUI.
      return new Container();
    },
  });
}
