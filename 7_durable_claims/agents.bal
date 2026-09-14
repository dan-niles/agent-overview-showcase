import ballerina/ai;
import ballerina/workflow;

final ai:Wso2ModelProvider claimModel = check ai:getDefaultModelProvider();

final workflow:DurableAgent claimAgent = check new ({
    systemPrompt: {
        role: "Smart Claim assistant",
        instructions: string `You run one user's insurance claim case end to end. Gather what happened and the amount,
file the claim, validate it, ask the manager to sign off when required, then release the payment.`
    },
    model: claimModel,
    maxIter: 24,
    activities: [
        fileClaim,
        {activity: validateClaim, description: "Apply the pre-approval rules."},
        notifyUser,
        {activity: executePayment, requiresApproval: true, userRoles: "ACCOUNTANT",
            description: "Release the payment. Gated on an accountant."}
    ],
    events: {chat: {request: string, response: string, cardinality: workflow:MULTI_EVENT}},
    humanTasks: {
        managerApproval: {userRoles: "MANAGER", resultType: SignoffDecision, title: "Manager sign-off"}
    }
});
