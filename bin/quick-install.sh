#!/bin/bash
# .ai/bin/quick-install.sh — One-line install for Dark Factory governance.
#
# Usage (curl):
#   curl -sSL https://raw.githubusercontent.com/SET-Apps/ai-submodule/main/bin/quick-install.sh | bash
#
# Usage (local):
#   bash .ai/bin/quick-install.sh
#
# What it does:
#   1. Adds .ai as a git submodule (if not already present)
#   2. Runs init.sh to configure the project
#   3. Optionally installs Python dependencies (pass --install-deps)

set -euo pipefail

REPO_URL="https://github.com/SET-Apps/ai-submodule.git"
SUBMODULE_PATH=".ai"
INSTALL_DEPS=false

for arg in "$@"; do
  case "$arg" in
    --install-deps) INSTALL_DEPS=true ;;
    --help|-h)
      echo "Usage: bash quick-install.sh [--install-deps]"
      echo ""
      echo "Adds the Dark Factory governance submodule and runs init.sh."
      echo "  --install-deps    Also install Python venv and dependencies"
      exit 0
      ;;
  esac
done

# Safety: must be in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "[ERROR] Not inside a git repository. Run 'git init' first."
  exit 1
fi

# Safety: don't overwrite existing .ai
if [ -d "$SUBMODULE_PATH" ]; then
  echo "[OK] $SUBMODULE_PATH already exists. Running init.sh..."
else
  echo "Adding $SUBMODULE_PATH as git submodule..."
  git submodule add "$REPO_URL" "$SUBMODULE_PATH"
  echo "[OK] Submodule added."
fi

# Run init.sh
INIT_ARGS=""
if [ "$INSTALL_DEPS" = "true" ]; then
  INIT_ARGS="--install-deps"
fi

echo ""
echo "Running init.sh..."
bash "$SUBMODULE_PATH/bin/init.sh" $INIT_ARGS
