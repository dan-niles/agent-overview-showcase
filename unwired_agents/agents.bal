import ballerina/ai;

final ai:Agent supportAgent = check new (
    systemPrompt = {role: string `Customer Support`, instructions: string `You answer customer questions.`},
    model = check ai:getDefaultModelProvider(), tools = [lookupAccount]
);

final ai:Agent salesAgent = check new (
    systemPrompt = {role: string `Sales Assistant`, instructions: string `You answer pre-sales questions.`},
    model = check ai:getDefaultModelProvider(), tools = [lookupAccount]
);
