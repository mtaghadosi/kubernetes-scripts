sudo hostnamectl set-hostname "master1.mohammad.net"
exec bash

sudo hostnamectl set-hostname "worker1.mohammad.net"   // 1st worker node
sudo hostnamectl set-hostname "worker2.mohammad.net"   // 2nd worker node
exec bash

/etc/hosts 
192.168.1.173   master1.mohammad.net master1
192.168.1.174   worker1.mohammad.net worker1
192.168.1.175   worker2.mohammad.net worker2

reboot NOW

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF 
sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#=====ONLY MASTER NODE=====

sudo kubeadm init --control-plane-endpoint=master1.mohammad.net

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#=====WORKER NODED ONLY=====

sudo kubeadm join k8smaster.example.net:6443 --token ((TOKEN FOR JOIN)) --discovery-token-ca-cert-hash sha256:(GENERATED HASH FROM SHELL))
IF MISSED: kubeadm token create --print-join-command

#=====MASTER NODE ONLY=====
curl https://github.com/mtaghadosi/kubernetes-scripts/blob/main/calico-plugin-for-k8s.yaml -O && kubectl apply -f calico.yaml
kubectl get pods -n kube-system ((WAIT UNTIL ALL NODES COME UP))

END
mTaghadosi
