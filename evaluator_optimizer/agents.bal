import ballerina/ai;

final ai:Wso2ModelProvider studioModel = check ai:getDefaultModelProvider();

final ai:Agent generatorAgent = check new (
    systemPrompt = {
        role: string `Generator`,
        instructions: string `You write a translation or a slogan.`
    }, model = studioModel, tools = []
);
final ai:Agent evaluatorAgent = check new (
    systemPrompt = {
        role: string `Evaluator`,
        instructions: string `You score a text from 0 to 100 and say what to fix.`
    }, model = studioModel, tools = []
);
final ai:Agent translatorAgent = check new (
    systemPrompt = {
        role: string `Translator`,
        instructions: string `You translate text.`
    }, model = studioModel, tools = []
);
final ai:Agent qualityAgent = check new (
    systemPrompt = {
        role: string `Quality`,
        instructions: string `You check a translation reads naturally.`
    }, model = studioModel, tools = []
);
