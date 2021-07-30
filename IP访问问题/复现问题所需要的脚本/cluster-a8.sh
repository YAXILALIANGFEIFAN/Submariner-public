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


# Install CNI plugins (required for most pod network)
CNI_VERSION="v0.8.2"
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

# Define the directory to download command files
DOWNLOAD_DIR=/usr/local/bin
sudo mkdir -p $DOWNLOAD_DIR

# Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
CRICTL_VERSION="v1.17.0"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

# Install kubeadm, kubelet, kubectl and add a kubelet systemd service
# RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
RELEASE="v1.19.7"
cd $DOWNLOAD_DIR
sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Enable and start kubelet
systemctl enable --now kubelet

sleep 20


rm -rf broker-info.subm
kubeadm reset -f 

kubeadm init --apiserver-advertise-address=10.1.1.37 --apiserver-cert-extra-sans=localhost,127.0.0.1,10.1.1.37,124.156.237.68 --pod-network-cidr=10.44.0.0/16 --service-cidr=10.45.0.0/16 --kubernetes-version v1.19.7

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

yq -i eval \
'.clusters[].cluster.server |= sub("10.1.1.37", "124.156.237.68") | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
$HOME/.kube/config



kubectl label node vm-1-37-ubuntu submariner.io/gateway=true
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 120

DATASTORE_TYPE=kubernetes calicoctl create -f /root/cluster1.txt

subctl deploy-broker 

sleep 60

scp  broker-info.subm 43.128.232.201:/root
scp  broker-info.subm 124.156.223.85:/root
subctl join broker-info.subm --clusterid cluster-a --natt=true





