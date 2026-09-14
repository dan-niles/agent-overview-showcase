import ballerina/ai;

# Collects today's metrics.
# + return - the metrics as text
@ai:AgentTool
isolated function collectMetrics() returns string {
    return "Signups 42, churn 1, open tickets 7.";
}

# Saves a blog draft.
# + title - the draft title
# + body - the draft body
# + return - a confirmation
@ai:AgentTool
isolated function saveDraft(string title, string body) returns string {
    return string `Saved draft "${title}" (${body.length()} chars)`;
}
