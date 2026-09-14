import ballerina/ai;

# Lists the security rules to check.
# + return - the rules
@ai:AgentTool
isolated function listSecurityRules() returns string {
    return "No secrets in code; validate all inputs; use parameterised queries.";
}

# Lists the style rules to check.
# + return - the rules
@ai:AgentTool
isolated function listStyleRules() returns string {
    return "Descriptive names; functions under 40 lines; no commented-out code.";
}
