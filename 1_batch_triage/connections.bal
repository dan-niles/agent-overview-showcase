import ballerinax/github;
import ballerinax/slack;

configurable string githubToken = ?;
configurable string slackToken = ?;

final github:Client githubClient = check new ({auth: {token: githubToken}});
final slack:Client slackClient = check new ({auth: {token: slackToken}});
