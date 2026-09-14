import ballerinax/kafka;
import ballerinax/metrics.logs as _;

import wso2/icp.runtime.bridge as _;

listener kafka:Listener eventsIn = new (kafka:DEFAULT_URL, {groupId: "pipeline", topics: ["events"]});
listener kafka:Listener batchesIn = new (kafka:DEFAULT_URL, {groupId: "pipeline", topics: ["batches"]});

// Agents as stream processors: one event in, enrich, then route by priority.
service on eventsIn {
    remote function onConsumerRecord(kafka:Caller caller, kafka:AnydataConsumerRecord[] records) returns error? {
        foreach kafka:AnydataConsumerRecord rec in records {
            string enriched = check enrichAgent.run(string `Enrich: ${rec.value.toString()}`, "events");
            if enriched.includes("high") {
                _ = check escalateAgent.run(enriched, "events", td = string);
            } else {
                _ = check archiveAgent.run(enriched, "events", td = string);
            }
        }
    }
}

// A second consumer digests whole batches.
service on batchesIn {
    remote function onConsumerRecord(kafka:Caller caller, kafka:AnydataConsumerRecord[] records) returns error? {
        _ = check digestAgent.run(string `Digest ${records.length()} events`, "batches", td = string);
    }
}
