#!/bin/bash

#Retrieve the latest git commit hash
BUILD_TAG=`git rev-parse --short HEAD`

#Build the docker image
sudo docker build -t 127.0.0.1:30400/kr8sswordz:$BUILD_TAG -f applications/kr8sswordz-pages/Dockerfile applications/kr8sswordz-pages

#Setup the proxy for the registry
#sudo docker stop socat-registry; sudo docker rm socat-registry; sudo docker run -d -e "REG_IP=192.168.1.73" -e "REG_PORT=40400" --name socat-registry -p 40400:5000 socat-registry

echo "5 second sleep to make sure the registry is ready"
sleep 5;

#Push the images
sudo docker push 127.0.0.1:30400/kr8sswordz:$BUILD_TAG

#Stop the registry proxy
#sudo docker stop socat-registry

# Create the deployment and service for the front end aka kr8sswordz
#sed 's#127.0.0.1:30400/kr8sswordz:$BUILD_TAG#127.0.0.1:30400/kr8sswordz:'$BUILD_TAG'#' applications/kr8sswordz-pages/k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f applications/kr8sswordz-pages/k8s/deployment_custom.yaml
