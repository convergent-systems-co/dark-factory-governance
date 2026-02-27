# MCP Server Usage Guide

The `@jm-packages/ai-submodule-mcp` server exposes governance prompts, review panels, policy profiles, and tools via the [Model Context Protocol](https://modelcontextprotocol.io/) (MCP). This allows any MCP-compatible IDE or AI assistant to access governance resources without directly reading the ai-submodule filesystem.

## Installation

### npx (recommended)

```bash
npx @jm-packages/ai-submodule-mcp --governance-root /path/to/ai-submodule
```

### From source

```bash
cd mcp-server
npm install
npm run build
node dist/index.js --governance-root /path/to/ai-submodule
```

### Docker

```bash
cd mcp-server
npm run build
docker build -t ai-submodule-mcp --build-arg GOVERNANCE_SRC=../governance .
docker run -i ai-submodule-mcp
```

### Installer scripts

The installer scripts automatically configure Claude Code, VS Code, and Cursor:

**macOS / Linux:**
```bash
bash mcp-server/install.sh --governance-root /path/to/ai-submodule
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File mcp-server\install.ps1 -GovernanceRoot C:\path\to\ai-submodule
```

## CLI Options

| Option | Default | Description |
|--------|---------|-------------|
| `--governance-root` | Auto-detected | Path to the repository root containing `governance/` |

If `--governance-root` is not specified, the server walks up from its install location to find the `governance/` directory (works for both the ai-submodule itself and consuming repos with `.ai/governance/`).

## IDE Configuration

### Claude Code

Add to `~/.claude.json`:

```json
{
  "mcpServers": {
    "ai-submodule-mcp": {
      "command": "node",
      "args": ["/path/to/mcp-server/dist/index.js", "--governance-root", "/path/to/repo"]
    }
  }
}
```

### VS Code

Add to VS Code settings (`settings.json`):

```json
{
  "mcp.servers": {
    "ai-submodule-mcp": {
      "command": "node",
      "args": ["/path/to/mcp-server/dist/index.js", "--governance-root", "/path/to/repo"]
    }
  }
}
```

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "ai-submodule-mcp": {
      "command": "node",
      "args": ["/path/to/mcp-server/dist/index.js", "--governance-root", "/path/to/repo"]
    }
  }
}
```

## Available Resources

Resources are served as read-only content via `governance://` URIs.

### Review Prompts (20)

URI pattern: `governance://reviews/{panel-name}`

| URI | Description |
|-----|-------------|
| `governance://reviews/code-review` | Comprehensive code evaluation |
| `governance://reviews/security-review` | Security vulnerability analysis |
| `governance://reviews/threat-modeling` | STRIDE/MITRE ATT&CK threat analysis |
| `governance://reviews/cost-analysis` | Cost impact assessment |
| `governance://reviews/documentation-review` | Documentation completeness check |
| `governance://reviews/data-governance-review` | Data classification and handling |
| `governance://reviews/architecture-review` | Architecture pattern evaluation |
| `governance://reviews/performance-review` | Performance impact analysis |
| `governance://reviews/testing-review` | Test coverage evaluation |
| `governance://reviews/ai-expert-review` | AI/ML governance assessment |
| `governance://reviews/api-design-review` | API design quality |
| `governance://reviews/copilot-review` | AI assistant output review |
| `governance://reviews/data-design-review` | Data model evaluation |
| `governance://reviews/governance-compliance-review` | Governance pipeline compliance |
| `governance://reviews/incident-post-mortem` | Incident analysis |
| `governance://reviews/migration-review` | Migration safety review |
| `governance://reviews/production-readiness-review` | Production readiness gate |
| `governance://reviews/technical-debt-review` | Technical debt assessment |
| `governance://reviews/test-generation-review` | Test generation evaluation |
| `governance://reviews/threat-model-system` | System-level threat model |

### Workflow Templates (10)

URI pattern: `governance://workflows/{workflow-name}`

Includes: feature-implementation, bug-fix, refactoring, documentation, migration, api-design, architecture-decision, incident-response, acceptance-verification, and index.

