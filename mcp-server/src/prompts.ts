import { join } from "node:path";
import { readdir } from "node:fs/promises";
import { z } from "zod";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { readTextFile, parseMarkdownWithFrontmatter } from "./utils.js";

/**
 * Register all MCP prompts with the server.
 */
export function registerPrompts(
  server: McpServer,
  governanceRoot: string
): void {
  // Prompt: governance_review
  server.prompt(
    "governance_review",
    "Run a governance review panel against code changes",
    {
      panel_name: z.string().describe(
        "Name of the review panel (e.g., code-review, security-review, threat-modeling)"
      ),
    },
    async ({ panel_name }) => {
      const reviewPath = join(
        governanceRoot,
        "governance",
        "prompts",
        "reviews",
        `${panel_name}.md`
      );

      try {
        const content = await readTextFile(reviewPath);
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: content,
              },
            },
          ],
        };
      } catch {
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: `Error: Review panel "${panel_name}" not found. Use list_panels tool to see available panels.`,
              },
            },
          ],
        };
      }
    }
  );

  // Prompt: plan_create
  server.prompt(
    "plan_create",
    "Create an implementation plan using the governance plan template",
    async () => {
      const templatePath = join(
        governanceRoot,
        "governance",
        "prompts",
        "templates",
        "plan-template.md"
      );

      try {
        const content = await readTextFile(templatePath);
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: `Use this template to create an implementation plan:\n\n${content}`,
              },
            },
          ],
        };
      } catch {
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: "Error: Plan template not found at governance/prompts/templates/plan-template.md",
              },
            },
          ],
        };
      }
    }
  );

  // Prompt: threat_model
  server.prompt(
    "threat_model",
    "Perform threat modeling analysis on code changes",
    async () => {
      const threatPath = join(
        governanceRoot,
        "governance",
        "prompts",
        "reviews",
        "threat-modeling.md"
      );

      try {
        const content = await readTextFile(threatPath);
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: content,
              },
            },
          ],
        };
      } catch {
        return {
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: "Error: Threat modeling prompt not found at governance/prompts/reviews/threat-modeling.md",
              },
            },
          ],
        };
      }
    }
  );
}

/**
 * Recursively scan a directory for *.prompt.md files.
 */
async function scanPromptFiles(dir: string): Promise<string[]> {
  const results: string[] = [];

  async function walk(d: string): Promise<void> {
    let entries;
    try {
      entries = await readdir(d, { withFileTypes: true });
    } catch {
      return;
    }

    for (const entry of entries) {
      const fullPath = join(d, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith(".prompt.md")) {
        results.push(fullPath);
      }
    }
  }

  await walk(dir);
  return results.sort();
}

/**
 * Discover *.prompt.md files under prompts/ and register each as an MCP prompt.
 *
 * Each file must have YAML frontmatter with at least `name` and `description`.
 * The prompt handler returns the full markdown content (after frontmatter).
 */
export async function discoverAndRegisterPrompts(
  server: McpServer,
  governanceRoot: string
): Promise<number> {
  const promptsDir = join(governanceRoot, "prompts");
  const files = await scanPromptFiles(promptsDir);
  let registered = 0;

  for (const filePath of files) {
    try {
      const raw = await readTextFile(filePath);
      const { data, content } = parseMarkdownWithFrontmatter(raw);

      const name = data.name as string | undefined;
      const description = data.description as string | undefined;

      if (!name) {
        console.error(
          `[ai-submodule-mcp] Skipping prompt file (missing 'name' in frontmatter): ${filePath}`
        );
        continue;
      }

      server.prompt(
        name,
        description ?? "",
        async () => ({
          messages: [
            {
              role: "user" as const,
              content: {
                type: "text" as const,
                text: content.trim(),
              },
            },
          ],
        })
      );

      registered++;
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.error(
        `[ai-submodule-mcp] Failed to register prompt from ${filePath}: ${message}`
      );
    }
  }

  return registered;
}
