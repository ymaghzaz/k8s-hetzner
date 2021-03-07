
locals {
  master_ip = "192.168.0.2"
}

resource "hcloud_server" "master" {
  name        = "master-kub"
  server_type = var.master_type
  image       = var.master_image
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]
  location    = "nbg1"

  network {
    network_id = hcloud_network.kub_network.id
    ip         =  "192.168.0.2"
    alias_ips  = [
      "192.168.0.3",
      "192.168.0.4"
    ]
  }

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/master.sh"
    destination = "/root/master.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/master.sh"]
  }

  depends_on = [
    hcloud_network_subnet.kub_network_subnet
  ]
}
