import ballerina/ai;

final ai:Wso2ModelProvider triageModel = check ai:getDefaultModelProvider();

final ai:Agent triageAgent = check new (
    systemPrompt = {role: string `Triage Agent`, instructions: string `You label a support ticket with a priority and a team.`},
    model = triageModel, tools = [lookupTicketOwner]
);

final ai:Agent escalationAgent = check new (
    systemPrompt = {role: string `Escalation Agent`, instructions: string `You draft an escalation note and end it with RESOLVED once the customer is unblocked.`},
    model = triageModel, tools = [lookupTicketOwner]
);
