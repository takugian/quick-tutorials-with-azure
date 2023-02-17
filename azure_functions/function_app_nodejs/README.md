# function_app_nodejs

Creates a Function App with NodeJs as runtime.

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