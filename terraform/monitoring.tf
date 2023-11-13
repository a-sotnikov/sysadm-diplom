resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"

  zone = yandex_vpc_subnet.private-subnet-b.zone

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
    
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    security_group_ids = [ yandex_vpc_security_group.default-sg.id, 
                            yandex_vpc_security_group.internal-ssh-sg.id, 
                            yandex_vpc_security_group.prometheus-sg.id ]
    dns_record {
      fqdn = "prometheus.dip.lom."
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "grafana" {
  name = "grafana"

  zone = yandex_vpc_subnet.public-subnet.zone

  resources {
    cores = 2
    core_fraction = 20
    memory = 2
    
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = [ yandex_vpc_security_group.default-sg.id,
                            yandex_vpc_security_group.internal-ssh-sg.id, 
                            yandex_vpc_security_group.grafana-sg.id ]
    dns_record {
      fqdn = "grafana.dip.lom."
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_snapshot_schedule" "monitoring-snapshot" {
  name = "monitoring-snapshot"

  schedule_policy {
    expression = "45 21 * * *" # Every day at 21:45
  }

  snapshot_count = 7  # Maximum snapshots

  snapshot_spec {
    labels = { target = "monitoring"}
  }

  disk_ids = [ yandex_compute_instance.prometheus.boot_disk[0].disk_id, yandex_compute_instance.grafana.boot_disk[0].disk_id ]

}