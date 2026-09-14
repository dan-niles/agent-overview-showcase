import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /travel on httpDefaultListener {
    resource function post plan(@http:Payload TripRequest trip) returns string|error {
        string result = check travelConciergeAgent.run(string `Plan a trip from ${trip.origin} to ${trip.destination} on ${trip.date}.`, trip.travellerId);
        return result;
    }
}

service /expenses on httpDefaultListener {
    resource function post file(@http:Payload ExpenseClaim claim) returns string|error {
        string result = check expenseAgent.run(string `File ${claim.amount} ${claim.currency} for ${claim.category}.`, claim.travellerId);
        return result;
    }
}
