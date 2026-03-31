#!/usr/bin/env bash
# configure-skills.sh — Enable only relevant skills, disable everything else
#
# Usage (run from project root):
#   bash .claude/scripts/configure-skills.sh [keyword1] [keyword2] ...
#
# Examples:
#   bash .claude/scripts/configure-skills.sh                    # universal only
#   bash .claude/scripts/configure-skills.sh python django postgresql docker
#   bash .claude/scripts/configure-skills.sh react typescript node postgresql
#
# Keywords are case-insensitive. Saved to .claude/active-skills.txt for
# update-mode restoration.

set -e

# Determine project root from script location (2 levels up: .claude/scripts/ → project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
ACTIVE_FILE="$PROJECT_ROOT/.claude/active-skills.txt"

# ── Universal skills — always ON regardless of stack ──────────────────────────
UNIVERSAL_SKILLS=(
  "tdd-workflow"
  "blueprint"
  "deep-research"
  "search-first"
  "verification-loop"
  "coding-standards"
  "memory-protocol"
  "security-review"
  "security-scan"
  "security-context"
  "documentation-lookup"
  "skill-stocktake"
  "agentic-engineering"
  "strategic-compact"
)

# ── Keyword → skill mappings ──────────────────────────────────────────────────
# Each key maps to a space-separated list of skill directory names.
declare -A SKILL_MAP

SKILL_MAP["python"]="python-patterns python-testing"
SKILL_MAP["django"]="python-patterns python-testing django-patterns django-security django-tdd django-verification"
SKILL_MAP["fastapi"]="python-patterns python-testing backend-patterns api-design"
SKILL_MAP["flask"]="python-patterns python-testing backend-patterns api-design"
SKILL_MAP["react"]="frontend-patterns frontend-context e2e-testing"
SKILL_MAP["nextjs"]="frontend-patterns frontend-context nextjs-turbopack e2e-testing"
SKILL_MAP["vue"]="frontend-patterns frontend-context e2e-testing"
SKILL_MAP["svelte"]="frontend-patterns frontend-context e2e-testing"
SKILL_MAP["typescript"]="frontend-patterns backend-patterns"
SKILL_MAP["postgresql"]="postgres-patterns database-context database-migrations"
SKILL_MAP["mysql"]="database-context database-migrations"
SKILL_MAP["mongodb"]="database-context"
SKILL_MAP["sqlite"]="database-context"
SKILL_MAP["golang"]="golang-patterns golang-testing backend-patterns"
SKILL_MAP["go"]="golang-patterns golang-testing backend-patterns"
SKILL_MAP["rust"]="rust-patterns rust-testing"
SKILL_MAP["kotlin"]="kotlin-patterns kotlin-testing kotlin-coroutines-flows kotlin-ktor-patterns kotlin-exposed-patterns"
SKILL_MAP["ktor"]="kotlin-patterns kotlin-ktor-patterns kotlin-coroutines-flows"
SKILL_MAP["android"]="android-clean-architecture kotlin-patterns kotlin-coroutines-flows kotlin-testing"
SKILL_MAP["java"]="java-coding-standards jpa-patterns springboot-patterns"
SKILL_MAP["springboot"]="java-coding-standards jpa-patterns springboot-patterns springboot-security springboot-tdd springboot-verification"
SKILL_MAP["laravel"]="laravel-patterns laravel-security laravel-tdd laravel-verification"
SKILL_MAP["php"]="laravel-patterns"
SKILL_MAP["perl"]="perl-patterns perl-security perl-testing"
SKILL_MAP["swift"]="swiftui-patterns swift-concurrency-6-2 swift-actor-persistence swift-protocol-di-testing foundation-models-on-device liquid-glass-design"
SKILL_MAP["swiftui"]="swiftui-patterns swift-concurrency-6-2 swift-actor-persistence swift-protocol-di-testing foundation-models-on-device liquid-glass-design"
SKILL_MAP["ios"]="swiftui-patterns swift-concurrency-6-2 swift-actor-persistence swift-protocol-di-testing foundation-models-on-device liquid-glass-design"
SKILL_MAP["cpp"]="cpp-coding-standards cpp-testing"
SKILL_MAP["docker"]="docker-patterns deployment-patterns devops-context"
SKILL_MAP["node"]="backend-patterns backend-context api-design"
SKILL_MAP["express"]="backend-patterns backend-context api-design"
SKILL_MAP["vercel"]="deployment-patterns devops-context"
SKILL_MAP["aws"]="deployment-patterns devops-context"
SKILL_MAP["railway"]="deployment-patterns devops-context"
SKILL_MAP["bun"]="bun-runtime backend-patterns backend-context"
SKILL_MAP["mcp"]="mcp-server-patterns"
SKILL_MAP["ai"]="claude-api continuous-learning-v2 cost-aware-llm-pipeline eval-harness ai-first-engineering ai-regression-testing prompt-optimizer iterative-retrieval regex-vs-llm-structured-text fal-ai-media"
SKILL_MAP["llm"]="claude-api continuous-learning-v2 cost-aware-llm-pipeline prompt-optimizer iterative-retrieval regex-vs-llm-structured-text"
SKILL_MAP["agents"]="agent-harness-construction autonomous-loops continuous-agent-loop enterprise-agent-ops agentic-engineering ai-first-engineering"
SKILL_MAP["exa"]="exa-search deep-research"
SKILL_MAP["scraping"]="data-scraper-agent exa-search"
SKILL_MAP["clickhouse"]="clickhouse-io"
SKILL_MAP["compose"]="compose-multiplatform-patterns kotlin-patterns kotlin-coroutines-flows"

