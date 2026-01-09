---
description: Show tk ready/blocked and suggest next work item (does NOT start work)
agent: os-tk-agent
subtask: false
---

Ready:
!`tk ready`

Blocked:
!`tk blocked`

Pick ONE ready ticket to do next (or the smallest unblock step if none are ready).

**Output:**
- ticket id
- title & brief summary
- why it's the best next choice

**Important:** Do NOT start implementation. Do NOT provide an implementation plan.

End your response by asking the user:
> Would you like me to run `/tk-start <ticket-id>` to begin work on this ticket?
