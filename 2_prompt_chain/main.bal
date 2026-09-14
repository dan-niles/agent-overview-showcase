import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /articles on httpDefaultListener {
    // Sequential pipeline: research, draft, edit — each step fed the previous step's output.
    resource function post write(@http:Payload Topic topic) returns string|error {
        string notes = check researchAgent.run(string `Research: ${topic.title}`, topic.id);
        string draft = check draftAgent.run(string `Draft from: ${notes}`, topic.id);
        string result = check editAgent.run(string `Edit: ${draft}`, topic.id);
        return result;
    }
}
