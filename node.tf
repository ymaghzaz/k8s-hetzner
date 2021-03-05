
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
    source      = "secrets/kubeadm_join"
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
    hcloud_server.master,
    null_resource.kubernetes_join_token
  ]

}
