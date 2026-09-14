import ballerina/ai;

# Looks a SKU up in the catalog.
@ai:AgentTool
isolated function lookupSku(string sku) returns string|error {
    json item = check catalogApi->/skus/[sku];
    return item.toJsonString();
}
