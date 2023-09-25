resource "yandex_compute_instance" "elasticsearch" {
  name = "elaticsearch"

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }
  network_interface {
      subnet_id = yandex_vpc_subnet.private-subnet.id
  dns_record {
    fqdn = "es.dip.lom."
  }
  }
  zone = yandex_vpc_subnet.private-subnet.zone

  resources {
      cores = 2
      memory = 2
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