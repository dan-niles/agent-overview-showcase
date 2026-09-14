import ballerina/ai;

# Looks up the customer behind a ticket.
# + ticketId - the ticket identifier
# + return - the customer's plan
@ai:AgentTool
isolated function lookupTicketOwner(string ticketId) returns string {
    return string `Ticket ${ticketId} belongs to a Team plan customer.`;
}
