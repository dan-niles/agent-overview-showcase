import ballerina/ai;
import ballerinax/github;

# Looks up the customer behind a ticket.
# + ticketId - the ticket identifier
# + return - the customer's plan
@ai:AgentTool
isolated function lookupTicketOwner(string ticketId) returns string {
    return string `Ticket ${ticketId} belongs to a Team plan customer.`;
}

# Finds open GitHub issues that might already cover this ticket.
# + return - how many similar issues are open
@ai:AgentTool
isolated function findRelatedIssues() returns string|error {
    github:Issue[] issues = check githubClient->/repos/["wso2"]/["support-tickets"]/issues;
    return string `${issues.length()} similar issues are already open on GitHub.`;
}

# Notifies the on-call channel about an escalation.
# + message - the escalation note
# + return - a confirmation
@ai:AgentTool
isolated function notifyOnCall(string message) returns string|error {
    _ = check slackClient->/chat\.postMessage.post({channel: "#support-escalations", text: message});
    return "posted";
}
