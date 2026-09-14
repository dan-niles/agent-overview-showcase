import ballerina/io;

// Replays a backlog: the digest agent inside a while loop from the automation.
public function main() returns error? {
    int remaining = 3;
    while remaining > 0 {
        string digest = check digestAgent.run(string `Replay batch ${remaining}`, "replay");
        io:println(digest);
        remaining -= 1;
    }
}
