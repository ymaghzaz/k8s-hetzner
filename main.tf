provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "k8s_admin_simple"
  public_key = file(var.ssh_public_key)
}
