import ballerina/http;
import ballerina/workflow.management.rest as _;

// A chat turn can block on a human task/approval far past the 60s default, so the listener never times it out.
service /agent on new http:Listener(8080, timeout = 0) {
    resource function post conversations(NewConversation payload) returns string|error {
        string claimId = check claimAgent.run(string `user=${payload.username}`);
        return claimId;
    }

    resource function post conversations/[string id]/messages(ChatMessage m) returns string|error {
        string token = check claimAgent.sendData(id, "chat", m.message);
        string result = check claimAgent.waitForDataResult(id, token);
        return result;
    }

    resource function post cases/[string caseId]/submit(CaseSubmission c) returns string|error {
        string token = check claimAgent.sendData(c.conversationId, "chat", string `[case-submitted] ${caseId} ${c.documentUrl}`);
        return token;
    }

    resource function get conversations/[string id]/state() returns string|error {
        string state = check claimAgent.getResult(id);
        return state;
    }
}
