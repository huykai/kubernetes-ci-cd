docker stop socat-registry; docker rm socat-registry; 
docker run -d -e "REG_IP=192.168.1.73" -e "REG_PORT=40400" --name socat-registry -p 40400:5000 socat-registry
