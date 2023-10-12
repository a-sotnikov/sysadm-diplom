terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
}

locals {
  image_id = "fd8988va1tm1ig0aq7rc"
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bh.network_interface.0.nat_ip_address
}

output "load_balancer" {
  value = yandex_alb_load_balancer.l7-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
}