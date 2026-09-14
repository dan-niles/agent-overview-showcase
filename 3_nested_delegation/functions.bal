import ballerina/ai;

# Estimates backend API work.
# + feature - the feature to estimate
# + return - an estimate in days
@ai:AgentTool
isolated function estimateApiWork(string feature) returns string {
    return string `${feature}: 3 days of API work`;
}

# Estimates frontend UI work.
# + feature - the feature to estimate
# + return - an estimate in days
@ai:AgentTool
isolated function estimateUiWork(string feature) returns string {
    return string `${feature}: 2 days of UI work`;
}

# Drafts a launch announcement.
# + feature - the feature being launched
# + return - the announcement text
@ai:AgentTool
isolated function draftAnnouncement(string feature) returns string {
    return string `Introducing ${feature}!`;
}

# Delegates to the engineering manager.
# + query - the request
# + return - the answer
@ai:AgentTool
isolated function engineeringManagerAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check engineeringManagerAgent.run(query, context = ctx);
    return result;
}

# Delegates to the marketing manager.
# + query - the request
# + return - the answer
@ai:AgentTool
isolated function marketingManagerAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check marketingManagerAgent.run(query, context = ctx);
    return result;
}

# Delegates to the backend developer.
# + query - the request
# + return - the answer
@ai:AgentTool
isolated function backendDeveloperAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check backendDeveloperAgent.run(query, context = ctx);
    return result;
}

# Delegates to the frontend developer.
# + query - the request
# + return - the answer
@ai:AgentTool
isolated function frontendDeveloperAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check frontendDeveloperAgent.run(query, context = ctx);
    return result;
}

# Delegates to the content writer.
# + query - the request
# + return - the answer
@ai:AgentTool
isolated function contentWriterAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check contentWriterAgent.run(query, context = ctx);
    return result;
}
