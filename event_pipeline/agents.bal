import ballerina/ai;

final ai:Wso2ModelProvider streamModel = check ai:getDefaultModelProvider();

final ai:Agent enrichAgent = check new (
    systemPrompt = {
        role: string `Enricher`,
        instructions: string `You enrich an incoming event with context.`
    }, model = streamModel, tools = [lookupCustomer]
);
final ai:Agent escalateAgent = check new (
    systemPrompt = {
        role: string `Escalation`,
        instructions: string `You escalate a high-priority event.`
    }, model = streamModel, tools = [pageOnCall]
);
final ai:Agent archiveAgent = check new (
    systemPrompt = {
        role: string `Archive`,
        instructions: string `You archive a low-priority event.`
    }, model = streamModel, tools = []
);
final ai:Agent digestAgent = check new (
    systemPrompt = {
        role: string `Digest`,
        instructions: string `You summarise a batch of events.`
    }, model = streamModel, tools = []
);
