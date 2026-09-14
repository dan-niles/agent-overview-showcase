import ballerina/workflow;

@workflow:Activity
function fileClaim(decimal amount, string description) returns string|error {
    return string `CLM-${amount}`;
}

@workflow:Activity
function validateClaim(string claimId, decimal amount) returns string|error {
    boolean billRequired = amount > 1000d;
    boolean managerApprovalRequired = amount > 3000d;
    map<json> verdict = {claimId, billRequired, managerApprovalRequired};
    return verdict.toJsonString();
}

@workflow:Activity
function notifyUser(string username, string title, string body) returns string|error {
    json posted = check notifications->post("/notifications", {user: username, title, body});
    return posted.toJsonString();
}

@workflow:Activity
function executePayment(string claimId, decimal payout) returns string|error {
    return "PAY-" + claimId;
}
