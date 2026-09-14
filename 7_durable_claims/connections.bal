import ballerina/http;

final http:Client notifications = check new ("http://localhost:9092");
