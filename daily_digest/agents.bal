import ballerina/ai;

final ai:Wso2ModelProvider digestModel = check ai:getDefaultModelProvider();

final ai:Agent digestAgent = check new (
    systemPrompt = {role: string `Daily Digest`, instructions: string `You compile the day's metrics into a short digest.`},
    model = digestModel, tools = [collectMetrics]
);

final ai:Agent draftAgent = check new (
    systemPrompt = {role: string `Draft Writer`, instructions: string `You turn a digest into a blog draft.`},
    model = digestModel, tools = [saveDraft]
);
