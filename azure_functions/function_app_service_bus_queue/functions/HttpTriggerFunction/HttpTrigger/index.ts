import { AzureFunction, Context, HttpRequest } from "@azure/functions"

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
    context.log('HTTP trigger function processed a request');
    const message = (req.query.message || (req.body && req.body.message));
    // const responseMessage = name
    // ? "Hello, " + name + ". This HTTP triggered function executed successfully."
    // : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

    // context.res = {
    // status: 200, /* Defaults to 200 */
    // body: responseMessage
    // };

    context.bindings.res = message;

};

export default httpTrigger;