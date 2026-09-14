public type SignoffDecision record {|
    "APPROVE"|"REQUEST_BILL"|"REJECT" outcome;
    string comment?;
|};

public type NewConversation record {|
    string username;
|};

public type ChatMessage record {|
    string message;
|};

public type CaseSubmission record {|
    string conversationId;
    string documentUrl;
|};
