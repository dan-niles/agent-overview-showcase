import ballerina/http;

final http:Client searchApi = check new ("http://localhost:9701/search");
final http:Client sourceApi = check new ("http://localhost:9702/sources");
