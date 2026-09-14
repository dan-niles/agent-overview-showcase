import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /research on httpDefaultListener {
    // Orchestrator-workers: the orchestrator fans out to three typed workers, then a synthesizer writes the report.
    resource function post .(@http:Payload Question question) returns string|error {
        string findings = check orchestratorAgent.run(question.question, question.id);
        string result = check synthesizerAgent.run(string `Report from: ${findings}`, question.id);
        return result;
    }
}
