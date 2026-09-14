import ballerina/ai;
import ballerina/http;

final ai:McpToolKit inventoryTools = check new ("http://localhost:9601/mcp");
final http:Client catalogApi = check new ("http://localhost:9602/catalog");
