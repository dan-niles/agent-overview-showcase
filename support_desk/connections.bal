import ballerina/http;
import ballerinax/github;

configurable string githubToken = ?;

final github:Client githubClient = check new ({
    auth: {token: githubToken}
});

final http:Client ratesApi = check new ("http://localhost:9092/rates");
