import ballerina/http;
import ballerinax/ai.anthropic;

final http:Client ordersApi = check new ("http://localhost:9091/orders");
final anthropic:ModelProvider anthropicModelprovider = check new ("test", "claude-haiku-4-5-20251001", compression = "ALWAYS");
