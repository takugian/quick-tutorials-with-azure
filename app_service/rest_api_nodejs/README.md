# rest_api_nodejs

## Pre requirements

- Repository created in Azure Container Registry;

## How to deploy

### Localnpm install

```
npm start
```

#### How to test

- curl http://localhost:3070/
- curl http://localhost:3070/customers

### Docker

```
docker build -t rest_api_nodejs .
docker images
docker run -d -p 3070:3070 --name rest_api_nodejs rest_api_nodejs
```

#### How to test

- curl http://localhost:3070/
- curl http://localhost:3070/customers

### Azure

Credentials configurations
```
az login
```

Login to your container registry
```
docker login {ContainerRegistryName}.azurecr.io
```
	
Push to your registry
```
docker tag rest_api_nodejs qtrestapinodejs.azurecr.io/rest_api_nodejs

docker push qtrestapinodejs.azurecr.io/rest_api_nodejs
```

```
Use terraform to deploy
```

#### How to test

- curl http://{URLFromAppServices}/
- curl http://{URLFromAppServices}/customers