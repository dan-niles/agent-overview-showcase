import ballerina/ai;

# Fetches a source document.
@ai:AgentTool
isolated function fetchSource(string url) returns string|error {
    json doc = check sourceApi->/fetch.post({url});
    return doc.toJsonString();
}
# Asks the citation agent to verify a source.
@ai:AgentTool
isolated function citationAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check citationAgent.run(query, context = ctx);
    return result;
}

# Hands the market aspect to its worker.
@ai:AgentTool
isolated function marketWorkerTool(string query) returns string|error {
    string result = check marketWorker.run(query);
    return result;
}

# Hands the technical aspect to its worker.
@ai:AgentTool
isolated function techWorkerTool(string query) returns string|error {
    string result = check techWorker.run(query);
    return result;
}

# Hands the legal aspect to its worker.
@ai:AgentTool
isolated function legalWorkerTool(string query) returns string|error {
    string result = check legalWorker.run(query);
    return result;
}
