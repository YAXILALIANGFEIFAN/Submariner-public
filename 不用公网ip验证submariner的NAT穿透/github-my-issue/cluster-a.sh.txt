#!/bin/bash
#Before installing kubeadm，please do some checking as following:
#	Docker has been installed
#	Log in to the operating system with root
#   modify the hostname to lowercase
#	
#	subctl v0.9.0 has been installed
#	calicoctl has been installed
#	yq has been installed
#	Disable swap
#	Disable selinux

K8S_VERSION="v1.19.7"
CNI_VERSION="v0.8.2"

#0. clean up env
kubeadm reset -f
rm -rf broker-info.subm
rm -rf /usr/bin/kube*

#1. set http proxy
# export http_proxy=http://49.51.49.223:8123
# export https_proxy=http://49.51.49.223:8123

#2. install yq
# BINARY=yq_linux_amd64
# wget https://github.com/mikefarah/yq/releases/download/v4.8.0/${BINARY} -O /usr/bin/yq &&  chmod +x /usr/bin/yq


#3. install CNI plugins
sudo mkdir -p /opt/cni/bin
# wget -c  "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" -O - | tar -C /opt/cni/bin -xz
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz


#4. download kubeadm, kubelet, kubectl, flannel
curl -o /usr/bin/kubeadm https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubeadm && chmod +x /usr/bin/kubeadm
curl -o /usr/bin/kubelet https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubelet && chmod +x /usr/bin/kubelet
curl -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl && chmod +x /usr/bin/kubectl
curl -o /root/kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


# sed -i "s/10.244.0.0/${POD_CIDR}/g" kube-flannel.yml
sed -i "s/10.244.0.0/10.44.0.0/g" kube-flannel.yml


#5. add a kubelet systemd service
RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#6. enable and start kubelet
systemctl enable --now kubelet

#7. install subctl
# curl -Ls https://get.submariner.io | bash
# export PATH=$PATH:~/.local/bin
# echo export PATH=\$PATH:~/.local/bin >> ~/.profile

#8. unset http proxy
# unset http_proxy
# unset https_proxy

# 43.128.40.60
# 10.0.32.154

kubeadm init --apiserver-advertise-address=10.0.32.154 \
--apiserver-cert-extra-sans=localhost,127.0.0.1,10.0.32.154,43.128.40.60 \
--pod-network-cidr=10.44.0.0/16 \
--service-cidr=10.45.0.0/16 \
--kubernetes-version ${K8S_VERSION}

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

yq -i eval \
'.clusters[].cluster.server |= sub("10.0.32.154", "43.128.40.60") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
$HOME/.kube/config

sleep 60

kubectl label node vm-32-154-ubuntu submariner.io/gateway=true
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl create -f kube-flannel.yml

sleep 120

subctl deploy-broker 

sleep 60

scp  broker-info.subm 129.226.196.185:/root


subctl join broker-info.subm --clusterid cluster-a --natt=true