# ── Helpers ───────────────────────────────────────────────────────────────────

disable_skill() {
  local skill_md="$SKILLS_DIR/$1/SKILL.md"
  [ -f "$skill_md" ] || return 0
  grep -q "^disable-model-invocation:" "$skill_md" && return 0
  # Insert disable flag after the opening --- of frontmatter
  sed -i '0,/^---$/{s/^---$/---\ndisable-model-invocation: true/}' "$skill_md"
}

enable_skill() {
  local skill_md="$SKILLS_DIR/$1/SKILL.md"
  [ -f "$skill_md" ] || return 0
  sed -i '/^disable-model-invocation:/d' "$skill_md"
}

# ── Step 1: Disable ALL skills ────────────────────────────────────────────────
TOTAL=$(ls -1 "$SKILLS_DIR" 2>/dev/null | wc -l)
echo "→ Disabling all $TOTAL skills..."
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  disable_skill "$(basename "$skill_dir")"
done

# ── Step 2: Build enabled set ─────────────────────────────────────────────────
declare -A ENABLED

for skill in "${UNIVERSAL_SKILLS[@]}"; do
  ENABLED["$skill"]=1
done

KEYWORDS=("$@")
for keyword in "${KEYWORDS[@]}"; do
  kw=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
  if [ -n "${SKILL_MAP[$kw]+_}" ]; then
    for skill in ${SKILL_MAP[$kw]}; do
      ENABLED["$skill"]=1
    done
  fi
done

# ── Step 3: Enable selected skills ───────────────────────────────────────────
ENABLED_COUNT="${#ENABLED[@]}"
echo "→ Enabling $ENABLED_COUNT skills (${TOTAL} - $((TOTAL - ENABLED_COUNT)) disabled)..."
for skill in "${!ENABLED[@]}"; do
  enable_skill "$skill"
done

# ── Step 4: Save active keywords for update-mode restoration ─────────────────
printf '%s\n' "${KEYWORDS[@]}" > "$ACTIVE_FILE"

# ── Done ─────────────────────────────────────────────────────────────────────
echo "✓ Skills configured: $ENABLED_COUNT enabled / $TOTAL total"
if [ ${#KEYWORDS[@]} -gt 0 ]; then
  echo "  Stack keywords: ${KEYWORDS[*]}"
else
  echo "  Stack keywords: (none — universal only, run /init to configure)"
fi
