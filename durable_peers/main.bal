import ballerina/http;

service /order\-desk on new http:Listener(8081) {
    resource function post orders(NewOrder payload) returns string|error {
        string orderId = check orderAgent.run(string `customer=${payload.customer}`, payload.toJson());
        return orderId;
    }

    resource function post orders/[string id]/events(ShippingUpdate update) returns http:Accepted|error {
        _ = check orderAgent.sendData(id, "shipping", update);
        return http:ACCEPTED;
    }
}
