import { join } from "node:path";
import { z } from "zod";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { readTextFile } from "./utils.js";

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
