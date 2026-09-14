import ballerina/io;

public function main() returns error? {
    string digest = check digestAgent.run("Prepare today's digest.", "daily");
    io:println(digest);
}
