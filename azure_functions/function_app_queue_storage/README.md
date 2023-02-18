# function_app_queue_storage

Creates a Function App with NodeJs as runtime that reads a queue storage.

## Run locally

```
npm install
npm start
```

## Deploy on Azure

```
npm run build
func azure functionapp publish function-app-my-function
```

## Run on Azure

```
https://function-app-my-function.azurewebsites.net/api/my_function?name=Quick Tutorials with Azure
```