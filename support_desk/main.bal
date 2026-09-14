import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /help\-desk on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string answer = check supportSupervisorAgent.run(request.message, sessionId = request.sessionId);
        return {message: answer};
    }
}

service /shipping\-api on httpDefaultListener {
    resource function post quotes(@http:Payload QuoteRequest payload) returns string|error {
        string orderSummary = check orderAgent.run(string `Summarise order ${payload.orderId} for a shipping quote.`, payload.orderId);
        string rate = check shippingRatesAgent.run(string `Quote shipping to ${payload.destination} for: ${orderSummary}`, payload.orderId);
        return rate;
    }
}

service /sales on httpDefaultListener {
    resource function post ask(@http:Payload SalesQuestion payload) returns string|error {
        string result = check salesSupervisorAgent.run(payload.question, payload.leadId);
        return result;
    }
}
