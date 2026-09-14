import ballerina/ai;
import ballerina/workflow;

final ai:Wso2ModelProvider deskModel = check ai:getDefaultModelProvider();

final ai:Agent stockAgent = check new (
    systemPrompt = {role: "Stock desk", instructions: "Answer whether an item is in stock."},
    model = deskModel
);

final workflow:DurableAgent paymentAgent = check new ({
    systemPrompt: {role: "Payment desk", instructions: "Charge the card once finance releases the payment."},
    model: deskModel,
    activities: [chargeCard],
    humanTasks: {
        release: {userRoles: "FINANCE", resultType: ReleaseDecision, title: "Release payment"}
    }
});

final workflow:DurableAgent orderAgent = check new ({
    systemPrompt: {role: "Order desk", instructions: "Take the order, reserve the items, hand payment to the payment desk, then wait for shipping."},
    model: deskModel,
    activities: [reserveItems],
    tools: [askStock],
    events: {shipping: {request: ShippingUpdate}},
    peers: [{agent: paymentAgent, name: "pay", requiresApproval: true, userRoles: "FINANCE"}]
});
