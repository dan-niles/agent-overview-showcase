import ballerina/io;

public function main() returns error? {
    string report = check costAgent.run("Report yesterday's cloud cost.", "daily");
    io:println(report);
}
