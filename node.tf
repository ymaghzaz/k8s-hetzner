resource "null_resource" "kubernetes_node_join_master" {
  count = var.node_count
  provisioner "local-exec" {
    command = "bash scripts/node_join_k8s.sh"
    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME    = "root"
      SSH_HOST_MASTER =  hcloud_server.master.ipv4_address
      NODE_ID =  count.index
      TARGET          = "${path.module}/secrets/"
    }
  }

  depends_on = [
    hcloud_server.master
  ]
}


resource "hcloud_server" "node" {
  count = var.node_count
  name = "node-v-${count.index + 1}"
  server_type = var.node_type
  image = var.node_image
  location    = "nbg1"
  ssh_keys = [
    hcloud_ssh_key.k8s_admin.id
  ]

  network {
    network_id = hcloud_network.kub_network.id
    ip         =  "192.168.0.${5 + count.index}"
  }

  connection {
    host = self.ipv4_address
    type = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "secrets/kubeadm_join_${count.index}"
    destination = "/tmp/kubeadm_join"
  }

  provisioner "file" {
    source      = "scripts/node.sh"
    destination = "/root/node.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/node.sh"]
  }

  depends_on = [
    null_resource.kubernetes_node_join_master
  ]
}



