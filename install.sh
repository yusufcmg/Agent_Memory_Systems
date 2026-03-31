#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Agent Memory System — Installer
#  Usage: bash install.sh [--update]
#  --update: re-copy agents/skills/commands without touching memory-bank
# ─────────────────────────────────────────────────────────────────
set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
err()  { echo -e "${RED}✗${NC} $1"; exit 1; }
info() { echo -e "${CYAN}→${NC} $1"; }

UPDATE_MODE=false
[[ "$1" == "--update" ]] && UPDATE_MODE=true

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
if $UPDATE_MODE; then
  echo -e "${BOLD}  Agent Memory System — Update             ${NC}"
else
  echo -e "${BOLD}  Agent Memory System — Install            ${NC}"
fi
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Check Claude Code CLI ──────────────────────────────────────
if ! command -v claude &>/dev/null; then
  err "Claude Code CLI not found.\nInstall: npm install -g @anthropic-ai/claude-code\nDocs:    https://code.claude.com"
fi
log "Claude Code CLI: $(claude --version 2>/dev/null | head -1)"

# ── 2. Check Node.js ──────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  err "Node.js not found. Install from https://nodejs.org (v18+)"
fi
NODE_VER=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 18 ]; then
  err "Node.js v18+ required (found v$NODE_VER)"
fi
log "Node.js: $(node --version)"

# ── 3. Install Claude Code Router (optional) ─────────────────────
if ! command -v ccr &>/dev/null; then
  info "Installing Claude Code Router (for multi-model routing)..."
  if npm install -g @musistudio/claude-code-router 2>/dev/null; then
    log "Claude Code Router installed"
  else
    warn "CCR install failed (optional — single-model setup still works)"
    warn "Manual install: npm install -g @musistudio/claude-code-router"
  fi
else
  log "Claude Code Router: $(ccr --version 2>/dev/null | head -1 || echo 'found')"
fi

