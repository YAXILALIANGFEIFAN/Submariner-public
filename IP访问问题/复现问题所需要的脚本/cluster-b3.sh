#!/bin/bash
#Before installing kubeadm，please do some checking as following:
#	Docker has been installed on the computer
#	Log in to the operating system with root
#	
#	submariner has been installed on the computer
#	calicoctl has been installed on the computer
#	yq has been installed on the computer
#	dos2unix has been installed on the computer
#	conntrack has been installed on the computer
#	Disable swap conntrack
#	Disable selinux
#	ssh-keygen ssh-copy-id


# # Install CNI plugins (required for most pod network)
# CNI_VERSION="v0.8.2"
# sudo mkdir -p /opt/cni/bin
# curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

# # Define the directory to download command files
# DOWNLOAD_DIR=/usr/local/bin
# sudo mkdir -p $DOWNLOAD_DIR

# # Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
# CRICTL_VERSION="v1.17.0"
# curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

# # Install kubeadm, kubelet, kubectl and add a kubelet systemd service
# # RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
# RELEASE="v1.19.7"
# cd $DOWNLOAD_DIR
# sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
# sudo chmod +x {kubeadm,kubelet,kubectl}

# RELEASE_VERSION="v0.4.0"
# curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
# sudo mkdir -p /etc/systemd/system/kubelet.service.d
# curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# # Enable and start kubelet
# systemctl enable --now kubelet

# sleep 20







# # 1. install yq
# BINARY=yq_linux_amd64
# VERSION=v4.8.0 
# wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&    chmod +x /usr/bin/yq


# # 2. install yq calicoctl 
# curl -o /usr/bin/calicoctl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.18.4/calicoctl &&   chmod +x /usr/bin/calicoctl


# 3. install CNI plugins (required for most pod network)
CNI_VERSION="v0.8.2"
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz


#4. install kubeadm, kubelet, kubectl
RELEASE="v1.19.7"
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


# rm -rf broker-info.subm


kubeadm reset -f

kubeadm init --apiserver-advertise-address=10.1.1.149  --pod-network-cidr=10.144.0.0/16  --service-cidr=10.145.0.0/16 --kubernetes-version v1.19.7 

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

yq -i eval \
'.clusters[].cluster.server |= sub("10.1.1.149", "10.1.1.149") | .contexts[].name = "cluster-b" | .current-context = "cluster-b"' \
$HOME/.kube/config


kubectl label node vm-1-149-ubuntu submariner.io/gateway=true
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 120

subctl join broker-info.subm --clusterid cluster-b --natt=true

DATASTORE_TYPE=kubernetes calicoctl create -f /root/cluster2.txt





