data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "elasticsearch" {
    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.container-optimized-image.id
      }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.subnet-a.id
        nat       = true
    }
    zone = yandex_vpc_subnet.subnet-a.zone

    resources {
        cores = 2
        memory = 2
    }
    metadata = {
        docker-compose = "${file("./config/docker-compose-es.yml")}"
        user-data = "${file("./meta.yml")}"
    }
}

resource "yandex_compute_instance" "kibana" {
    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.container-optimized-image.id
      }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.subnet-a.id
        nat       = true
    }
    zone = yandex_vpc_subnet.subnet-a.zone

    resources {
        cores = 2
        memory = 2
    }
    metadata = {
        docker-compose = "${file("./config/docker-compose-kibana.yml")}"
        user-data = "${file("./meta.yml")}"
    }
}
