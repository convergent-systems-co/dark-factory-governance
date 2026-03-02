#!/bin/bash
# governance/bin/vendor-engine.sh — Vendor the policy engine into a consuming repo.
#
# Copies the policy engine, schemas, and policy profiles into .governance/engine/
# so that cross-org consuming repos can run the full policy engine in CI without
# needing to clone the ai-submodule.
#
# Called by: init.sh (submodule context) or standalone.
#
# Usage:
#   bash .ai/governance/bin/vendor-engine.sh
#   bash .ai/governance/bin/vendor-engine.sh --force   # re-vendor even if up-to-date
#   bash .ai/governance/bin/vendor-engine.sh --check    # check staleness only (exit 0=fresh, 1=stale)
#
# The vendored copy includes:
#   .governance/engine/policy-engine.py    — CLI entry point
#   .governance/engine/policy_engine.py    — Engine module
#   .governance/engine/policy/             — Policy profiles
#   .governance/engine/schemas/            — JSON schemas for validation
#   .governance/engine/requirements.txt    — Python dependencies
#   .governance/engine/VERSION             — Submodule commit SHA for staleness detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
resolve_ai_dir

FORCE=false
CHECK_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --check) CHECK_ONLY=true ;;
  esac
done

# --- Paths ---
VENDOR_DIR="$PROJECT_ROOT/.governance/engine"
VERSION_FILE="$VENDOR_DIR/VERSION"

# Source directories (inside the submodule)
ENGINE_CLI="$AI_DIR/governance/bin/policy-engine.py"
ENGINE_MODULE="$AI_DIR/governance/engine/policy_engine.py"
POLICY_DIR="$AI_DIR/governance/policy"
SCHEMA_DIR="$AI_DIR/governance/schemas"
REQUIREMENTS="$AI_DIR/governance/bin/requirements.txt"

# --- Resolve current submodule version ---
get_submodule_version() {
  if git -C "$AI_DIR" rev-parse HEAD &>/dev/null; then
    git -C "$AI_DIR" rev-parse HEAD
  else
    echo "unknown"
  fi
}

CURRENT_VERSION="$(get_submodule_version)"

# --- Staleness check ---
is_stale() {
  if [ ! -f "$VERSION_FILE" ]; then
    return 0  # No version file = needs vendoring
  fi
  local vendored_version
  vendored_version="$(cat "$VERSION_FILE" 2>/dev/null || echo "")"
  if [ "$vendored_version" != "$CURRENT_VERSION" ]; then
    return 0  # Different version = stale
  fi
  # Also check that key files exist
  if [ ! -f "$VENDOR_DIR/policy-engine.py" ] || [ ! -f "$VENDOR_DIR/policy_engine.py" ]; then
    return 0  # Missing files = needs re-vendor
  fi
  return 1  # Up to date
}

# --- Check-only mode ---
if [ "$CHECK_ONLY" = "true" ]; then
  if is_stale; then
    echo "stale"
    exit 1
  else
    echo "fresh"
    exit 0
  fi
fi

# --- Skip if up-to-date (unless --force) ---
if [ "$FORCE" != "true" ] && ! is_stale; then
  log_ok "Vendored policy engine is up-to-date ($(cat "$VERSION_FILE" | head -c 12)...)"
  return 0 2>/dev/null || exit 0
fi

# --- Validate source files exist ---
if [ ! -f "$ENGINE_CLI" ]; then
  log_warn "Policy engine CLI not found at $ENGINE_CLI — skipping vendoring"
  return 0 2>/dev/null || exit 0
fi

# --- Vendor the engine ---
echo ""
echo "  Vendoring policy engine into .governance/engine/"

# Create vendor directory structure
run_cmd "Create vendor directory" mkdir -p "$VENDOR_DIR/policy" "$VENDOR_DIR/schemas"

# Copy engine files
run_cmd "Copy policy-engine.py (CLI)" cp "$ENGINE_CLI" "$VENDOR_DIR/policy-engine.py"
if [ -f "$ENGINE_MODULE" ]; then
  run_cmd "Copy policy_engine.py (module)" cp "$ENGINE_MODULE" "$VENDOR_DIR/policy_engine.py"
fi

# Copy policy profiles
if [ -d "$POLICY_DIR" ]; then
  for profile in "$POLICY_DIR"/*.yaml; do
    [ -f "$profile" ] || continue
    run_cmd "Copy policy $(basename "$profile")" cp "$profile" "$VENDOR_DIR/policy/$(basename "$profile")"
  done
  log_ok "Copied $(ls "$POLICY_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ') policy profiles"
fi

# Copy schemas (only the ones needed for policy evaluation)
SCHEMA_FILES=(
  "panel-output.schema.json"
  "run-manifest.schema.json"
  "panels.defaults.json"
  "panels.schema.json"
)
for schema in "${SCHEMA_FILES[@]}"; do
  if [ -f "$SCHEMA_DIR/$schema" ]; then
    run_cmd "Copy schema $schema" cp "$SCHEMA_DIR/$schema" "$VENDOR_DIR/schemas/$schema"
  fi
done

# Copy requirements
if [ -f "$REQUIREMENTS" ]; then
  run_cmd "Copy requirements.txt" cp "$REQUIREMENTS" "$VENDOR_DIR/requirements.txt"
fi

# Write version file
echo "$CURRENT_VERSION" > "$VERSION_FILE"

# Write .gitignore note
if [ ! -f "$VENDOR_DIR/.gitignore" ]; then
  cat > "$VENDOR_DIR/README.md" << 'VENDOREOF'
# Vendored Policy Engine

This directory contains a vendored copy of the Dark Factory policy engine
from the `ai-submodule`. It is automatically maintained by `init.sh` and
`init.sh --refresh`.

**Do not edit files in this directory manually.** They will be overwritten
on the next refresh.

## Purpose

Cross-org consuming repos cannot clone the private `SET-Apps/ai-submodule`
in CI. This vendored copy allows the full policy engine to run without
submodule access, providing Tier 1 evaluation instead of falling back to
the lightweight Tier 2 validator.

## Staleness

The `VERSION` file contains the submodule commit SHA used to produce this
copy. Running `bash .ai/bin/init.sh --refresh` will update the vendored
copy if the submodule has been updated.

To check staleness: `bash .ai/governance/bin/vendor-engine.sh --check`
VENDOREOF
fi

log_ok "Vendored policy engine at version $(echo "$CURRENT_VERSION" | head -c 12)..."
echo ""
