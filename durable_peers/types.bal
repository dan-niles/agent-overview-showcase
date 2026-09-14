public type NewOrder record {|
    string customer;
    string[] items;
|};

public type ShippingUpdate record {|
    string status;
|};

public type ReleaseDecision record {|
    "RELEASE"|"HOLD" outcome;
|};
