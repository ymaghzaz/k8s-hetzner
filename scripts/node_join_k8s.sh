#!/bin/bash
set -eu
SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}
SSH_USERNAME=${SSH_USERNAME:-}
SSH_HOST_MASTER=${SSH_HOST_MASTER:-}
NODE_ID=${NODE_ID:-}

TARGET=${TARGET:-}

mkdir -p "${TARGET}"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST_MASTER}" "kubeadm token create --print-join-command" >  \
    "${TARGET}kubeadm_join_${NODE_ID}"
