import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /pr\-review on httpDefaultListener {
    resource function post .(@http:Payload PullRequest pr) returns ReviewResult|error {
        string sessionId = pr.id.toString();
        fork {
            worker securityWorker returns string|ai:Error {
                string result = check securityReviewAgent.run(string `Review for security issues: ${pr.diff}`, sessionId);
                return result;
            }
            worker styleWorker returns string|ai:Error {
                string result = check styleReviewAgent.run(string `Review for style issues: ${pr.diff}`, sessionId);
                return result;
            }
        }
        record {|string|ai:Error securityWorker; string|ai:Error styleWorker;|} results = wait {securityWorker, styleWorker};
        return {security: check results.securityWorker, style: check results.styleWorker};
    }

    resource function post summary(@http:Payload PullRequest pr) returns string|error {
        future<string|ai:Error> pending = start summaryAgent.run(string `Summarise this pull request: ${pr.title}`, pr.id.toString(), td = string);
        return check wait pending;
    }
}
