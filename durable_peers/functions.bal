import ballerina/ai;
import ballerina/workflow;

# Asks the stock desk whether an item is available.
# + item - the item name
# + return - the stock desk's answer
@ai:AgentTool
isolated function askStock(string item) returns string|error {
    return stockAgent.run(string `Is ${item} in stock?`);
}

@workflow:Activity
function reserveItems(string[] items) returns string|error {
    return string `reserved ${items.length()} items`;
}

@workflow:Activity
function chargeCard(string customer, decimal amount) returns string|error {
    return string `charged ${customer} ${amount}`;
}
