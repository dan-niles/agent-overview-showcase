import ballerina/ai;

# Looks an invoice up.
@ai:AgentTool
isolated function lookupInvoice(string accountId) returns string {
    return string `Invoice for ${accountId}`;
}
