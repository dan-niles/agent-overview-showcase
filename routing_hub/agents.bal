import ballerina/ai;

final ai:Wso2ModelProvider hubModel = check ai:getDefaultModelProvider();

final ai:Agent classifierAgent = check new (
    systemPrompt = {
        role: string `Classifier`,
        instructions: string `You classify a customer message into billing, tech, sales or other.`
    }, model = hubModel, tools = []
);
final ai:Agent billingAgent = check new (
    systemPrompt = {
        role: string `Billing`,
        instructions: string `You handle billing.`
    }, model = hubModel, tools = [lookupInvoice]
);
final ai:Agent techAgent = check new (
    systemPrompt = {
        role: string `Tech`,
        instructions: string `You handle technical problems.`
    }, model = hubModel, tools = []
);
final ai:Agent salesAgent = check new (
    systemPrompt = {
        role: string `Sales`,
        instructions: string `You handle sales questions.`
    }, model = hubModel, tools = []
);
final ai:Agent generalAgent = check new (
    systemPrompt = {
        role: string `General`,
        instructions: string `You handle everything else.`
    }, model = hubModel, tools = []
);
