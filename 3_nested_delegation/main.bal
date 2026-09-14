import ballerina/ai;
import ballerina/http;

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /company on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string answer = check ceoAgent.run(request.message, sessionId = request.sessionId);
        return {message: answer};
    }
}
