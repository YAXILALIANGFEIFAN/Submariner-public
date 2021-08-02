#!/bin/bash
#Before installing kubeadm，please do some checking as following:
#	Docker has been installed on the computer
#	Log in to the operating system with root
#	
#	submariner has been installed on the computer
#	calicoctl has been installed on the computer
#	yq has been installed on the computer
#	dos2unix has been installed on the computer
#	Disable swap
#	Disable selinux



# # 1. install yq
# BINARY=yq_linux_amd64
# VERSION=v4.8.0 
# wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&  chmod +x /usr/bin/yq


# # 2.1 install calicoctl 
# curl -o /usr/bin/calicoctl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.18.4/calicoctl &&   chmod +x /usr/bin/calicoctl

# # 2.2 install calicoctl old version 
# curl -o /usr/bin/calicoctl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.8.1/calicoctl &&  chmod +x /usr/bin/calicoctl




# 3. install CNI plugins (required for most pod network)
CNI_VERSION="v0.8.2"
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz


#4. install kubeadm, kubelet, kubectl
RELEASE="v1.15.7"
curl -o /usr/bin/kubeadm https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/kubeadm && chmod +x /usr/bin/kubeadm
curl -o /usr/bin/kubelet https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/kubelet && chmod +x /usr/bin/kubelet
curl -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/kubectl && chmod +x /usr/bin/kubectl

#5. add a kubelet systemd service
RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf


# 6. enable and start kubelet
systemctl enable --now kubelet



rm -rf broker-info.subm
kubeadm reset -f 

kubeadm init \
	--apiserver-advertise-address=10.1.1.111 \
	--apiserver-cert-extra-sans=localhost,127.0.0.1,10.1.1.111,43.128.252.173 \
	--pod-network-cidr=10.44.0.0/16 --service-cidr=10.45.0.0/16 \
	--kubernetes-version v1.15.7 \
	--ignore-preflight-errors=FileExisting-conntrack


mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config


yq -i eval \
'.clusters[].cluster.server |= sub("10.1.1.111", "43.128.252.173") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
$HOME/.kube/config


kubectl create -f /root/EndpointSlices.yaml

kubectl label node vm-1-111-ubuntu submariner.io/gateway=true
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 120

DATASTORE_TYPE=kubernetes calicoctl create -f /root/cluster1.txt

subctl deploy-broker

sleep 60

scp  broker-info.subm 43.128.250.238:/root
scp  broker-info.subm 43.128.253.220:/root
subctl join broker-info.subm --clusterid cluster-a --natt=true





