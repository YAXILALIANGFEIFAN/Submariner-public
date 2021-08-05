




gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project ruyingzhe-312112

scp .kube/config 43.128.115.112:/opt


scp -r /home/g3321337994/google-cloud-sdk/ root@43.128.115.112:/home/g3321337994/google-cloud-sdk/


vi /root/.profile



获取节点的外网ip
https://cloud.google.com/anthos/clusters/docs/on-prem/1.7/how-to/ssh-cluster-node


kubectl --kubeconfig <config文件的绝对路径> get nodes --output wide

kubectl --kubeconfig /opt/config get nodes --output wide


kubectl get nodes --output wide

kubectl --kubeconfig [ADMIN_CLUSTER_KUBECONFIG] get secrets -n [USER_CLUSTER_NAME] ssh-keys \
-o jsonpath='{.data.ssh\.key}' | base64 -d > \
~/.ssh/[USER_CLUSTER_NAME].key && chmod 600 ~/.ssh/[USER_CLUSTER_NAME].key


cluster-1

kubectl --kubeconfig /opt/config get secrets -n cluster-1 ssh-keys \
-o jsonpath='{.data.ssh\.key}' | base64 -d > \
~/.ssh/cluster-1.key && chmod 600 ~/.ssh/cluster-1.key






# 连接指定的node节点

# 配置好PROJECT_ID
gcloud config set project <PROJECT_ID>

gcloud config set project ruyingzhe-312112


# gcloud命令连接指定的node节点
gcloud compute ssh <NODE_NAME> --zone <ZONE>

gcloud compute ssh gke-cluster-1-default-pool-d2a4431c-68l8 --zone us-central1-c

# 获取root权限
sudo su



# 把broker-info.subm文件传给指定的节点
scp  broker-info.subm <目标节点的公网ip>:/root

scp  broker-info.subm 34.133.20.107:/root





# 把其他node隔离
kubectl cordon gke-cluster-1-default-pool-d2a4431c-j6lq

kubectl cordon gke-cluster-1-default-pool-d2a4431c-xk0g



# 因为没法从linux主机传文件给LB或者cluster-c中的node节点，
# 所以在LB或者cluster-c中的node节点，使用scp从指定的linux主机下载文件
scp root@43.131.68.117:/root/broker-info.subm .

scp root@43.131.68.117:/root/.local/bin/subctl /tmp



# 查看broker-info.subm的位置
ls

pwd


/home/g3321337994/broker-info.subm


# 把其中一个节点标记为submariner的网关未来部署的节点	
kubectl label node gke-cluster-1-default-pool-d2a4431c-68l8 submariner.io/gateway=true



mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



