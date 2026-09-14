import ballerina/http;
import ballerinax/github;
import ballerinax/slack;

configurable string githubToken = ?;
configurable string slackToken = ?;

final http:Client pagerClient = check new ("http://localhost:9101/pager");
final http:Client statusPageClient = check new ("http://localhost:9102/status");
final http:Client ciClient = check new ("http://localhost:9103/ci");
final http:Client docsClient = check new ("http://localhost:9104/docs");
final http:Client hrClient = check new ("http://localhost:9105/hr");
final http:Client procurementClient = check new ("http://localhost:9106/procurement");
final http:Client calendarClient = check new ("http://localhost:9107/calendar");
final http:Client cloudBillingClient = check new ("http://localhost:9108/billing");
final github:Client githubClient = check new ({auth: {token: githubToken}});
final slack:Client slackClient = check new ({auth: {token: slackToken}});
