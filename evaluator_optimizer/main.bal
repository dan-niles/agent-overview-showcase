import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

function scoreOf(string verdict) returns int {
    return verdict.startsWith("9") ? 95 : 60;
}

service /studio on httpDefaultListener {
    // Evaluator-optimizer: generate, score, loop until the score passes or attempts run out.
    resource function post slogan(@http:Payload Brief brief) returns string|error {
        string draft = "";
        int score = 0;
        int attempts = 0;
        while score < 90 && attempts < 3 {
            draft = check generatorAgent.run(string `Slogan for ${brief.product}, attempt ${attempts}`, brief.id);
            string verdict = check evaluatorAgent.run(string `Score: ${draft}`, brief.id);
            score = scoreOf(verdict);
            attempts += 1;
        }
        return draft;
    }

    // A loop over languages with a quality gate inside, retried once on failure.
    resource function post translate(@http:Payload Brief brief) returns string|error {
        string[] results = [];
        foreach string language in brief.languages {
            string translated = check translatorAgent.run(string `Translate to ${language}: ${brief.product}`, brief.id);
            string verdict = check qualityAgent.run(string `Natural? ${translated}`, brief.id);
            if scoreOf(verdict) < 90 {
                translated = check translatorAgent.run(string `Retry to ${language}: ${brief.product}`, brief.id);
            }
            results.push(translated);
        }
        return results.toString();
    }
}
