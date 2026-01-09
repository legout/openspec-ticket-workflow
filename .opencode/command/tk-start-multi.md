---
description: Start multiple tickets in parallel as background tasks [ultrahardwork]
agent: os-tk-agent
---

**Ticket IDs:** $ARGUMENTS

For EACH ticket ID provided in `$ARGUMENTS`:
- Call the `/tk-start` slash command: `/tk-start <id>`

**Important:** Each `/tk-start` call will automatically spawn a background task handled by the `os-tk-agent`.

After initiating all tasks, confirm to the user:
> "Started <N> tickets in parallel: <id1>, <id2>, ... Each is running as a background task via `os-tk-agent`."

<!-- ultrahardwork -->
