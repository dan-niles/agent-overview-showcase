import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /ops on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string answer = check incidentCommanderAgent.run(request.message, sessionId = request.sessionId);
        return {message: answer};
    }
}

service /ops on httpDefaultListener {
    resource function get status(string alertName) returns string|error {
        string result = check triageAgent.run(string `How severe is ${alertName}?`, alertName);
        return result;
    }
}

service /releases on httpDefaultListener {
    resource function post plan(@http:Payload ReleasePlan plan) returns string|error {
        string result = check releaseManagerAgent.run(string `Plan release ${plan.release}: ${plan.changes.toString()}`, plan.release);
        return result;
    }

    resource function post hotfix(@http:Payload Hotfix fix) returns string|error {
        string review = check changeReviewAgent.run(string `Review ${fix.owner}/${fix.repo}#${fix.pullRequest}`, fix.release);
        string deployment = check deployAgent.run(string `Deploy ${fix.release} after this review: ${review}`, fix.release);
        string result = check commsAgent.run(string `Announce the hotfix ${fix.release}: ${deployment}`, fix.release);
        return result;
    }
}

service /onboarding on httpDefaultListener {
    resource function post enroll(@http:Payload NewHire hire) returns string|error {
        string result = check onboardingCoordinatorAgent.run(string `Onboard ${hire.email} starting ${hire.startDate}`, hire.email);
        return result;
    }
}
