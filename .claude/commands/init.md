---
name: init
description: >
  Initialize memory-bank for a new project. Interviews user and creates
  all memory files under .claude/memory-bank/. Run once at project start.
---

Use the `onboarding` agent to initialize this project.

Ask the user questions one at a time and create all memory-bank files.
Do not skip any question. Do not guess — ask if unsure.

After completing, print the completion message from the onboarding agent template.
