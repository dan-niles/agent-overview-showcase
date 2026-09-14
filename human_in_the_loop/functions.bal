import ballerina/ai;

# Looks an order up.
@ai:AgentTool
isolated function lookupOrder(string orderId) returns string {
    return string `Order ${orderId}`;
}
# Issues a refund; a human must have approved it.
@ai:AgentTool
isolated function issueRefund(string orderId) returns string {
    return string `Refunded ${orderId}`;
}