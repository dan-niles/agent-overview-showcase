import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /hub on httpDefaultListener {
    // Anthropic's routing: a classifier step, then a match on its answer.
    resource function post message(@http:Payload Inbound inbound) returns string|error {
        string category = check classifierAgent.run(string `Classify: ${inbound.text}`, inbound.accountId);
        match category {
            "billing" => {
                string result = check billingAgent.run(inbound.text, inbound.accountId);
                return result;
            }
            "tech" => {
                string result = check techAgent.run(inbound.text, inbound.accountId);
                return result;
            }
            "sales" => {
                string result = check salesAgent.run(inbound.text, inbound.accountId);
                return result;
            }
            _ => {
                string result = check generalAgent.run(inbound.text, inbound.accountId);
                return result;
            }
        }
    }

    // Two branches route to the same agent; one branch hands off to a human and calls no agent.
    resource function post ticket(@http:Payload Inbound inbound) returns string|error {
        if inbound.kind == "refund" {
            string result = check billingAgent.run(inbound.text, inbound.accountId);
            return result;
        } else if inbound.kind == "chargeback" {
            string result = check billingAgent.run(inbound.text, inbound.accountId);
            return result;
        } else if inbound.kind == "legal" {
            return "Handed to the legal team.";
        } else {
            string result = check generalAgent.run(inbound.text, inbound.accountId);
            return result;
        }
    }

    // A match whose guard reads the payload, with a fallthrough that is not an agent.
    resource function post priority(@http:Payload Inbound inbound) returns string|error {
        match inbound.kind {
            var kind if inbound.vip => {
                string result = check salesAgent.run(string `VIP ${kind}: ${inbound.text}`, inbound.accountId);
                return result;
            }
            "tech" => {
                string result = check techAgent.run(inbound.text, inbound.accountId);
                return result;
            }
            _ => {
                return "Queued.";
            }
        }
    }
}
