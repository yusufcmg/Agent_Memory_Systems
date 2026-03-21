# Contributing to Agent Memory System

Thank you for your interest in contributing! This guide will help you get started.

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or suggest features.
- Include your OS, Node.js version, and Claude Code version.
- Paste any error messages and your `config.json` (with API keys redacted).

### Pull Requests
1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes.
4. Test the installation: `bash install.sh` in a clean directory.
5. Submit a Pull Request with a clear description.

### What You Can Contribute
- **New Agents** → Add a `.md` file to `.claude/agents/`
- **New Skills** → Create a folder in `.claude/skills/your-skill/` with a `SKILL.md`
- **New Commands** → Add a `.md` file to `.claude/commands/`
- **Documentation** → Improve README, translations, or `docs/`
- **Bug Fixes** → Fix issues in `install.sh` or configuration templates

## Code Style
- Shell scripts: Follow existing `install.sh` patterns. Use `shellcheck` for linting.
- Markdown: Use standard GitHub Flavored Markdown.
- Agent/Skill files: Follow the YAML frontmatter + markdown body format used by existing files.

## Security
- **NEVER** commit real API keys, tokens, or secrets.
- Use placeholder values in examples (e.g., `sk-or-YOUR-KEY-HERE`).

## Questions?
Open a GitHub Issue — we're happy to help!
