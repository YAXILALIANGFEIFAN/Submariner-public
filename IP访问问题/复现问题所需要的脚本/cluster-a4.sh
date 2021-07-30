#!/bin/bash
#Before installing kubeadm，please do some checking as following:
#	Docker has been installed on the computer
#	Log in to the operating system with root
#	
#	submariner has been installed on the computer
#	calicoctl has been installed on the computer

rm -rf broker-info.subm
kubeadm reset -f 

kubeadm init --apiserver-advertise-address=10.1.1.37 --apiserver-cert-extra-sans=localhost,127.0.0.1,10.1.1.37,124.156.237.68 --pod-network-cidr=10.44.0.0/16 --service-cidr=10.45.0.0/16 --kubernetes-version v1.19.7

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

yq -i eval \
'.clusters[].cluster.server |= sub("10.1.1.37", "124.156.237.68") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
$HOME/.kube/config



kubectl label node VM-1-37-ubuntu submariner.io/gateway=true
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 120

DATASTORE_TYPE=kubernetes calicoctl create -f /root/cluster1.txt

subctl deploy-broker 

sleep 60

scp  broker-info.subm 43.128.232.201:/root
# scp  broker-info.subm 129.226.144.251:/root
subctl join broker-info.subm --clusterid cluster-a --natt=true




