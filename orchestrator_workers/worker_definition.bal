import ballerina/ai;

# A research worker; the orchestrator runs several instances of it.
public isolated class ResearchWorker {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    public function init(ai:ModelProvider model, string focus) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Research Worker`,
                instructions: string `You research one aspect of a question: ${focus}. Ask the citation agent to verify sources.`
            },
            model = model,
            tools = [self.searchWeb, citationAgentTool]
        );
    }

    public isolated function run(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new) returns string|ai:Error {
        string result = check self.agent.run(query, sessionId, context);
        return result;
    }

    public isolated function trace(string|ai:Prompt query, string sessionId = "sessionId", ai:Context context = new) returns ai:Trace|ai:Error {
        ai:Trace result = check self.agent.run(query, sessionId, context);
        return result;
    }

    # Searches the web for a query.
    # + query - what to search for
    # + return - the top result
    @ai:AgentTool
    isolated function searchWeb(string query) returns string|error {
        json result = check searchApi->/search.post({query});
        return result.toJsonString();
    }
}
