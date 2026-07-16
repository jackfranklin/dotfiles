import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

export default function (pi: ExtensionAPI) {
	let thinkingLevel = "off";
	let model = "no-model";
	let contextWindow = 0;
	let usingSubscription = false;

	pi.on("session_start", (_event, ctx) => {
		model = ctx.model?.id ?? "no-model";
		contextWindow = ctx.model?.contextWindow ?? 0;
		usingSubscription = ctx.model ? ctx.modelRegistry.isUsingOAuth(ctx.model) : false;

		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "thinking_level_change") {
				thinkingLevel = entry.thinkingLevel;
			}
		}

		ctx.ui.setFooter((_tui, theme) => ({
			invalidate() {},

			render(width: number): string[] {
				const usage = ctx.getContextUsage();
				const currentContextWindow = usage?.contextWindow ?? contextWindow;
				const contextPercent = usage?.percent == null ? "?" : `${usage.percent.toFixed(1)}%`;
				const context = `${contextPercent}/${formatTokens(currentContextWindow)}`;

				let totalCost = 0;
				for (const entry of ctx.sessionManager.getEntries()) {
					if (entry.type === "message" && entry.message.role === "assistant") {
						totalCost += entry.message.usage.cost.total;
					}
				}

				const cost = `$${totalCost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`;
				const left = theme.fg("dim", `${context}  ${cost}`);

				const right = theme.fg("dim", `${model}  ${thinkingLevel}`);

				const padding = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
				return [truncateToWidth(left + padding + right, width)];
			},
		}));
	});

	pi.on("model_select", (event, ctx) => {
		model = event.model.id;
		contextWindow = event.model.contextWindow;
		usingSubscription = ctx.modelRegistry.isUsingOAuth(event.model);
	});

	pi.on("thinking_level_select", (event) => {
		thinkingLevel = event.level;
	});
}
