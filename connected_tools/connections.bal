import ballerina/http;

final http:Client flightsApi = check new ("http://localhost:9901/flights");
final http:Client hotelsApi = check new ("http://localhost:9902/hotels");
final http:Client carRentalApi = check new ("http://localhost:9903/cars");
final http:Client weatherApi = check new ("http://localhost:9904/weather");
final http:Client mapsApi = check new ("http://localhost:9905/maps");
final http:Client expenseApi = check new ("http://localhost:9906/expenses");
final http:Client currencyApi = check new ("http://localhost:9907/currency");
