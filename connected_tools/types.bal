public type TripRequest record {|
    string travellerId;
    string origin;
    string destination;
    string date;
|};

public type ExpenseClaim record {|
    string travellerId;
    string category;
    decimal amount;
    string currency;
|};
