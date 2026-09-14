import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /decisions on httpDefaultListener {
    // Maker-checker: the maker drafts, the checker reviews; the checker can push corrections back to the maker.
    resource function post propose(@http:Payload Decision decision) returns string|error {
        string draft = check makerAgent.run(string `Decide on ${decision.orderId}`, decision.orderId);
        string result = check checkerAgent.run(string `Review: ${draft}`, decision.orderId);
        return result;
    }

    // The human's answer arrives later as its own request.
    resource function post approve(@http:Payload Decision decision) returns string|error {
        if decision.approved {
            _ = check executorAgent.run(string `Execute ${decision.orderId}`, decision.orderId, td = string);
            string result = check notifyAgent.run("Tell the customer it is done.", decision.orderId);
            return result;
        } else {
            string result = check notifyAgent.run("Tell the customer it was declined.", decision.orderId);
            return result;
        }
    }

    // A handler with no agent at all: the overview must not draw it.
    resource function get pending() returns string[] {
        return ["ORD-1", "ORD-2"];
    }
}
