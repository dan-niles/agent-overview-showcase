import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /inventory on httpDefaultListener {
    resource function post ask(@http:Payload StockQuestion question) returns string|error {
        string result = check stockAgent.run(question.question, question.sku);
        return result;
    }

    resource function post reorder(@http:Payload StockQuestion question) returns string|error {
        string result = check supplierAgent.run(string `Reorder ${question.sku}`, question.sku);
        return result;
    }
}
