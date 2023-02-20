# function_app_service_bus_queue

Creates a Function App with NodeJS as runtime that writes to and reads from a service bus queue.

## Run locally

```
npm install
npm start
```

## Deploy on Azure

```
npm run build
func azure functionapp publish {function_name}
```