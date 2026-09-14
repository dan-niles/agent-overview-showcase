import ballerina/ai;

final ai:Agent faqAgent = check new (
    systemPrompt = {
        role: string `Product FAQ Agent`,
        instructions: string `You answer questions about our products with the searchDocs tool.
When a customer asks about an order, look it up with lookupOrderStatus before answering. Keep answers short.`
    }, model = check ai:getDefaultModelProvider(), tools = [searchDocs, lookupOrderStatus]
);
