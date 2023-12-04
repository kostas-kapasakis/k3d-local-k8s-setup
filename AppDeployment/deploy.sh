#!/bin/bash

###
# Replace environment variables
##
source ./replace_env.sh .deploymentyamlfilefolder ./env.txt

###
# Build and push docker image to local registry
###

docker build -t localhost:55555/app:1.0.0 -f ../../src/Services/App/app/Dockerfile ../../
docker push localhost:55555/app:1.0.0

# either create a new random number and add it as a image version while tagging 
# then need to replace the image version in the env.txt

###
# Deploy k8s objects
###

kubectl apply -f ./secret.yml
kubectl apply -f ./service.yml
kubectl apply -f ./ingress.yml
kubectl apply -f ./deployment.yml
