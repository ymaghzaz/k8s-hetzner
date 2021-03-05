#!/bin/bash

sudo apt update && sudo apt upgrade -y && sudo apt install docker.io -y
sudo systemctl enable docker.service
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt install kubeadm -y

sudo kubeadm init --apiserver-advertise-address 192.168.0.2 \
    --service-cidr 10.96.0.0/16 \
    --pod-network-cidr 10.244.0.0/16 \
    --ignore-preflight-errors=NumCPU

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
