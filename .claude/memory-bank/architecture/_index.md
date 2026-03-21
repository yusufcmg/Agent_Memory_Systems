# Architecture Decision Records — Index
_Last updated: YYYY-MM-DD_

## ADR Table
| ADR     | Title               | Status      | Affects               | Date       |
|---------|---------------------|-------------|------------------------|------------|
| ADR-001 | Tech Stack          | Accepted    | all                   | YYYY-MM-DD |

## Agent → Which ADRs to Read
| Agent       | Must Read           | Read if relevant        |
|-------------|---------------------|-------------------------|
| frontend    | ADR-001             | Any ADR tagged frontend |
| backend     | ADR-001             | Any ADR tagged backend  |
| database    | ADR-001             | Any ADR tagged database |
| security    | —                   | Any ADR tagged security |
| teamlead    | ALL                 | ALL                     |
| architect   | ALL                 | ALL                     |

## ADR Status Meanings
- **Proposed** — Under discussion, not yet implemented
- **Accepted** — Approved and should be followed
- **Deprecated** — Was valid, now superseded by a newer ADR
- **Superseded by ADR-NNN** — Replaced

## How to Add a New ADR
1. Run `/new-adr` command
2. Copy `ADR-001-tech-stack.md` as template
3. Increment number
4. Update this index table
