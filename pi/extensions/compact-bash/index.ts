import {
  createBashToolDefinition,
  type ExtensionAPI,
} from '@earendil-works/pi-coding-agent';
import { Container, Text, type Component } from '@earendil-works/pi-tui';

type RendererState = {
  defaultResultComponent?: Component;
};

/**
 * Keeps bash results in the agent context while hiding them from Pi's
 * interactive transcript until the user expands tool output with Ctrl-O.
 */
export default function (pi: ExtensionAPI) {
  const originalBash = createBashToolDefinition(process.cwd());

  pi.registerTool({
    name: 'bash',
    label: 'bash',
    description: originalBash.description,
    promptSnippet: 'Execute bash commands (ls, grep, find, etc.)',
    promptGuidelines: ['Use bash for file operations like ls, rg, find.'],
    parameters: originalBash.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      return originalBash.execute(toolCallId, params, signal, onUpdate, ctx);
    },

    // Omitting renderCall and renderShell retains Pi's built-in bash styling.
    renderResult(result, options, theme, context) {
      const state = context.state as RendererState;
      const defaultResult = originalBash.renderResult?.(
        result,
        options,
        theme,
        {
          ...context,
          lastComponent: state.defaultResultComponent,
        },
      );
      state.defaultResultComponent = defaultResult;

      if (options.expanded && defaultResult) return defaultResult;

      if (context.isError) {
        // Keep failures visible without exposing stdout/stderr until Ctrl-O.
        return new Text(theme.fg('error', 'Command failed'), 0, 0);
      }

      // The result remains in session/model context; do not render it in the TUI.
      return new Container();
    },
  });
}
