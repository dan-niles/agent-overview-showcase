import ballerina/ai;

# Searches flights between two cities.
# + origin - departure city
# + destination - arrival city
# + date - travel date
# + return - matching flights
@ai:AgentTool
isolated function searchFlights(string origin, string destination, string date) returns string|error {
    json result = check flightsApi->/search.post({origin, destination, date});
    return result.toJsonString();
}

# Searches hotels in a city.
# + city - the city to search
# + checkIn - check-in date
# + checkOut - check-out date
# + return - matching hotels
@ai:AgentTool
isolated function searchHotels(string city, string checkIn, string checkOut) returns string|error {
    json result = check hotelsApi->/search.post({city, checkIn, checkOut});
    return result.toJsonString();
}

# Reserves a rental car.
# + city - pickup city
# + pickupDate - pickup date
# + return - the reservation reference
@ai:AgentTool
isolated function reserveCar(string city, string pickupDate) returns string|error {
    json result = check carRentalApi->/reserve.post({city, pickupDate});
    return result.toJsonString();
}

# Gets the weather forecast for a city.
# + city - the city
# + date - the date
# + return - the forecast
@ai:AgentTool
isolated function getWeather(string city, string date) returns string|error {
    json result = check weatherApi->/forecast.post({city, date});
    return result.toJsonString();
}

# Gets directions between two points.
# + origin - the starting point
# + destination - the destination
# + return - the route
@ai:AgentTool
isolated function getDirections(string origin, string destination) returns string|error {
    json result = check mapsApi->/directions.post({origin, destination});
    return result.toJsonString();
}

# Estimates a trip's total budget.
# + flightCost - the flight cost
# + hotelCost - the hotel cost
# + return - the estimate
@ai:AgentTool
isolated function estimateBudget(string flightCost, string hotelCost) returns string {
    return string `Estimated total: ${flightCost} + ${hotelCost} plus incidentals.`;
}

# Files an expense claim.
# + category - the expense category
# + amount - the amount spent
# + return - the claim reference
@ai:AgentTool
isolated function submitExpense(string category, decimal amount) returns string|error {
    json result = check expenseApi->/claims.post({category, amount});
    return result.toJsonString();
}

# Converts an amount between currencies.
# + amount - the amount to convert
# + 'from - the source currency
# + to - the target currency
# + return - the converted amount
@ai:AgentTool
isolated function convertCurrency(decimal amount, string 'from, string to) returns string|error {
    json result = check currencyApi->/convert.post({amount, 'from, to});
    return result.toJsonString();
}
