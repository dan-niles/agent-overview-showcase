import ballerina/ai;

# Looks the customer up.
@ai:AgentTool
isolated function lookupCustomer(string customerId) returns string|error {
    json customer = check crmApi->/customers/[customerId];
    return customer.toJsonString();
}
# Pages the on-call engineer.
@ai:AgentTool
isolated function pageOnCall(string summary) returns string|error {
    json response = check pagerApi->/page.post({summary});
    return response.toJsonString();
}
