import ballerina/ai;

final ai:Wso2ModelProvider storeModel = check ai:getDefaultModelProvider();

// A function tool beside a named MCP toolkit and an inline one.
final ai:Agent stockAgent = check new (
    systemPrompt = {
        role: string `Stock`,
        instructions: string `You answer stock questions with the inventory tools and the catalog.`
    }, model = storeModel, tools = [lookupSku, inventoryTools, check new ai:McpToolKit("http://localhost:9603/mcp")]
);

// Only MCP tools: the design model sees no tool functions.
final ai:Agent supplierAgent = check new (
    systemPrompt = {
        role: string `Suppliers`,
        instructions: string `You contact suppliers through their MCP server.`
    }, model = storeModel, tools = [inventoryTools]
);
