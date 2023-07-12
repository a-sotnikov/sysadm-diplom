resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"

  zone = yandex_vpc_subnet.subnet-b.zone

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
    subnet_id = yandex_vpc_subnet.subnet-b.id
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "grafana" {
  name = "grafana"

  zone = yandex_vpc_subnet.subnet-b.zone

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
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}