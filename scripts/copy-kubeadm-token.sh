#!/bin/bash
set -eu
SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}
SSH_USERNAME=${SSH_USERNAME:-}
SSH_HOST=${SSH_HOST:-}

TARGET=${TARGET:-}

mkdir -p "${TARGET}"

ssh  \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST}" "kubeadm token create --print-join-command" >  \
    "${TARGET}kubeadm_join"
