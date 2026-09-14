import ballerina/ai;
import ballerinax/github;

# Pages the on-call engineer.
@ai:AgentTool
isolated function pageOnCall(string severity) returns string|error {
    json response = check pagerClient->/page.post({severity});
    return response.toJsonString();
}
# Finds the runbook for an alert.
@ai:AgentTool
isolated function lookupRunbook(string alertName) returns string {
    return string `Runbook for ${alertName}: restart the pods, then check the queue depth.`;
}
# Posts an update to the status page.
@ai:AgentTool
isolated function postStatus(string message) returns string|error {
    json response = check statusPageClient->/incidents.post({message});
    return response.toJsonString();
}
# Posts a message to the ops channel.
@ai:AgentTool
isolated function notifySlack(string message) returns string|error {
    _ = check slackClient->/chat\.postMessage.post({channel: "#ops", text: message});
    return "posted";
}
# Creates the postmortem document from every system the incident touched.
@ai:AgentTool
isolated function createPostmortemDoc(string incidentId) returns string|error {
    json pages = check pagerClient->/incidents/[incidentId];
    json status = check statusPageClient->/incidents/[incidentId];
    github:Issue[] issues = check githubClient->/repos/["wso2"]/["ops"]/issues;
    _ = check slackClient->/conversations\.history(channel = "#incidents");
    json doc = check docsClient->/postmortems.post({incidentId, pages, status, issueCount: issues.length()});
    return doc.toJsonString();
}
# Summarises a pull request's diff.
@ai:AgentTool
isolated function diffSummary(string owner, string repo, int number) returns string|error {
    github:PullRequest? pr = check githubClient->/repos/[owner]/[repo]/pulls/[number];
    return pr is () ? "Pull request not found" : string `${pr.title}`;
}
# Runs the deployment pipeline for a release.
@ai:AgentTool
isolated function runPipeline(string release) returns string|error {
    json run = check ciClient->/pipelines/deploy.post({release});
    return run.toJsonString();
}
# Rolls a release back.
@ai:AgentTool
isolated function rollbackRelease(string release) returns string|error {
    json run = check ciClient->/pipelines/revert.post({release});
    return run.toJsonString();
}
# Grants the standard accounts to a new hire.
@ai:AgentTool
isolated function grantAccess(string email) returns string|error {
    json result = check hrClient->/access.post({email});
    return result.toJsonString();
}
# Orders a laptop for a new hire.
@ai:AgentTool
isolated function orderLaptop(string email, string model) returns string|error {
    json purchase = check procurementClient->/orders.post({email, model});
    return purchase.toJsonString();
}
# Schedules the onboarding sessions.
@ai:AgentTool
isolated function scheduleTraining(string email, string startDate) returns string|error {
    json slot = check calendarClient->/events.post({email, startDate});
    return slot.toJsonString();
}
# Exports the audit log for a period.
@ai:AgentTool
isolated function exportAuditLog(string fromDate, string toDate) returns string {
    return string `Audit log ${fromDate}..${toDate} exported.`;
}
# Gets the cloud cost for a pipeline run or a day.
@ai:AgentTool
isolated function getDailyCost(string reference) returns string|error {
    json cost = check cloudBillingClient->/costs/[reference];
    return cost.toJsonString();
}
# Hands an incident to the triage specialist.
@ai:AgentTool
isolated function triageAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check triageAgent.run(query, context = ctx);
    return result;
}
# Hands an announcement to the communications specialist.
@ai:AgentTool
isolated function commsAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check commsAgent.run(query, context = ctx);
    return result;
}
# Hands a closed incident to the postmortem writer.
@ai:AgentTool
isolated function postmortemAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check postmortemAgent.run(query, context = ctx);
    return result;
}
# Hands a change to the reviewer.
@ai:AgentTool
isolated function changeReviewAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check changeReviewAgent.run(query, context = ctx);
    return result;
}
# Hands a release to the deployer.
@ai:AgentTool
isolated function deployAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check deployAgent.run(query, context = ctx);
    return result;
}
# Hands the access request to the access specialist.
@ai:AgentTool
isolated function accessAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check accessAgent.run(query, context = ctx);
    return result;
}
# Hands the hardware request to the hardware specialist.
@ai:AgentTool
isolated function hardwareAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check hardwareAgent.run(query, context = ctx);
    return result;
}
# Hands the training plan to the training specialist.
@ai:AgentTool
isolated function trainingAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check trainingAgent.run(query, context = ctx);
    return result;
}
# Asks the cost specialist what a run cost.
@ai:AgentTool
isolated function costAgentTool(ai:Context ctx, string query) returns string|error {
    string result = check costAgent.run(query, context = ctx);
    return result;
}