sudo cp /etc/kubernetes/admin.conf HOME/ 
sudo chown (id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf






./subctl join /tmp/broker-info.subm --clusterid cluster-c --natt=true


10.4.1.4


















root@vm-1-113-ubuntu:~# kubectl --kubeconfig /opt/config get po kube-proxy-gke-cluster-1-default-pool-d2a4431c-68l8 -n kube-system -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubernetes.io/config.hash: ec0457271ac4a44853c0cb9fcf2192d0
    kubernetes.io/config.mirror: ec0457271ac4a44853c0cb9fcf2192d0
    kubernetes.io/config.seen: "2021-06-28T01:10:50.270279109Z"
    kubernetes.io/config.source: file
  creationTimestamp: "2021-06-28T01:11:31Z"
  labels:
    component: kube-proxy
    tier: node
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:kubernetes.io/config.hash: {}
          f:kubernetes.io/config.mirror: {}
          f:kubernetes.io/config.seen: {}
          f:kubernetes.io/config.source: {}
        f:labels:
          .: {}
          f:component: {}
          f:tier: {}
        f:ownerReferences:
          .: {}
          k:{"uid":"8d728fe6-f44a-473b-b9ae-a8ad387fb0eb"}:
            .: {}
            f:apiVersion: {}
            f:controller: {}
            f:kind: {}
            f:name: {}
            f:uid: {}
      f:spec:
        f:containers:
          k:{"name":"kube-proxy"}:
            .: {}
            f:command: {}
            f:image: {}
            f:imagePullPolicy: {}
            f:name: {}
            f:resources:
              .: {}
              f:requests:
                .: {}
                f:cpu: {}
            f:securityContext:
              .: {}
              f:privileged: {}
            f:terminationMessagePath: {}
            f:terminationMessagePolicy: {}
            f:volumeMounts:
              .: {}
              k:{"mountPath":"/etc/ssl/certs"}:
                .: {}
                f:mountPath: {}
                f:name: {}
                f:readOnly: {}
              k:{"mountPath":"/lib/modules"}:
                .: {}
                f:mountPath: {}
                f:name: {}
                f:readOnly: {}
              k:{"mountPath":"/run/xtables.lock"}:
                .: {}
                f:mountPath: {}
                f:name: {}
              k:{"mountPath":"/usr/share/ca-certificates"}:
                .: {}
                f:mountPath: {}
                f:name: {}
                f:readOnly: {}
              k:{"mountPath":"/var/lib/kube-proxy/kubeconfig"}:
                .: {}
                f:mountPath: {}
                f:name: {}
              k:{"mountPath":"/var/log"}:
                .: {}
                f:mountPath: {}
                f:name: {}
        f:dnsPolicy: {}
        f:enableServiceLinks: {}
        f:hostNetwork: {}
        f:nodeName: {}
        f:priority: {}
        f:priorityClassName: {}
        f:restartPolicy: {}
        f:schedulerName: {}
        f:securityContext: {}
        f:terminationGracePeriodSeconds: {}
        f:tolerations: {}
        f:volumes:
          .: {}
          k:{"name":"etc-ssl-certs"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
          k:{"name":"iptableslock"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
          k:{"name":"kubeconfig"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
          k:{"name":"lib-modules"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
          k:{"name":"usr-ca-certs"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
          k:{"name":"varlog"}:
            .: {}
            f:hostPath:
              .: {}
              f:path: {}
              f:type: {}
            f:name: {}
      f:status:
        f:conditions:
          .: {}
          k:{"type":"ContainersReady"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"Initialized"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"PodScheduled"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
          k:{"type":"Ready"}:
            .: {}
            f:lastProbeTime: {}
            f:lastTransitionTime: {}
            f:status: {}
            f:type: {}
        f:containerStatuses: {}
        f:hostIP: {}
        f:phase: {}
        f:podIP: {}
        f:podIPs:
          .: {}
          k:{"ip":"10.128.0.3"}:
            .: {}
            f:ip: {}
        f:startTime: {}
    manager: kubelet
    operation: Update
    time: "2021-06-28T01:11:34Z"
  name: kube-proxy-gke-cluster-1-default-pool-d2a4431c-68l8
  namespace: kube-system
  ownerReferences:
  - apiVersion: v1
    controller: true
    kind: Node
    name: gke-cluster-1-default-pool-d2a4431c-68l8
    uid: 8d728fe6-f44a-473b-b9ae-a8ad387fb0eb
  resourceVersion: "763"
  selfLink: /api/v1/namespaces/kube-system/pods/kube-proxy-gke-cluster-1-default-pool-d2a4431c-68l8
  uid: ba6c292f-d0c8-48f3-bd7f-2ec996bcbd4d
spec:
  containers:
  - command:
    - /bin/sh
    - -c
    - exec kube-proxy --master=https://35.223.145.12 --kubeconfig=/var/lib/kube-proxy/kubeconfig
      --cluster-cidr=10.4.0.0/14 --oom-score-adj=-998 --v=2 --feature-gates=DynamicKubeletConfig=false,RotateKubeletServerCertificate=true
      --iptables-sync-period=1m --iptables-min-sync-period=10s --ipvs-sync-period=1m
      --ipvs-min-sync-period=10s --detect-local-mode=NodeCIDR 1>>/var/log/kube-proxy.log
      2>&1
    image: gke.gcr.io/kube-proxy-amd64:v1.19.10-gke.1600
    imagePullPolicy: IfNotPresent
    name: kube-proxy
    resources:
      requests:
        cpu: 100m
    securityContext:
      privileged: true
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: etc-ssl-certs
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-ca-certs
      readOnly: true
    - mountPath: /var/log
      name: varlog
    - mountPath: /var/lib/kube-proxy/kubeconfig
      name: kubeconfig
    - mountPath: /run/xtables.lock
      name: iptableslock
    - mountPath: /lib/modules
      name: lib-modules
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  hostNetwork: true
  nodeName: gke-cluster-1-default-pool-d2a4431c-68l8
  preemptionPolicy: PreemptLowerPriority
  priority: 2000001000
  priorityClassName: system-node-critical
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    operator: Exists
  - effect: NoSchedule
    operator: Exists
  volumes:
  - hostPath:
      path: /usr/share/ca-certificates
      type: ""
    name: usr-ca-certs
  - hostPath:
      path: /etc/ssl/certs
      type: ""
    name: etc-ssl-certs
  - hostPath:
      path: /var/lib/kube-proxy/kubeconfig
      type: FileOrCreate
    name: kubeconfig
  - hostPath:
      path: /var/log
      type: ""
    name: varlog
  - hostPath:
      path: /run/xtables.lock
      type: FileOrCreate
    name: iptableslock
  - hostPath:
      path: /lib/modules
      type: ""
    name: lib-modules
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2021-06-28T01:11:34Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2021-06-28T01:11:34Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2021-06-28T01:11:34Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2021-06-28T01:11:34Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://ac55a87cf388124df240a03d7c50feaa8896172143e32eee2d40112b38ba64a5
    image: gke.gcr.io/kube-proxy-amd64:v1.19.10-gke.1600
    imageID: sha256:576e3eb0e699d3f499cbdb49ba1727e2c9479111211d9a2ebfc436e8cd1f8f4b
    lastState: {}
    name: kube-proxy
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2021-06-28T01:11:32Z"
  hostIP: 10.128.0.3
  phase: Running
  podIP: 10.128.0.3
  podIPs:
  - ip: 10.128.0.3
  qosClass: Burstable
  startTime: "2021-06-28T01:11:34Z"
root@vm-1-113-ubuntu:~# 



















