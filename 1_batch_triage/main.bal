import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /tickets on httpDefaultListener {
    resource function post triage(@http:Payload TicketBatch payload) returns string[]|error {
        string[] labels = [];
        foreach Ticket ticket in payload.tickets {
            string label = check triageAgent.run(ticket.text, ticket.id);
            labels.push(label);
        }
        return labels;
    }

    resource function post escalate(@http:Payload Ticket payload) returns string|error {
        int attempts = 0;
        string note = "";
        while attempts < 3 {
            note = check escalationAgent.run(payload.text, payload.id);
            attempts += 1;
        }
        return note;
    }
}
