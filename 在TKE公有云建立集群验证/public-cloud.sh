

# 在TKE公有云上部署验证submariner


rm -rf broker-info.subm

yq -i eval \
'.clusters[].cluster.server |= sub("10.0.0.109", "43.131.64.7") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
$HOME/.kube/config


# 查看并修改master节点配置文件
vi $HOME/.kube/config

# 查看broker-info.subm 其中base64是一种编码方式，-d表示decode
cat broker-info.subm | base64 -d

# 查看节点
kubectl get nodes


# 把其他node隔离，cordon意思是封锁
kubectl cordon 10.0.0.105
kubectl cordon 10.0.0.77


# 把其中三个节点标记为submariner的网关未来部署的节点（这里只需要写一个，因为其他的node被禁用了）
# kubectl label node <node节点的名字> submariner.io/gateway=true
kubectl label node 10.0.0.144 submariner.io/gateway=true


# 默认情况下，出于安全原因，集群不会在control-plane节点上调度pod。如果非要在control-plane节点上调度pod，
# 例如为单机Kubernetes集群，运行下面指令（把所有节点标记为污点），
# 参见网页链接https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
kubectl taint nodes --all node-role.kubernetes.io/master-


# 部署submariner
subctl deploy-broker

# 把broker-info.subm文件传给cluster-b
scp  broker-info.subm 43.128.115.112:/root


# cluster-a以cluster-a的名义加入broker
subctl join broker-info.subm --clusterid cluster-a --natt=true


# 查看当前submariner的gateway是否安装在多个节点上
kubectl get ds -n submariner-operator


# 获取当前运行的所有cluster的信息（cluster-a上执行该指令），看看其他的cluster有没有加入进来
kubectl get clusters.submariner.io  -A -w


# 如果你的cluster-a没安装tmp-shell（执行这条指令可能会卡住大概10秒）
kubectl -n default  run tmp-shell --rm -i \
--tty --image quay.io/submariner/nettest \
-- /bin/bash


# 在cluster-a上检查能否连接上cluster-b的nginx这个pod
ping <cluster-b显示的nginx的IP>

curl nginx.default.svc.clusterset.local
	




	
	
# cluster-b需要执行的命令

# 删除已经安装的nginx节点
kubectl delete pod <nginx的pod名字>
# 删除部署nginx的deployment
kubectl delete deployment nginx	
# 删除nginx的service
kubectl delete svc nginx
	

# 查看broker-info.subm 其中base64是一种编码方式，-d表示decode
cat broker-info.subm | base64 -d


# 查看节点
kubectl get nodes


# 把其他node隔离
kubectl cordon 10.0.1.18
kubectl cordon 10.0.1.7


# 把其中一个节点标记为submariner的网关未来部署的节点*（写一个节点就可以了，因为其他节点都被cordon了）	
kubectl label node 10.0.1.113 submariner.io/gateway=true
kubectl label node 10.0.1.125 submariner.io/gateway=true
kubectl label node 10.0.1.66  submariner.io/gateway=true


# 默认情况下，出于安全原因，集群不会在control-plane节点上调度pod。如果非要在control-plane节点上调度pod
kubectl taint nodes --all node-role.kubernetes.io/master-


# cluster-b以cluster-b的名义加入broker
subctl join broker-info.subm --clusterid cluster-b --natt=true

	
# 先创建一个deployment对象，对象的名字叫做nginx，然后这个deployment对象运行nginx镜像
kubectl create deployment nginx --image=nginx

# 为deployment对象的nginx创建service，并通过Service的80端口转发至容器的80端口上。
kubectl expose deployment nginx --port=80

#使用subctl创建ServiceExport对象，使service可见，使得submariner中的其他集群可以发现这个service（执行这条指令可能会卡住大概10秒）
subctl export service --namespace default nginx
	
# 获取当前运行的namespace所有pods的信息（比如获取nginx的IP），包括pod运行在哪个节点上
kubectl get po -o wide

	
	
	
yq -i eval \
'.clusters[].cluster.server |= sub("10.1.1.111", "43.128.252.173") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
/root/mytest






# uninstall subctl
# 删除broker-info.subm
rm -rf broker-info.subm

# 对每一个加入submariner的节点，删除指定的namespace（每一个delete语句大概要等30秒）
kubectl delete namespace submariner-operator

kubectl delete namespace submariner-k8s-broker

# 删除submariner的 CRDs
for CRD in `kubectl get crds | grep -iE 'submariner|multicluster.x-k8s.io'| awk '{print $1}'`; do kubectl delete crd $CRD; done


# 对每一个加入submariner的节点，删除submariner的ClusterRoles和ClusterRoleBinding
roles="submariner-operator submariner-operator-globalnet submariner-lighthouse submariner-networkplugin-syncer"
kubectl delete clusterrole,clusterrolebinding $roles --ignore-not-found


# 删除submariner的网关标签
kubectl label --all node submariner.io/gateway-
# 查看当前submariner的gateway是否安装在多个节点上（验证是否删除成功）
kubectl get ds -n submariner-operator


# 手动编辑coredns的Corefile configmap然后删除lighthouse条目（两条命令选一个）
kubectl edit cm coredns -n kube-system

kubectl rollout restart -n kube-system deployment/coredns


# 检查dns-default config map的Corefile文件，验证lighthouse条目被删除
kubectl describe configmap coredns -n kube-system

# 删除submariner在iptables中的链
iptables --flush SUBMARINER-INPUT
iptables -D INPUT $(iptables -L INPUT --line-numbers | grep SUBMARINER-INPUT | awk '{print $1}')
iptables --delete-chain SUBMARINER-INPUT

iptables -t nat --flush SUBMARINER-POSTROUTING
iptables -t nat -D POSTROUTING $(iptables -t nat -L POSTROUTING --line-numbers | grep SUBMARINER-POSTROUTING | awk '{print $1}')
iptables -t nat --delete-chain SUBMARINER-POSTROUTING


# 删除vx-submariner接口
ip link delete vx-submariner






# debug
# 查看日志
kubectl  get po -A -o wide |grep gateway

kubectl  logs -f  submariner-gateway-2rgz8   -n submariner-operator

kubectl  delete po  submariner-gateway-fbwf8  -n submariner-operator



# 查看yaml文件
kubectl  get po  -A -o wide


kubectl  get po  kube-apiserver-10.0.0.144   -n kube-system -o yaml

kubectl  get po  submariner-gateway-4hr5l   -n submariner-operator -o yaml









