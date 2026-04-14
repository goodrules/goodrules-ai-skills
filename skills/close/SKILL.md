---
name: close
description: >
  End-of-session skill that summarizes work accomplished, updates SESSION_UPDATE.md
  with current information, removes stale items, and generates next steps. Use this
  skill whenever the user says "/close", "close the session", "wrap up", "end session",
  "session update", or "update the session file". Also use when the user asks to
  summarize what was done today or capture progress before ending work.
---

# Close Session

Wrap up the current working session by producing an accurate, current SESSION_UPDATE.md at the project root.

## Process

### Step 1: Read the existing file

Read `SESSION_UPDATE.md` from the project root. Understand its current structure, what was previously accomplished, and what remaining items exist.

### Step 2: Analyze the current session

Review the full conversation to identify everything that was accomplished in this session. Be thorough — look for:

- Features added or modified
- Bugs fixed
- Configuration changes
- Deployment updates
- Refactors or renames
- Security fixes
- Infrastructure changes
- Any other meaningful work

For each item, note the specific files changed and the technical details — these updates should be precise enough that someone reading them cold can understand exactly what changed and why.

### Step 3: Reconcile remaining items

Compare the existing "Remaining Items" against what was accomplished:
- **Remove** items that were completed in this or any prior session
- **Keep** items that are still relevant and unfinished
- **Add** new items that were identified during this session
- **Re-prioritize** if the session revealed new information about what matters most

### Step 4: Write the updated file

Rewrite `SESSION_UPDATE.md` with this structure:

```markdown
# Session Update — {date(s)}

## What Was Accomplished

### {Category} (Complete)
- **{Item}** — {concise technical description of what changed}

---

## Remaining Items — Next Priorities

### {Priority Group}
1. **{Item}** — {description, with PRD/spec references if applicable}

---

## {Any standing reference sections}
```

Guidelines for writing:
- Use the current date for the session header (or date range if spanning multiple days)
- Group accomplished items by logical category (e.g., "Deployment", "Security", "UI Updates")
- Mark each category with "(Complete)"
- Be concise but precise — include file paths, env var names, and technical details that matter
- Bold the item name, em-dash, then the description
- For remaining items, organize by priority group and number them
- Preserve any standing reference sections (like "Deployment Architecture" or "Security Posture") if they exist, updating them to reflect current state
- Remove sections that are no longer relevant or accurate

### Step 5: Confirm with the user

After writing the file, give the user a brief summary of:
- How many items were added to "Accomplished"
- How many remaining items were removed (completed)
- How many new remaining items were added
- Any notable changes to reference sections
