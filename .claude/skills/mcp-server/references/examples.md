# MCP Server Examples

Copy-ready skeletons using the official SDKs. Adapt names, schemas, and logic.

## TypeScript — stdio server

```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "orders", version: "1.0.0" });

// Tool: model-invocable, typed input, clear description.
server.tool(
  "search_orders",
  "Search orders by customer email or status. Read-only. Returns up to `limit` " +
    "matching orders as JSON.",
  {
    email: z.string().email().optional().describe("Customer email to filter by"),
    status: z.enum(["open", "shipped", "cancelled"]).optional()
      .describe("Order status filter"),
    limit: z.number().int().min(1).max(100).default(20)
      .describe("Max results to return"),
  },
  async ({ email, status, limit }) => {
    const results = await findOrders({ email, status, limit }); // your logic
    return { content: [{ type: "text", text: JSON.stringify(results, null, 2) }] };
  }
);

// Resource: readable data by URI.
server.resource("order", "order://{id}", async (uri, { id }) => ({
  contents: [{ uri: uri.href, text: JSON.stringify(await getOrder(id)) }],
}));

const transport = new StdioServerTransport();
await server.connect(transport);
// NOTE: never console.log to stdout — it corrupts the JSON-RPC stream.
// Use console.error for logs.
```

## TypeScript — streamable HTTP server

```ts
import express from "express";
import { StreamableHTTPServerTransport } from
  "@modelcontextprotocol/sdk/server/streamableHttp.js";

const app = express();
app.use(express.json());

app.post("/mcp", async (req, res) => {
  const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
  await server.connect(transport);            // `server` built as above
  await transport.handleRequest(req, res, req.body);
});

app.listen(3000, () => console.error("MCP server on :3000/mcp"));
```

## Python — stdio server (FastMCP)

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("orders")

@mcp.tool()
def search_orders(email: str | None = None,
                  status: str | None = None,
                  limit: int = 20) -> str:
    """Search orders by customer email or status. Read-only.

    Args:
        email: Customer email to filter by.
        status: One of "open", "shipped", "cancelled".
        limit: Max results (1-100).
    """
    results = find_orders(email=email, status=status, limit=limit)  # your logic
    return json.dumps(results, indent=2)

@mcp.resource("order://{order_id}")
def get_order_resource(order_id: str) -> str:
    return json.dumps(get_order(order_id))

if __name__ == "__main__":
    mcp.run()  # stdio transport
```

## Client config (Claude Code / desktop) — stdio

```json
{
  "mcpServers": {
    "orders": {
      "command": "node",
      "args": ["/abs/path/to/build/index.js"],
      "env": { "DATABASE_URL": "postgres://..." }
    }
  }
}
```

Python equivalent uses `"command": "python"`, `"args": ["/abs/path/server.py"]`.

## Debug with the inspector

```bash
# TypeScript stdio server
npx @modelcontextprotocol/inspector node build/index.js

# Python
npx @modelcontextprotocol/inspector python server.py
```

The inspector lets you list and call tools/resources directly, so you can tell
whether a problem is in the server or in the client wiring.

## Tool-description checklist

- [ ] Name is a clear verb-noun, lowercase.
- [ ] Description says what it does, when to use it, and side effects.
- [ ] Every parameter is described; required vs optional is explicit.
- [ ] Fixed choices use enums; ranges are constrained.
- [ ] Read and write tools are separate; destructive ones are flagged.
- [ ] Inputs are validated before use (no raw shell/SQL/path interpolation).
- [ ] Errors return a clear message, not an opaque throw.
- [ ] stdio servers log to stderr, never stdout.
