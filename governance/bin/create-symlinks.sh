#!/bin/bash
# governance/bin/create-symlinks.sh — Create CLAUDE.md and copilot-instructions.md symlinks.

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
