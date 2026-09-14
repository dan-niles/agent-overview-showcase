import ballerina/ai;

final ai:Wso2ModelProvider opsModel = check ai:getDefaultModelProvider();

final ai:Agent incidentCommanderAgent = check new (
    systemPrompt = {
        role: string `Incident Commander`,
        instructions: string `You run incidents: triage first, keep the status page current, and open a postmortem when the incident closes.`
    }, model = opsModel, tools = [triageAgentTool, commsAgentTool, postmortemAgentTool]
);
final ai:Agent releaseManagerAgent = check new (
    systemPrompt = {
        role: string `Release Manager`,
        instructions: string `You plan releases: get every change reviewed, deploy through the pipeline, and announce the result.`
    }, model = opsModel, tools = [changeReviewAgentTool, deployAgentTool, commsAgentTool]
);
final ai:Agent onboardingCoordinatorAgent = check new (
    systemPrompt = {
        role: string `Onboarding Coordinator`,
        instructions: string `You onboard new hires: access, hardware, then training, in that order.`
    }, model = opsModel, tools = [accessAgentTool, hardwareAgentTool, trainingAgentTool]
);
final ai:Agent triageAgent = check new (
    systemPrompt = {
        role: string `Triage`,
        instructions: string `You classify an incident's severity, page the on-call engineer and find the matching runbook.`
    }, model = opsModel, tools = [pageOnCall, lookupRunbook]
);
final ai:Agent commsAgent = check new (
    systemPrompt = {
        role: string `Communications`,
        instructions: string `You post incident and release updates to the status page and to Slack.`
    }, model = opsModel, tools = [postStatus, notifySlack]
);
final ai:Agent postmortemAgent = check new (
    systemPrompt = {
        role: string `Postmortem Writer`,
        instructions: string `You write the postmortem: collect the timeline from every system and file the document.`
    }, model = opsModel, tools = [createPostmortemDoc]
);
final ai:Agent changeReviewAgent = check new (
    systemPrompt = {
        role: string `Change Reviewer`,
        instructions: string `You summarise the diff of a change and flag risky files.`
    }, model = opsModel, tools = [diffSummary]
);
final ai:Agent deployAgent = check new (
    systemPrompt = {
        role: string `Deployer`,
        instructions: string `You run the deployment pipeline, roll back on failure and ask the cost specialist for the run's cost.`
    }, model = opsModel, tools = [runPipeline, rollbackRelease, costAgentTool]
);
final ai:Agent accessAgent = check new (
    systemPrompt = {
        role: string `Access`,
        instructions: string `You grant the accounts a new hire needs.`
    }, model = opsModel, tools = [grantAccess]
);
final ai:Agent hardwareAgent = check new (
    systemPrompt = {
        role: string `Hardware`,
        instructions: string `You order the laptop and peripherals for a new hire.`
    }, model = opsModel, tools = [orderLaptop]
);
final ai:Agent trainingAgent = check new (
    systemPrompt = {
        role: string `Training`,
        instructions: string `You schedule the onboarding training sessions.`
    }, model = opsModel, tools = [scheduleTraining]
);
final ai:Agent auditAgent = check new (
    systemPrompt = {
        role: string `Audit`,
        instructions: string `You export the audit log for a period. Nothing calls you yet.`
    }, model = opsModel, tools = [exportAuditLog]
);
final ai:Agent costAgent = check new (
    systemPrompt = {
        role: string `Cloud Cost`,
        instructions: string `You report the cloud cost of a pipeline run or of yesterday's usage.`
    }, model = opsModel, tools = [getDailyCost]
);
