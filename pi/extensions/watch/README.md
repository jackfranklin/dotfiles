# Watch extension

Adds session-scoped, recurring status checks to Pi. It is intended for bounded polling commands such as `kubectl get pods`, `systemctl status my-service --no-pager`, or `tail -n 100 app.log`.

Ask Pi naturally, for example:

> Every 2 minutes, check `kubectl get pods -n api` and tell me if anything changes.

Pi calls `watch_start`, shows the exact command and interval in a confirmation dialog, runs an initial check, then polls at the requested interval. A changed result is injected into the conversation, so Pi can explain it. Identical results do not trigger a response.

## Controls

- `/watches` — show active watches.
- `/watch-stop <watch-id>` — stop one watch.
- `/watch-stop all` — stop every watch.

Pi can also use the `watch_list` and `watch_stop` tools.

## Behavior and safety

- Watches run only for the current Pi session. They stop on exit, reload, `/new`, `/resume`, or `/fork`; they are never restored automatically.
- The extension skips a scheduled poll while Pi is busy, so it does not queue repeated agent responses.
- Each poll has a 60-second timeout. Command output is limited to Pi's normal 50 KB / 2,000-line tail limit.
- Commands run through the extension's `pi.exec`, rather than Pi's `bash` tool. Therefore the permissions extension cannot apply its bash glob policy to them. The extension requires an interactive confirmation of the exact recurring command before it starts. Only confirm commands you trust.
- Prefer finite snapshot commands (`tail -n 100 …`) over persistent commands (`tail -f …`).
