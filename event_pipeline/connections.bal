import ballerina/http;

final http:Client crmApi = check new ("http://localhost:9801/crm");
final http:Client pagerApi = check new ("http://localhost:9802/pager");
