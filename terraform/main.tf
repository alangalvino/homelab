module "home_assistant_vm" {
  source       = "./modules/proxmox-disk-image-vm"
  hostname     = "home-assistant"
  proxmox_node = "pve3"
  cpu_cores    = 2
  memory       = 6144
  disk_size    = 100
  bios         = "ovmf"
  image_url    = "https://github.com/home-assistant/operating-system/releases/download/15.2/haos_ova-15.2.qcow2.xz"
  # IoT VLAN_ID is 40
  ip_address          = "192.168.40.24"
  network_vlan_id     = 40
  network_mac_address = "02:5f:52:b4:3d:40"
}

module "talos_node_1" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve1"
  hostname            = "talos-controlplane"
  cpu_cores           = 2
  memory              = 6144
  disk_size           = 200
  ip_address          = "192.168.50.21"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "e6:3f:f3:99:40:3d"
}

module "talos_node_2" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve2"
  hostname            = "talos-worker-1"
  cpu_cores           = 2
  memory              = 14336
  disk_size           = 200
  ip_address          = "192.168.50.22"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "b6:1a:77:fb:38:60"
}

module "talos_node_3" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve3"
  hostname            = "talos-worker-2"
  cpu_cores           = 2
  memory              = 6144
  disk_size           = 200
  ip_address          = "192.168.50.23"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "ca:29:05:23:c7:cd"
}

module "k8s_cluster" {
  source     = "./modules/k8s-cluster"
  depends_on = [module.talos_node_1, module.talos_node_2, module.talos_node_3]

  cluster_name     = "k8s-cluster"
  cluster_endpoint = "192.168.50.21"
  controlplanes    = ["192.168.50.21"]
  workers          = ["192.168.50.22", "192.168.50.23"]
}

module "homepage" {
  source     = "./modules/kustomize"
  kustomize_path = "../k8s/apps/homepage/"
}

module "pihole" {
  source     = "./modules/kustomize"
  kustomize_path = "../k8s/apps/pihole/"
}
