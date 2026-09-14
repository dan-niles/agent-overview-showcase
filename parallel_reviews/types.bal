public type PullRequest record {|
    int id;
    string title;
    string diff;
|};

public type ReviewResult record {|
    string security;
    string style;
|};