### Personas (5)

URI pattern: `governance://personas/{persona-name}`

| URI | Description |
|-----|-------------|
| `governance://personas/code-manager` | Pipeline orchestrator |
| `governance://personas/coder` | Implementation agent |
| `governance://personas/devops-engineer` | Session entry point and routing |
| `governance://personas/iac-engineer` | Infrastructure execution agent |
| `governance://personas/tester` | Independent evaluator |

### Shared Resources

| URI | Description |
|-----|-------------|
| `governance://shared/perspectives` | Shared perspective definitions |
| `governance://schemas/panel-output` | Panel output JSON schema |

### Policy Profiles (4)

URI pattern: `governance://policy/{profile-name}`

| URI | Description |
|-----|-------------|
| `governance://policy/default` | Standard risk tolerance, auto-merge enabled |
| `governance://policy/fin_pii_high` | SOC2/PCI-DSS/HIPAA/GDPR compliance |
| `governance://policy/infrastructure_critical` | Mandatory architecture and SRE review |
| `governance://policy/reduced_touchpoint` | Near-full autonomy |

## Available Tools

### validate_emission

Validate a panel emission JSON against the `panel-output.schema.json` schema.

**Parameters:**
- `emission_json` (string, required): The JSON string to validate

**Returns:** `{valid: boolean, errors?: string[]}`

### check_policy

Run the policy engine against a directory of panel emissions.

**Parameters:**
- `emissions_dir` (string, required): Path to the emissions directory
- `profile` (string, default: "default"): Policy profile name

**Returns:** `{decision: string, details: string}`

**Note:** Requires Python 3 to be available on PATH.

### generate_name

Generate a compliant Azure resource name.

**Parameters:**
- `resource_type` (string, required): Azure resource type (e.g., `Microsoft.KeyVault/vaults`)
- `lob` (string, required): Line of business code
- `stage` (string, required): Deployment stage (dev, staging, prod)
- `app_name` (string, required): Application name
- `app_id` (string, required): Application identifier

**Returns:** `{name: string}` or `{error: string}`

**Note:** Requires Python 3 to be available on PATH.

### list_panels

List all available governance review panels.

**Returns:** Array of `{name, description, uri}`

### list_policy_profiles

List available policy profiles with their key settings.

**Returns:** Array of `{name, description, risk_tolerance, auto_merge}`

## Available Prompts

### governance_review

Run a governance review panel. Loads the full review prompt content for the specified panel.

**Arguments:**
- `panel_name` (string, required): Name of the review panel (e.g., `code-review`, `security-review`)

### plan_create

Create an implementation plan using the governance plan template.

**Arguments:** None

### threat_model

Perform threat modeling analysis using the threat modeling prompt.

**Arguments:** None

## Content Integrity

The server provides manifest generation for integrity validation:

```typescript
import { generateManifest, validateManifest } from "./manifest.js";

const manifest = await generateManifest("/path/to/governance-root");
// manifest.files: [{path, hash (SHA-256), size}]
// manifest.generated_at: ISO 8601 timestamp

const result = await validateManifest("/path/to/governance-root", storedManifest);
// result.valid: boolean
// result.mismatches: [{path, expected, actual, reason}]
```

## Development

```bash
cd mcp-server
npm install
npm run build         # Compile TypeScript
npm test              # Run test suite
npm run test:watch    # Run tests in watch mode
```

## Troubleshooting

### "Could not find governance/ directory"

The server could not auto-detect the governance root. Pass `--governance-root` explicitly:

```bash
node dist/index.js --governance-root /path/to/ai-submodule
```

### Python tools return errors

The `check_policy` and `generate_name` tools require Python 3 on PATH. Install Python 3 and ensure it is accessible as `python3` (Unix) or `python` (Windows).

### Server starts but no resources appear

Verify the governance root contains the expected directory structure:

```
governance/
  prompts/reviews/     (20 .md files)
  prompts/workflows/   (10 .md files)
  personas/agentic/    (5 .md files)
  policy/              (4 primary .yaml files)
  schemas/             (panel-output.schema.json)
```
