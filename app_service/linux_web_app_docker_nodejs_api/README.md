# linux_web_app_docker_nodejs_api

Creates a Linux Web App to deploy a REST NodeJS API using Docker.

Tip: an example of API can be found in https://github.com/takugian/rest_nodejs_api.

## Pre requirements

- Repository created in Azure Container Registry;

## How to deploy

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
docker tag rest_api_nodejs {ContainerRegistryName}.azurecr.io/rest_api_nodejs

docker push {ContainerRegistryName}.azurecr.io/rest_api_nodejs
```

```
Use terraform to deploy
```

#### How to test

- curl http://{URLFromAppServices}/
- curl http://{URLFromAppServices}/customers