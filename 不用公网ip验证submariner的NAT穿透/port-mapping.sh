





wget https://github.com/coreos/flannel/releases/download/v0.11.0/flannel-v0.11.0-linux-amd64.tar.gz



tar -zxvf flannel-v0.11.0-linux-amd64.tar.gz

rm flannel-v0.11.0-linux-amd64.tar.gz





# 官网说明https://submariner.io/operations/nat-traversal/#Public%20Cloud%20vs%20On-Premises

kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/natt-discovery-port=4491
kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/udp-port=4501
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/natt-discovery-port=4492
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/udp-port=4502

# restart the gateways to pick up the new setting
for cluster in C D;
do
  kubectl delete pod -n submariner-operator -l app=submariner-gateway --kubeconfig $cluster
done



# 对于NAT穿透的case，需要对没有公网IP的那两个cluster执行如下命令



kubectl annotate node vm-0-12-ubuntu  gateway.submariner.io/natt-discovery-port=4491

kubectl annotate node vm-0-12-ubuntu  gateway.submariner.io/udp-port=4501

kubectl delete pod -n submariner-operator -l app=submariner-gateway




kubectl annotate node vm-0-33-ubuntu  gateway.submariner.io/natt-discovery-port=4492

kubectl annotate node vm-0-33-ubuntu  gateway.submariner.io/udp-port=4502

kubectl delete pod -n submariner-operator -l app=submariner-gateway
















