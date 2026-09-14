import ballerina/ai;

final ai:Wso2ModelProvider travelModel = check ai:getDefaultModelProvider();

final ai:Agent travelConciergeAgent = check new (
    systemPrompt = {
        role: string `Travel Concierge`,
        instructions: string `You plan a trip: find flights and a hotel, reserve a car, check the weather and suggest a route, then estimate the budget.`
    }, model = travelModel, tools = [searchFlights, searchHotels, reserveCar, getWeather, getDirections, estimateBudget]
);

final ai:Agent expenseAgent = check new (
    systemPrompt = {
        role: string `Expense Assistant`,
        instructions: string `You file an expense claim and convert it to the reimbursement currency.`
    }, model = travelModel, tools = [submitExpense, convertCurrency]
);
