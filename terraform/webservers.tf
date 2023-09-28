resource "yandex_compute_instance" "www-1" {
  name = "webserver-1"

  zone = "ru-central1-a"

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
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    dns_record {
      fqdn = "web1.dip.lom."
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "www-2" {
  name = "webserver-2"

  zone = "ru-central1-b"

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
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    dns_record {
      fqdn = "web2.dip.lom."
    }
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_snapshot_schedule" "www-snapshot" {
  name = "www-snapshot"

  schedule_policy {
    expression = "45 21 * * *" # Every day at 21:45
  }

  snapshot_count = 7  # Maximum snapshots

  snapshot_spec {
    labels = { target = "webserver"}
  }

  disk_ids = [ yandex_compute_instance.www-1.boot_disk[0].disk_id, yandex_compute_instance.www-2.boot_disk[0].disk_id ]

}