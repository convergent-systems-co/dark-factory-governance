#!/bin/bash
# governance/bin/setup-workflows.sh — Issue templates, governance workflow symlinks, GOALS.md template.
# Only runs in submodule context (consuming repo has .gitmodules with .ai entry).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
resolve_ai_dir

# Requires PYTHON_CMD from caller (or empty string)
PYTHON_CMD="${PYTHON_CMD:-}"

IS_SUBMODULE=false
if [ -f "$PROJECT_ROOT/.gitmodules" ] && grep -q '\.ai' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  IS_SUBMODULE=true
fi

if [ "$IS_SUBMODULE" != "true" ]; then
  echo "  Skipping template/workflow setup (not a submodule context)"
  return 0 2>/dev/null || exit 0
fi

# --- Issue templates ---
TEMPLATE_SRC="$AI_DIR/.github/ISSUE_TEMPLATE"
TEMPLATE_DST="$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
if [ -d "$TEMPLATE_SRC" ]; then
  mkdir -p "$TEMPLATE_DST"
  for tmpl in "$TEMPLATE_SRC"/*.yml; do
    [ -f "$tmpl" ] || continue
    TMPL_NAME=$(basename "$tmpl")
    if [ ! -f "$TEMPLATE_DST/$TMPL_NAME" ]; then
      run_cmd "Copy issue template $TMPL_NAME" cp "$tmpl" "$TEMPLATE_DST/$TMPL_NAME"
      echo "  Copied issue template $TMPL_NAME"
    else
      echo "  Issue template $TMPL_NAME already exists, skipping"
    fi
  done
fi

# --- Governance workflows ---
WORKFLOW_SRC="$AI_DIR/.github/workflows"
WORKFLOW_DST="$PROJECT_ROOT/.github/workflows"
if [ -d "$WORKFLOW_SRC" ]; then
  mkdir -p "$WORKFLOW_DST"
  # Read workflow lists from config.yaml if Python is available
  REQUIRED_WORKFLOWS="dark-factory-governance.yml"
  OPTIONAL_WORKFLOWS=""
  if [ -n "$PYTHON_CMD" ]; then
    CONFIG_WORKFLOWS=$("$PYTHON_CMD" -c "
import yaml, os, sys

def deep_merge(base, override):
    result = dict(base)
    for k, v in override.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = deep_merge(result[k], v)
        elif k in result and isinstance(result[k], list) and isinstance(v, list):
            result[k] = result[k] + v
        else:
            result[k] = v
    return result

config = {}
for f in sys.argv[1:]:
    if os.path.exists(f):
        with open(f) as fh:
            data = yaml.safe_load(fh) or {}
            config = deep_merge(config, data)

wf = config.get('workflows', {})
if isinstance(wf, dict):
    req = wf.get('required', ['dark-factory-governance.yml'])
    opt = wf.get('optional', [])
else:
    req = config.get('workflows_to_copy', ['dark-factory-governance.yml'])
    opt = []
print('REQUIRED=' + ' '.join(req))
print('OPTIONAL=' + ' '.join(opt))
" "$AI_DIR/config.yaml" "$AI_DIR/project.yaml" "$PROJECT_ROOT/project.yaml" 2>/dev/null)
    if [ -n "$CONFIG_WORKFLOWS" ]; then
      REQUIRED_WORKFLOWS=$(echo "$CONFIG_WORKFLOWS" | grep '^REQUIRED=' | sed 's/^REQUIRED=//')
      OPTIONAL_WORKFLOWS=$(echo "$CONFIG_WORKFLOWS" | grep '^OPTIONAL=' | sed 's/^OPTIONAL=//')
    fi
  fi

  # Link required workflows (warn if source is missing)
  for wf_name in $REQUIRED_WORKFLOWS; do
    if [ -f "$WORKFLOW_SRC/$wf_name" ]; then
      link_target="../../.ai/.github/workflows/$wf_name"
      if [ -L "$WORKFLOW_DST/$wf_name" ] && [ "$(readlink "$WORKFLOW_DST/$wf_name")" = "$link_target" ]; then
        echo "  Workflow $wf_name already linked"
      elif [ -f "$WORKFLOW_DST/$wf_name" ] && [ ! -L "$WORKFLOW_DST/$wf_name" ]; then
        echo "  Workflow $wf_name exists as regular file, skipping (remove to use symlink)"
      else
        run_cmd "Symlink workflow $wf_name" ln -sf "$link_target" "$WORKFLOW_DST/$wf_name"
        echo "  Linked $wf_name -> .ai/.github/workflows/$wf_name"
      fi
    else
      log_warn "Required workflow $wf_name not found in .ai/.github/workflows/"
    fi
  done

  # Link optional workflows (skip silently if source is missing)
  for wf_name in $OPTIONAL_WORKFLOWS; do
    if [ -f "$WORKFLOW_SRC/$wf_name" ]; then
      link_target="../../.ai/.github/workflows/$wf_name"
      if [ -L "$WORKFLOW_DST/$wf_name" ] && [ "$(readlink "$WORKFLOW_DST/$wf_name")" = "$link_target" ]; then
        echo "  Workflow $wf_name already linked (optional)"
      elif [ -f "$WORKFLOW_DST/$wf_name" ] && [ ! -L "$WORKFLOW_DST/$wf_name" ]; then
        echo "  Workflow $wf_name exists as regular file, skipping (optional)"
      else
        run_cmd "Symlink optional workflow $wf_name" ln -sf "$link_target" "$WORKFLOW_DST/$wf_name"
        echo "  Linked $wf_name -> .ai/.github/workflows/$wf_name (optional)"
      fi
    fi
  done
fi

# --- GOALS.md ---
GOALS_TEMPLATE="$AI_DIR/governance/templates/GOALS.md"
GOALS_DST="$PROJECT_ROOT/GOALS.md"
if [ -f "$GOALS_TEMPLATE" ]; then
  if [ -f "$GOALS_DST" ]; then
    echo "  GOALS.md already exists, skipping"
  else
    run_cmd "Create GOALS.md" cp "$GOALS_TEMPLATE" "$GOALS_DST"
    echo "  Created GOALS.md from template"
  fi
else
  log_warn "GOALS.md template not found at $GOALS_TEMPLATE"
fi
