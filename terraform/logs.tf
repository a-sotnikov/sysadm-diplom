resource "yandex_compute_instance" "elasticsearch" {
  name = "elaticsearch"

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }
  network_interface {
      subnet_id = yandex_vpc_subnet.private-subnet-a.id
      security_group_ids = [ yandex_vpc_security_group.default-sg.id,
                              yandex_vpc_security_group.internal-ssh-sg.id, 
                              yandex_vpc_security_group.es-sg.id ]
  dns_record {
    fqdn = "es.dip.lom."
  }
  }
  zone = yandex_vpc_subnet.private-subnet-a.zone

  resources {
      cores = 2
      memory = 4
  }
  metadata = {
      user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"

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
                              yandex_vpc_security_group.kibana-sg.id ]
  dns_record {
    fqdn = "kibana.dip.lom."
  }
  }
  zone = yandex_vpc_subnet.public-subnet.zone

  resources {
      cores = 2
      memory = 2
  }
  metadata = {
      user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_snapshot_schedule" "logs-snapshot" {
  name = "logs-snapshot"

  schedule_policy {
    expression = "45 21 * * *" # Every day at 21:45
  }

  snapshot_count = 7  # Maximum snapshots

  snapshot_spec {
    labels = { target = "logs"}
  }

  disk_ids = [ yandex_compute_instance.elasticsearch.boot_disk[0].disk_id, yandex_compute_instance.kibana.boot_disk[0].disk_id ]

}