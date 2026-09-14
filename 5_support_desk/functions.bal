import ballerina/ai;
import ballerinax/github;

# Looks up an invoice for an account.
# + accountId - the customer's account identifier
# + return - the latest invoice summary
@ai:AgentTool
isolated function lookupInvoice(string accountId) returns string {
    return string `Invoice INV-4821 for ${accountId}: 49.00 USD, paid.`;
}

# Issues a refund against an invoice.
# + invoiceId - the invoice to refund
# + amount - the amount to refund in USD
# + return - a confirmation message
@ai:AgentTool
isolated function issueRefund(string invoiceId, decimal amount) returns string {
    return string `Refunded ${amount} USD against ${invoiceId}.`;
}

# Searches the product knowledge base.
# + query - the search query
# + return - the most relevant article
@ai:AgentTool
isolated function searchKnowledgeBase(string query) returns string {
    return string `No article matches "${query}".`;
}

# Finds open GitHub issues related to a problem.
# + owner - the repository owner
# + repo - the repository name
# + return - the number of open issues in the repository
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_github_6.0.0.png"}
isolated function findRelatedIssues(string owner, string repo) returns string|error {
    github:Issue[] issues = check githubClient->/repos/[owner]/[repo]/issues;
    return string `${issues.length()} open issues in ${owner}/${repo}`;
}

# Looks up an order.
# + orderId - the order identifier
# + return - the order summary
@ai:AgentTool
isolated function lookupOrder(string orderId) returns string {
    return string `Order ${orderId}: 2 items, shipped to Colombo, weight 1.2 kg.`;
}

# Starts a return for an order.
# + orderId - the order identifier
# + reason - why the customer is returning it
# + return - the return reference
@ai:AgentTool
isolated function initiateReturn(string orderId, string reason) returns string {
    return string `Return RMA-17 opened for ${orderId}: ${reason}`;
}

# Gets shipping rates from the rates API.
# + destination - the destination country
# + weightKg - the parcel weight in kilograms
# + return - the available rates as JSON
@ai:AgentTool
isolated function getRates(string destination, decimal weightKg) returns string|error {
    json rates = check ratesApi->/quote.post({destination, weightKg});
    return rates.toJsonString();
}

# Returns the current price list.
# + return - the price list
@ai:AgentTool
isolated function priceList() returns string {
    return "Starter 29 USD, Team 99 USD, Enterprise on request.";
}

# Delegates a billing question to the billing specialist.
# + query - the request for the billing specialist
# + return - the specialist's answer
@ai:AgentTool
isolated function billingAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check billingAgent.run(query, context = ctx);
    return result;
}

# Delegates a technical question to the technical specialist.
# + query - the request for the technical specialist
# + return - the specialist's answer
@ai:AgentTool
isolated function technicalSupportAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check technicalSupportAgent.run(query, context = ctx);
    return result;
}

# Delegates an order question to the order specialist.
# + query - the request for the order specialist
# + return - the specialist's answer
@ai:AgentTool
isolated function orderAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check orderAgent.run(query, context = ctx);
    return result;
}

# Asks the shipping rates specialist for a rate.
# + query - the request for the shipping rates specialist
# + return - the specialist's answer
@ai:AgentTool
isolated function shippingRatesAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check shippingRatesAgent.run(query, context = ctx);
    return result;
}

# Asks the quote specialist for a price quote.
# + query - the request for the quote specialist
# + return - the specialist's answer
@ai:AgentTool
isolated function quoteAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check quoteAgent.run(query, context = ctx);
    return result;
}
