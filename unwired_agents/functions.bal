import ballerina/ai;

# Looks up an account.
# + accountId - the account identifier
# + return - the account summary
@ai:AgentTool
isolated function lookupAccount(string accountId) returns string {
    return string `Account ${accountId}: active.`;
}
