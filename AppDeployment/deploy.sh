#!/bin/bash

###
# Replace environment variables
##
replace_environment_variables(){
	source ./replace_env.sh .deploymentyamlfilefolder ./env.txt
}

###
# Build and push docker image to local registry
###
build_and_push_docker_image(){
  docker build -t localhost:55555/app:1.0.0 -f ../../src/Services/App/app/Dockerfile ../../
  docker push localhost:55555/app:1.0.0
}

###
# Deploy k8s objects
###

deploy_app_files(){
  kubectl apply -f ./api/secret.yml
  kubectl apply -f ./api/service.yml
  kubectl apply -f ./api/ingress.yml
  kubectl apply -f ./api/deployment.yml
}

replace_environment_variables
build_and_push_docker_image
deploy_app_files