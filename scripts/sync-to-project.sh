#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Agent Memory System — Sync to Project
#  Usage: bash sync-to-project.sh [TARGET_DIR] [--apply] [--diff]
#
#  Modes:
#    (default)  --dry-run  Show what would change, don't touch files
#    --apply               Apply changes (asks for confirmation)
#    --diff                Show unified diff of changed files
#
#  What is UPDATED  : agents/ skills/ commands/ hooks/ rules/ scripts/
#  What is PROTECTED: memory-bank/ settings.local.json active-skills.txt
# ─────────────────────────────────────────────────────────────────
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

log()   { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $1"; }
info()  { echo -e "${CYAN}→${NC} $1"; }
dry()   { echo -e "${GRAY}~${NC}  $1"; }
err()   { echo -e "${RED}✗${NC} $1"; exit 1; }

# ── Parse args ───────────────────────────────────────────────────
MODE="dry-run"
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --apply)   MODE="apply" ;;
    --diff)    MODE="diff"  ;;
    --dry-run) MODE="dry-run" ;;
    -*)        err "Unknown flag: $arg" ;;
    *)         TARGET="$arg" ;;
  esac
done

# Default target: current working directory
TARGET="${TARGET:-$(pwd)}"
TARGET="$(cd "$TARGET" && pwd)"  # normalize path

AMS2_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_CLAUDE="$TARGET/.claude"

# ── Guards ───────────────────────────────────────────────────────
[ "$TARGET" = "$AMS2_DIR" ] && err "Target cannot be the AMS2 repo itself. Use install.sh --update instead."
[ -d "$TARGET_CLAUDE" ] || err "No .claude/ found in $TARGET — run install.sh first to initialize."

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}  AMS2 → Project Sync  [${MODE^^}]${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════╣${NC}"
echo -e "  Source : $AMS2_DIR"
echo -e "  Target : $TARGET"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── Directories to sync ──────────────────────────────────────────
# Each entry: "src_subpath:dst_subpath"
SYNC_DIRS=(
  ".claude/agents:.claude/agents"
  ".claude/commands:.claude/commands"
  ".claude/skills:.claude/skills"
  ".claude/hooks:.claude/hooks"
  ".claude/scripts:.claude/scripts"
  ".claude/rules:.claude/rules"
)

# ── Collect changes ──────────────────────────────────────────────
declare -a TO_ADD=()
declare -a TO_UPDATE=()

for pair in "${SYNC_DIRS[@]}"; do
  src_rel="${pair%%:*}"
  dst_rel="${pair##*:}"
  src_abs="$AMS2_DIR/$src_rel"
  dst_abs="$TARGET/$dst_rel"

  [ -d "$src_abs" ] || continue

  while IFS= read -r src_file; do
    rel="${src_file#$src_abs/}"
    dst_file="$dst_abs/$rel"

    if [ ! -f "$dst_file" ]; then
      TO_ADD+=("$src_file → $dst_file")
    elif ! diff -q "$src_file" "$dst_file" &>/dev/null; then
      TO_UPDATE+=("$src_file → $dst_file")
    fi
  done < <(find "$src_abs" -type f)
done

# ── Report ───────────────────────────────────────────────────────
echo -e "${BOLD}── Files to add (${#TO_ADD[@]}) ──────────────────────────${NC}"
for entry in "${TO_ADD[@]}"; do
  dry "  ADD  ${entry##*→ }"
done

echo ""
echo -e "${BOLD}── Files to update (${#TO_UPDATE[@]}) ────────────────────${NC}"
for entry in "${TO_UPDATE[@]}"; do
  dry "  UPD  ${entry##*→ }"
done

echo ""
echo -e "${BOLD}── Protected (never touched) ─────────────────────${NC}"
dry "  SKIP $TARGET/.claude/memory-bank/"
dry "  SKIP $TARGET/.claude/settings.local.json"
dry "  SKIP $TARGET/.claude/active-skills.txt"

echo ""

TOTAL=$(( ${#TO_ADD[@]} + ${#TO_UPDATE[@]} ))

if [ "$TOTAL" -eq 0 ]; then
  log "Target is already up to date — nothing to sync."
  exit 0
fi

# ── Diff mode ────────────────────────────────────────────────────
if [ "$MODE" = "diff" ]; then
  echo -e "${BOLD}── Unified diff ──────────────────────────────────${NC}"
  for entry in "${TO_UPDATE[@]}"; do
    src="${entry% →*}"
    dst="${entry##*→ }"
    echo -e "${CYAN}--- $dst${NC}"
    diff -u "$dst" "$src" || true
    echo ""
  done
  exit 0
fi

# ── Dry-run mode ─────────────────────────────────────────────────
if [ "$MODE" = "dry-run" ]; then
  info "Dry-run: $TOTAL file(s) would change. Run with --apply to update."
  info "Run with --diff to see exact changes."
  exit 0
fi

# ── Apply mode ───────────────────────────────────────────────────
echo -e "${YELLOW}Apply $TOTAL change(s) to $TARGET?${NC} [y/N] "
read -r answer
[[ "$answer" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

# Backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$TARGET_CLAUDE/.backup-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
info "Creating backup → $BACKUP_DIR"

for entry in "${TO_UPDATE[@]}"; do
  dst="${entry##*→ }"
  rel_dst="${dst#$TARGET_CLAUDE/}"
  backup_path="$BACKUP_DIR/$rel_dst"
  mkdir -p "$(dirname "$backup_path")"
  cp "$dst" "$backup_path"
done
log "Backup complete (${#TO_UPDATE[@]} file(s))"

echo ""

# Apply
apply_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

for pair in "${SYNC_DIRS[@]}"; do
  src_rel="${pair%%:*}"
  dst_rel="${pair##*:}"
  src_abs="$AMS2_DIR/$src_rel"
  dst_abs="$TARGET/$dst_rel"

  [ -d "$src_abs" ] || continue
  mkdir -p "$dst_abs"

  while IFS= read -r src_file; do
    rel="${src_file#$src_abs/}"
    dst_file="$dst_abs/$rel"
    apply_file "$src_file" "$dst_file"
  done < <(find "$src_abs" -type f)
done

log "Sync applied ($TOTAL file(s) updated)"

# Restore skill config if active-skills.txt exists
if [ -f "$TARGET_CLAUDE/active-skills.txt" ]; then
  SAVED_KEYWORDS=$(tr '\n' ' ' < "$TARGET_CLAUDE/active-skills.txt" | xargs)
  info "Restoring skill config: $SAVED_KEYWORDS"
  bash "$TARGET_CLAUDE/scripts/configure-skills.sh" $SAVED_KEYWORDS
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}  ✅ Sync complete!${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════╣${NC}"
echo -e "  memory-bank:        ${GREEN}untouched ✓${NC}"
echo -e "  settings.local.json:${GREEN}untouched ✓${NC}"
echo -e "  backup:             $BACKUP_DIR"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
