import ballerina/ai;

final ai:Wso2ModelProvider chainModel = check ai:getDefaultModelProvider();

final ai:Agent researchAgent = check new (
    systemPrompt = {role: string `Researcher`, instructions: string `You gather key facts about a topic.`},
    model = chainModel, tools = []
);

final ai:Agent draftAgent = check new (
    systemPrompt = {role: string `Drafter`, instructions: string `You write a short article from research notes.`},
    model = chainModel, tools = []
);

final ai:Agent editAgent = check new (
    systemPrompt = {role: string `Editor`, instructions: string `You tighten an article for clarity and tone.`},
    model = chainModel, tools = []
);
