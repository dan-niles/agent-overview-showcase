import ballerina/ai;

final ai:Wso2ModelProvider triageModel = check ai:getDefaultModelProvider();

final ai:Agent triageAgent = check new (
    systemPrompt = {role: string `Triage Agent`, instructions: string `You label a support ticket with a priority and a team. Check GitHub for related issues before deciding.`},
    model = triageModel, tools = [lookupTicketOwner, findRelatedIssues]
);

final ai:Agent escalationAgent = check new (
    systemPrompt = {role: string `Escalation Agent`, instructions: string `You draft an escalation note, post it to the on-call channel, and end it with RESOLVED once the customer is unblocked.`},
    model = triageModel, tools = [lookupTicketOwner, notifyOnCall]
);
