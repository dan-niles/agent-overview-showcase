import ballerina/ai;

final ai:Wso2ModelProvider deskModel = check ai:getDefaultModelProvider();

final ai:Agent supportSupervisorAgent = check new (
    systemPrompt = {
        role: string `Customer Support Supervisor`,
        instructions: string `You are the front line of customer support. Understand what the customer needs,
then delegate to the right specialist tool and combine their answers into one clear reply.`
    }, model = deskModel, tools = [billingAgentTool, technicalSupportAgentTool, orderAgentTool]
);

final ai:Agent salesSupervisorAgent = check new (
    systemPrompt = {
        role: string `Sales Supervisor`,
        instructions: string `You answer pre-sales questions. Delegate technical questions to the technical
specialist and pricing questions to the quote specialist.`
    }, model = deskModel, tools = [technicalSupportAgentTool, quoteAgentTool]
);

final ai:Agent billingAgent = check new (
    systemPrompt = {
        role: string `Billing Specialist`,
        instructions: string `You resolve billing questions: charges, refunds and subscriptions. Look the account
up before answering and never promise a refund you have not issued.`
    }, model = deskModel, tools = [lookupInvoice, issueRefund]
);

final ai:Agent technicalSupportAgent = check new (
    systemPrompt = {
        role: string `Technical Support`,
        instructions: string `You solve technical problems using the product documentation. Check GitHub for
related issues before answering.`
    }, model = deskModel, tools = [searchKnowledgeBase, findRelatedIssues]
);

final ai:Agent orderAgent = check new (
    systemPrompt = {
        role: string `Order Agent`,
        instructions: string `You handle order status, returns and shipping questions. Look up the order before
answering. Ask the shipping rates specialist for a rate instead of quoting one yourself.`
    }, model = deskModel, tools = [lookupOrder, initiateReturn, shippingRatesAgentTool]
);

final ai:Agent shippingRatesAgent = check new (
    systemPrompt = {
        role: string `Shipping Rates`,
        instructions: string `You quote shipping rates for an order. Call the rates API with the destination
and weight, and return the cheapest and the fastest option.`
    }, model = deskModel, tools = [getRates]
);

final ai:Agent quoteAgent = check new (
    systemPrompt = {
        role: string `Quotes`,
        instructions: string `You prepare price quotes for prospective customers from the price list.`
    }, model = deskModel, tools = [priceList]
);
