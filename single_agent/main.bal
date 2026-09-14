import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /faq\-agent on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string answer = check faqAgent.run(request.message, sessionId = request.sessionId);
        return {message: answer};
    }

}

service /faq on httpDefaultListener {
    resource function post ask(@http:Payload FaqRequest payload) returns string|error {
        string result = check faqAgent.run(payload.question, payload.customerId);
        return result;
    }
}
