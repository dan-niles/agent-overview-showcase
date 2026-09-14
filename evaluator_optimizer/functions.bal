import ballerina/ai;

# Asks the generator for a small fix.
@ai:AgentTool
isolated function generatorAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check generatorAgent.run(query, context = ctx);
    return result;
}
