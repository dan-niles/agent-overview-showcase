import ballerina/ai;

final ai:Wso2ModelProvider labModel = check ai:getDefaultModelProvider();

final ai:Agent orchestratorAgent = check new (
    systemPrompt = {
        role: string `Orchestrator`,
        instructions: string `You break a research question into aspects and hand each to a worker, then return their findings.`
    }, model = labModel, tools = [marketWorkerTool, techWorkerTool, legalWorkerTool]
);
final ai:Agent synthesizerAgent = check new (
    systemPrompt = {
        role: string `Synthesizer`,
        instructions: string `You write one report from the workers' findings.`
    }, model = labModel, tools = []
);
final ai:Agent citationAgent = check new (
    systemPrompt = {
        role: string `Citations`,
        instructions: string `You verify that a source supports a claim.`
    }, model = labModel, tools = [fetchSource]
);

final ResearchWorker marketWorker = check new (labModel, "market size and competitors");
final ResearchWorker techWorker = check new (labModel, "technical feasibility");
final ResearchWorker legalWorker = check new (labModel, "regulation and compliance");
