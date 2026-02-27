#!/bin/bash
# governance/bin/create-symlinks.sh — Create CLAUDE.md, copilot-instructions.md, and .claude/commands symlinks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
resolve_ai_dir

echo "Initializing .ai submodule symlinks..."

# instructions.md -> CLAUDE.md
for target in "CLAUDE.md"; do
  if [ ! -L "$PROJECT_ROOT/$target" ] || [ "$(readlink "$PROJECT_ROOT/$target")" != ".ai/instructions.md" ]; then
    run_cmd "Symlink $target" ln -sf .ai/instructions.md "$PROJECT_ROOT/$target"
    echo "  Linked $target -> .ai/instructions.md"
  else
    echo "  $target already linked"
  fi
done

# GitHub Copilot instructions
mkdir -p "$PROJECT_ROOT/.github"
COPILOT_TARGET=".github/copilot-instructions.md"
if [ ! -L "$PROJECT_ROOT/$COPILOT_TARGET" ] || [ "$(readlink "$PROJECT_ROOT/$COPILOT_TARGET")" != "../.ai/instructions.md" ]; then
  run_cmd "Symlink $COPILOT_TARGET" ln -sf ../.ai/instructions.md "$PROJECT_ROOT/$COPILOT_TARGET"
  echo "  Linked $COPILOT_TARGET -> .ai/instructions.md"
else
  echo "  $COPILOT_TARGET already linked"
fi

# Claude Code slash commands (.claude/commands/)
if [ -d "$AI_DIR/.claude/commands" ]; then
  run_cmd "Create .claude directory" mkdir -p "$PROJECT_ROOT/.claude"
  COMMANDS_LINK="$PROJECT_ROOT/.claude/commands"
  COMMANDS_TARGET="../.ai/.claude/commands"
  if [ ! -L "$COMMANDS_LINK" ] || [ "$(readlink "$COMMANDS_LINK")" != "$COMMANDS_TARGET" ]; then
    # Do not overwrite an existing regular directory
    if [ -d "$COMMANDS_LINK" ] && [ ! -L "$COMMANDS_LINK" ]; then
      echo "  [WARN] .claude/commands/ exists as a regular directory; skipping symlink"
    else
      run_cmd "Symlink .claude/commands" ln -sf "$COMMANDS_TARGET" "$COMMANDS_LINK"
      echo "  Linked .claude/commands -> $COMMANDS_TARGET"
    fi
  else
    echo "  .claude/commands already linked"
  fi
else
  log_debug ".ai/.claude/commands/ not found; skipping commands symlink"
fi
