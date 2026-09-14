import ballerina/ai;

final ai:Wso2ModelProvider reviewModel = check ai:getDefaultModelProvider();

final ai:Agent securityReviewAgent = check new (
    systemPrompt = {role: string `Security Reviewer`, instructions: string `You review code changes for security problems.`},
    model = reviewModel, tools = [listSecurityRules]
);

final ai:Agent styleReviewAgent = check new (
    systemPrompt = {role: string `Style Reviewer`, instructions: string `You review code changes against the style guide.`},
    model = reviewModel, tools = [listStyleRules]
);

final ai:Agent summaryAgent = check new (
    systemPrompt = {role: string `PR Summariser`, instructions: string `You write a two-sentence summary of a pull request.`},
    model = reviewModel
);
