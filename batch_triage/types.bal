public type Ticket record {|
    string id;
    string text;
|};

public type TicketBatch record {|
    Ticket[] tickets;
|};
