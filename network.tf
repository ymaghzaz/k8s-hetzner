resource "hcloud_network" "kub_network" {
  name     = "kub_network"
  ip_range = "192.168.0.0/16"
}

resource "hcloud_network_subnet" "kub_network_subnet" {
  network_id   = hcloud_network.kub_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "192.168.0.0/24"
}

