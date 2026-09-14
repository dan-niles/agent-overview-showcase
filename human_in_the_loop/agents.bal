import ballerina/ai;

final ai:Wso2ModelProvider deskModel = check ai:getDefaultModelProvider();

final ai:Agent makerAgent = check new (
    systemPrompt = {
        role: string `Maker`,
        instructions: string `You draft a customer refund decision.`
    }, model = deskModel, tools = [lookupOrder]
);
final ai:Agent checkerAgent = check new (
    systemPrompt = {
        role: string `Checker`,
        instructions: string `You review the maker's decision.`
    }, model = deskModel, tools = []
);
final ai:Agent executorAgent = check new (
    systemPrompt = {
        role: string `Executor`,
        instructions: string `You carry out an approved decision.`
    }, model = deskModel, tools = [issueRefund]
);
final ai:Agent notifyAgent = check new (
    systemPrompt = {
        role: string `Notifier`,
        instructions: string `You tell the customer what was decided.`
    }, model = deskModel, tools = []
);
