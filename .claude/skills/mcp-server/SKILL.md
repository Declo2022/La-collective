---
name: mcp-server
description: >-
  Build, structure, and debug Model Context Protocol (MCP) servers that expose
  tools, resources, and prompts to Claude and other MCP clients. Use when the
  user says "create an MCP server", "add an MCP tool", "expose X over MCP",
  "build a connector", "write a stdio/HTTP MCP server", or wants to design tool
  schemas, wire up transports, or debug why a client can't see their server.
---

# MCP Server

Build a well-formed MCP server: define capabilities (tools, resources, prompts),
serve them over a transport (stdio or streamable HTTP), and design schemas and
descriptions a client model can actually use correctly.

## What MCP is

The Model Context Protocol is a JSON-RPC-based standard that lets an AI client
connect to external servers exposing three capability types:

- **Tools** — model-invocable functions with typed input schemas (the model
  decides when to call them).
- **Resources** — readable data identified by URI (files, records, docs) the
  client can load into context.
- **Prompts** — reusable prompt templates the user can invoke.

A server declares which of these it supports during initialization, then
responds to `list` and `call/read/get` requests.

## Workflow

1. **Pick the SDK + language.** Prefer the official SDKs: TypeScript
   (`@modelcontextprotocol/sdk`) or Python (`mcp`). Match the repo's existing
   language.
2. **Choose the transport.**
   - **stdio** — local server launched by the client as a subprocess; the
     default for desktop/CLI integrations.
   - **Streamable HTTP** — remote/networked server; use for hosted connectors.
3. **Design the capabilities** (schemas + descriptions — see below).
4. **Implement handlers**, validating input and returning structured results.
5. **Register the server** in the client config and test it end-to-end.
6. **Debug** with the inspector if the client can't see or call it.

## Designing tools (this is what makes a server usable)

The tool's **name**, **description**, and **input schema** are the model's only
interface — treat them like a prompt:

- **Name**: a clear verb-noun (`search_orders`, `create_invoice`), lowercase.
- **Description**: state what it does, when to use it, and any important
  constraints or side effects. This is how the model decides to call it — be
  concrete, not vague.
- **Input schema**: JSON Schema. Mark required fields, describe every parameter,
  use enums for fixed choices, and give examples in descriptions. Keep inputs
  minimal — fewer, well-described params beat many ambiguous ones.
- **Output**: return content the model can use; on failure return a clear error
  message rather than throwing an opaque exception.
- **Side effects**: for write/destructive tools, say so in the description so the
  client can gate them. Keep read and write tools separate.

## Security and safety

- **Validate all inputs** — never interpolate arguments straight into shell
  commands, SQL, or file paths. Treat tool arguments as untrusted.
- **Least privilege** — expose only what's needed; scope file/DB access.
- **Secrets** come from environment/config, never hard-coded or logged.
- **Confirm destructive actions** — mark them clearly so the client can require
  approval.

## Debugging a server the client can't see

- Run the **MCP Inspector** (`npx @modelcontextprotocol/inspector`) to exercise
  the server directly, independent of the client.
- For stdio servers, **never write logs to stdout** — stdout is the JSON-RPC
  channel. Log to stderr or a file.
- Check the client config path, command, args, and env are correct and the
  process actually starts.
- Confirm the server declares the capability it's serving during
  initialization.

For copy-ready server skeletons (TypeScript + Python, stdio + HTTP), a tool
schema example, and client config, read `references/examples.md`.
