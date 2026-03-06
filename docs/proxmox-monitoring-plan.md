# Proxmox + VM + Podman Monitoring Implementation Plan

## Scope
- Monitor 3 Proxmox hosts (Mac mini) with node_exporter and pve-exporter
- Monitor VMs (Home Assistant and container repository VM) with node_exporter
- Monitor Podman containers on the container repository host with cAdvisor
- Central monitoring VM runs Prometheus, Grafana, and Alertmanager on Debian 13 using Podman and a docker-compose file
- Retention: 30 days, scrape interval: 30s

## Target architecture
- Monitoring VM (Debian 13, Podman)
  - Prometheus (metrics storage)
  - Grafana (dashboards)
  - Alertmanager (alerts)
  - pve-exporter (Proxmox API metrics)
- Proxmox hosts (3)
  - node_exporter (host metrics)
- VMs (2)
  - node_exporter (guest metrics)
- Podman host (container repository)
  - cAdvisor (container metrics)

## Inputs needed
- Monitoring VM hostname/IP: <MONITORING_VM>
- Proxmox hosts: <PVE1>, <PVE2>, <PVE3>
- VM hosts: <HA_VM>, <CONTAINER_REPO_VM>
- Podman host: <PODMAN_HOST>
- Proxmox API token:
  - user: monitoring@pve
  - token_name: <TOKEN_ID>
  - token_value: <TOKEN_SECRET>

## Implementation steps

### 1) Provision monitoring VM
- Create Debian 13 VM: 2 vCPU, 4-8 GB RAM, 100-200 GB disk
- Assign static IP or DHCP reservation
- Confirm access from Proxmox hosts and VMs

### 2) Install Podman and compose tooling (monitoring VM)
- Install packages via apt:
  - podman
  - podman-compose (or docker-compose if preferred)
- Create a docker-compose file for:
  - Prometheus
  - Grafana
  - Alertmanager
  - pve-exporter
- Use systemd to manage the compose stack

### 3) Configure Prometheus retention and storage
- Set retention to 30d in the Prometheus container args
- Mount a host path for the TSDB on the VM disk
- Restart the compose stack

### 4) Configure pve-exporter
- Create Proxmox API token with PVEAuditor role
- Provide config via bind mount to the pve-exporter container
- Restart the compose stack

### 5) Install node_exporter on Proxmox hosts
- Install `prometheus-node-exporter` via apt on each host
- Enable and start the service
- Verify port 9100 reachable from the monitoring VM

### 6) Install node_exporter on VMs
- Install `prometheus-node-exporter` via apt in each VM
- Enable and start the service
- Verify port 9100 reachable from the monitoring VM

### 7) Deploy cAdvisor on Podman host (rootful)
- Run cAdvisor container once with Podman
- Generate a systemd unit using `podman generate systemd`
- Move unit to `/etc/systemd/system/` and enable it
- Verify `http://<PODMAN_HOST>:8080/metrics` is reachable

### 8) Configure Prometheus scrape targets
- Update the Prometheus config volume:
  - Proxmox hosts (node_exporter)
  - VMs (node_exporter)
  - pve-exporter endpoint
  - cAdvisor endpoint
- Reload Prometheus (container restart or reload endpoint)

### 9) Configure Grafana
- Open `http://<MONITORING_VM>:3000`
- Add Prometheus datasource: `http://localhost:9090`
- Import community dashboards:
  - Proxmox VE (pve-exporter)
  - Node Exporter Full
  - cAdvisor

### 10) Optional: Alerting
- Configure basic alerts:
  - Host down
  - Disk usage >= 80%
  - Memory usage >= 90%
  - VM unexpectedly stopped
- Route alerts via email/Telegram/Discord

### 11) Validation checklist
- Prometheus targets all show UP
  - Grafana dashboards render with live data
  - Alertmanager receives test alert
  - Disk usage grows at expected rate

## Notes
- Keep firewall rules open between monitoring VM and exporters:
  - 9100 (node_exporter), 9221 (pve-exporter), 8080 (cAdvisor)
- Expose Grafana directly on port 3000 as requested
- If retention or metric volume grows, expand disk or reduce scrape interval/metrics
