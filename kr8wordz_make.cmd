1. 
kubectl  create -f manifests/etcd-cluster.yaml
2.
kubectl  create -f manifests/etcd-service.yaml
3. 建立这个项目用到的三个service的配置。原来的配置中没有设置nodeport，所以后期的javascript中无法正常使用，我在新的all-services.yaml中把三个service的nodePort都设置为制定的port，puzzle, monitor-scale, kr8sswordz分别为3210+（0,1,2）
kubectl apply -f manifests/all-services.yaml
4.
sudo docker build -t 127.0.0.1:30400/monitor-scale:`git rev-parse --short HEAD` -f applications/monitor-scale/Dockerfile applications/monitor-scale
上面制作monitor-scale的image，这之前需要调整一些文件的内容，比如把一些url按照现在的,ip和nodeport做相应的调整
monitor-scale里面改了applications/monitor-scale/k8s/deplyment.xml的一些内容，如下：
host: monitor-scale.192.168.1.73.xip.io

5.下面两步是为了建立socat-registry, 使得建立的docker image可以加入到本地repository.这两步完成一次即可，不一定每次都要操作
docker build -t socat-registry -f applications/socat/Dockerfile applications/socat
6.
docker stop socat-registry; docker rm socat-registry; docker run -d -e "REG_IP=192.168.1.73" -e "REG_PORT=40400" --name socat-registry -p 40400:5000 socat-registry
7.
docker push 127.0.0.1:30400/monitor-scale:`git rev-parse --short HEAD`
8.查看registry-ui的端口映射信息，可以使用该端口和ip作为url，访问url获取当前local registry的image
kubectl get service registry-ui

9.
kubectl apply -f manifests/monitor-scale-serviceaccount.yaml

10.这步是修改初始的deployment.yaml.我已经建立了一个deployment_custom.yaml.其中除了修改了下面提到的$BUILD_TAG,另外还改了相应的ip地址。所以可以直接运行下面第二条指令。
sed 's#127.0.0.1:30400/monitor-scale:$BUILD_TAG#127.0.0.1:30400/ monitor-scale:'`git rev-parse --short HEAD`'#' applications/monitor-scale/k8s/deployment.yaml | kubectl apply -f -

kubectl apply -f applications/monitor-scale/k8s/deployment_custom.yaml 

11.Wait for the monitor-scale deployment to finish
kubectl rollout status deployment/monitor-scale

12. 执行puzzle相关的操作，包括建立image，加入本地local repository,执行deployment.yaml. 在原有脚本中需要修改image使用的文件，比如软件代码,另外给docker指令前加上sudo。
scripts/puzzle.sh

13. 建立kr8sswords, 需要先修改Javascripts代码中的url为现用的ip+port.
scripts/kr8sswordz-pages.sh
