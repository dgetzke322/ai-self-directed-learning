import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const commands = [
  {
    name: "Create PRD",
    prompt: `# Create PRD
## Role
Product Manager

## Task
Write PRD for DevLog.

## Context
Daily developer activity digest. Developers fill web form. System aggregates nightly, posts to Slack.

## Constraints
- Problem and solution
- All rules explicit
- V1 scope
- Tech context (React, FastAPI, PostgreSQL, Slack Bolt, Docker/ECS, Entra ID)`,
  },
  {
    name: "Create Architecture",
    prompt: `# Create Architecture
## Role
Senior Solutions Architect

## Task
Given DevLog PRD, produce architecture.

## Context
Tech stack: React 18, Python/FastAPI, PostgreSQL 16, Slack Bolt, Docker/ECS Fargate, Entra ID OIDC

## Constraints
- 8 required sections (overview, components, data, API, security, deployment, decisions, tradeoffs)
- Privacy-by-schema (no FK from responses to users)
- Multi-tenant isolation`,
  },
];

async function run() {
  for (const cmd of commands.slice(0, 1)) {
    // Just first one to test
    console.log(`\n${'='.repeat(60)}`);
    console.log(`${cmd.name}`);
    console.log('='.repeat(60));
    const message = await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 2000,
      messages: [{ role: "user", content: cmd.prompt }],
    });
    console.log(message.content[0].type === "text" ? message.content[0].text : "");
  }
}

run().catch(console.error);
