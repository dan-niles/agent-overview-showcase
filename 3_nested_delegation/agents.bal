import ballerina/ai;

final ai:Wso2ModelProvider companyModel = check ai:getDefaultModelProvider();

final ai:Agent ceoAgent = check new (
    systemPrompt = {role: string `Chief Executive`, instructions: string `You turn a business goal into work. Delegate engineering questions to the engineering manager and marketing questions to the marketing manager, then summarise the plan.`},
    model = companyModel, tools = [engineeringManagerAgentTool, marketingManagerAgentTool]
);

final ai:Agent engineeringManagerAgent = check new (
    systemPrompt = {role: string `Engineering Manager`, instructions: string `You break engineering work into backend and frontend tasks and delegate each to the right developer.`},
    model = companyModel, tools = [backendDeveloperAgentTool, frontendDeveloperAgentTool]
);

final ai:Agent marketingManagerAgent = check new (
    systemPrompt = {role: string `Marketing Manager`, instructions: string `You plan launches and delegate copy to the content writer.`},
    model = companyModel, tools = [contentWriterAgentTool]
);

final ai:Agent backendDeveloperAgent = check new (
    systemPrompt = {role: string `Backend Developer`, instructions: string `You estimate and describe API work.`},
    model = companyModel, tools = [estimateApiWork]
);

final ai:Agent frontendDeveloperAgent = check new (
    systemPrompt = {role: string `Frontend Developer`, instructions: string `You estimate and describe UI work.`},
    model = companyModel, tools = [estimateUiWork]
);

final ai:Agent contentWriterAgent = check new (
    systemPrompt = {role: string `Content Writer`, instructions: string `You draft launch announcements.`},
    model = companyModel, tools = [draftAnnouncement]
);