# ── 4. Copy root files ────────────────────────────────────────────
if ! $UPDATE_MODE; then
  if [ ! -f "CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" . && log "CLAUDE.md → project root"
  else
    warn "CLAUDE.md already exists — skipping (edit manually to add agents)"
  fi

  if [ ! -f "AGENTS.md" ]; then
    cp "$SCRIPT_DIR/AGENTS.md" . && log "AGENTS.md → project root"
  fi

  if [ ! -f ".env.example" ]; then
    cp "$SCRIPT_DIR/.env.example" . && log ".env.example → project root"
  fi

  # Merge .gitignore entries without duplicating
  if [ -f ".gitignore" ]; then
    # Ensure file ends with newline before appending
    if [ -s ".gitignore" ] && [ "$(tail -c 1 .gitignore | wc -l)" -eq 0 ]; then
      echo "" >> .gitignore
    fi
    ENTRIES=(
      ".claude/worktrees/"
      ".claude/settings.local.json"
      ".claude/active-skills.txt"
      "CLAUDE.local.md"
      ".claude-code-router/config.json"
    )
    for entry in "${ENTRIES[@]}"; do
      if ! grep -qF "$entry" .gitignore 2>/dev/null; then
        echo "$entry" >> .gitignore
      fi
    done
    log ".gitignore updated"
  else
    cp "$SCRIPT_DIR/.gitignore" . && log ".gitignore → project root"
  fi
fi

# ── 5. Install .claude/ directory ────────────────────────────────
mkdir -p .claude/{agents,commands,hooks,skills,scripts,memory-bank}

# Count actual files for accurate log messages
AGENT_COUNT=$(find "$SCRIPT_DIR/.claude/agents" -name '*.md' 2>/dev/null | wc -l)
CMD_COUNT=$(find "$SCRIPT_DIR/.claude/commands" -name '*.md' 2>/dev/null | wc -l)
SKILL_COUNT=$(find "$SCRIPT_DIR/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

if $UPDATE_MODE; then
  # Update mode: overwrite agents/skills/commands but preserve memory-bank
  # Guard against same-file copies (when this repo IS the target project directory)
  safe_cp() {
    local src="$1" dst="$2"
    [ "$(realpath "$src" 2>/dev/null)" = "$(realpath "$dst" 2>/dev/null)" ] && return 0
    cp -f "$src" "$dst"
  }
  while IFS= read -r src; do
    safe_cp "$src" ".claude/agents/$(basename "$src")"
  done < <(find "$SCRIPT_DIR/.claude/agents" -name '*.md')
  log "Agents updated ($AGENT_COUNT)"
  while IFS= read -r src; do
    safe_cp "$src" ".claude/commands/$(basename "$src")"
  done < <(find "$SCRIPT_DIR/.claude/commands" -name '*.md')
  log "Commands updated ($CMD_COUNT)"
  safe_cp "$SCRIPT_DIR/.claude/hooks/hooks.json" ".claude/hooks/hooks.json" && log "Hooks updated"
  safe_cp "$SCRIPT_DIR/.claude/scripts/configure-skills.sh" ".claude/scripts/configure-skills.sh"
  log "Scripts updated"
  for skill_dir in "$SCRIPT_DIR"/.claude/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    mkdir -p ".claude/skills/$skill_name"
    safe_cp "$skill_dir/SKILL.md" ".claude/skills/$skill_name/SKILL.md" || true
  done
  log "Skills updated ($SKILL_COUNT)"
  # Restore skill configuration from previous /init
  if [ -f ".claude/active-skills.txt" ]; then
    SAVED_KEYWORDS=$(tr '\n' ' ' < .claude/active-skills.txt | xargs)
    info "Restoring skill configuration: $SAVED_KEYWORDS"
    # shellcheck disable=SC2086
    bash .claude/scripts/configure-skills.sh $SAVED_KEYWORDS
  else
    info "No active-skills.txt found — disabling all skills (run /init to configure)"
    bash .claude/scripts/configure-skills.sh
  fi
else
  # Fresh install: use -n to not overwrite existing
  cp -rn "$SCRIPT_DIR/.claude/agents/".    .claude/agents/   2>/dev/null; log "Agents installed ($AGENT_COUNT)"
  cp -rn "$SCRIPT_DIR/.claude/commands/".  .claude/commands/ 2>/dev/null; log "Commands installed ($CMD_COUNT)"
  cp -rn "$SCRIPT_DIR/.claude/hooks/".     .claude/hooks/    2>/dev/null; log "Hooks installed"
  cp -rn "$SCRIPT_DIR/.claude/scripts/".   .claude/scripts/  2>/dev/null; log "Scripts installed"
  cp -rn "$SCRIPT_DIR/.claude/skills/".    .claude/skills/   2>/dev/null; log "Skills installed ($SKILL_COUNT)"
  # Disable all skills by default — /init will enable the right ones
  bash .claude/scripts/configure-skills.sh
fi

# settings.json — never overwrite (user may have customized)
if [ ! -f ".claude/settings.json" ]; then
  cp "$SCRIPT_DIR/.claude/settings.json" .claude/ && log "settings.json installed"
else
  warn "settings.json exists — skipping (yours is preserved)"
fi

# ── 6. Memory-bank templates (fresh install only) ─────────────────
if ! $UPDATE_MODE; then
  if [ ! -f ".claude/memory-bank/core/project.md" ]; then
    cp -r "$SCRIPT_DIR/.claude/memory-bank/". .claude/memory-bank/
    log "Memory-bank templates installed"
    info "Run /init in Claude Code to fill them with your project details"
  else
    warn "Memory-bank already initialized — skipping template copy"
    info "Run /sync-memory to check for drift"
  fi
fi

# ── 7. Claude Code Router config ─────────────────────────────────
# Cross-platform sed -i helper (macOS BSD sed vs GNU sed)
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

mkdir -p ~/.claude-code-router
if [ ! -f ~/.claude-code-router/config.json ]; then
  if [ -f "$SCRIPT_DIR/.claude-code-router/config.example.json" ]; then
    cp "$SCRIPT_DIR/.claude-code-router/config.example.json" \
       ~/.claude-code-router/config.json
    log "CCR config → ~/.claude-code-router/config.json"

    # Auto-fill OpenRouter API key from environment variable if set
    # Note: Only OPENROUTER_API_KEY is used because CCR config is for OpenRouter only.
    # Claude Pro uses /login directly — no API key needed in this file.
    if [ -n "$OPENROUTER_API_KEY" ]; then
      sed_inplace "s|BURAYA-OPENROUTER-KEY-GIRIN|$OPENROUTER_API_KEY|g" \
        ~/.claude-code-router/config.json
      log "OPENROUTER_API_KEY auto-filled into config.json ✓"
    else
      warn "OpenRouter key not set — edit ~/.claude-code-router/config.json to add it"
    fi
  fi
else
  warn "CCR config already exists — skipping (~/.claude-code-router/config.json)"
fi

# ── 8. API key check ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}── API Keys ──────────────────────────────────────${NC}"
info "Claude Pro (Path A): No API key needed — use ${YELLOW}claude${NC} and type ${YELLOW}/login${NC}"
if [ -n "$OPENROUTER_API_KEY" ]; then
  log "OPENROUTER_API_KEY set ✓ (Path B — cheap models via OpenRouter)"
else
  warn "OPENROUTER_API_KEY not set — add your key to ~/.claude-code-router/config.json"
fi

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
if $UPDATE_MODE; then
  echo -e "${BOLD}${GREEN}  ✅ Update complete!${NC}"
  echo -e "${BOLD}╠══════════════════════════════════════════╣${NC}"
  echo -e "  Memory-bank preserved — no data lost"
  echo -e "  Agents, commands, and skills refreshed"
else
  echo -e "${BOLD}${GREEN}  ✅ Installation complete!${NC}"
  echo -e "${BOLD}╠══════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}  Next steps:${NC}"
  echo -e ""
  echo -e "  ${BOLD}1.${NC} Claude Pro (quality work):"
  echo -e "     Run ${YELLOW}claude${NC} → type ${YELLOW}/login${NC} → authenticate in browser"
  echo -e "     Then: ${YELLOW}claude -p \"as architect, analyze this project\"${NC}"
  echo -e ""
  echo -e "  ${BOLD}2.${NC} OpenRouter (cheap routine work):"
  echo -e "     Edit ${YELLOW}~/.claude-code-router/config.json${NC} → add your API key"
  echo -e "     Then: ${YELLOW}ccr code -p \"as qa agent, write tests\"${NC}"
  echo -e ""
  echo -e "  ${BOLD}3.${NC} Initialize project memory:"
  echo -e "     Run ${YELLOW}claude${NC} → type ${YELLOW}/init${NC}"
fi
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
