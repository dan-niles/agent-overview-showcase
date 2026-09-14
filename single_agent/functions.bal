import ballerina/ai;

# Searches the product documentation.
# + query - the search query
# + return - the most relevant documentation snippet
@ai:AgentTool
isolated function searchDocs(string query) returns string {
    return string `No documentation found for "${query}".`;
}

# Looks up the current status of an order.
# + orderId - the order identifier, for example ORD-1001
# + return - the order status, or an error if the lookup failed
@ai:AgentTool
isolated function lookupOrderStatus(string orderId) returns string|error {
    json status = check ordersApi->/[orderId]/status.get();
    return status.toJsonString();
}
