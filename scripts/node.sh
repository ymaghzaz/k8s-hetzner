#!/bin/bash

sudo apt update && sudo apt upgrade -y && sudo apt install docker.io -y
sudo systemctl enable docker.service
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt install kubeadm -y

eval "$(cat /tmp/kubeadm_join)"
