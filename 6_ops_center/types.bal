public type ReleasePlan record {|
    string release;
    string[] changes;
|};

public type Hotfix record {|
    string release;
    string owner;
    string repo;
    int pullRequest;
|};

public type NewHire record {|
    string email;
    string startDate;
|};
