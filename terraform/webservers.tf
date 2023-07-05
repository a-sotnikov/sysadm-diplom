resource "yandex_compute_instance" "www-1" {
  name = "webserver-1"

  zone = yandex_vpc_subnet.subnet-a.zone

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
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_compute_instance" "www-2" {
  name = "webserver-2"

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

resource "yandex_alb_target_group" "tg-1" {
  name = "target-grp"

  target {
    subnet_id = yandex_compute_instance.www-1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.www-1.network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_compute_instance.www-2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.www-2.network_interface.0.ip_address
  }

}

resource "yandex_alb_backend_group" "bg-1" {
  name                     = "backend-grp"

  http_backend {
    name                   = "backend-1"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.tg-1.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name   = "http-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virt-host"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "main-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg-1.id
        timeout          = "3s"
      }
    }
  }
}    

resource "yandex_alb_load_balancer" "test-balancer" {
  name        = "l7-balancer"
  network_id  = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = yandex_vpc_subnet.subnet-a.zone
      subnet_id = yandex_vpc_subnet.subnet-a.id
    }
  }

  listener {
    name = "l7b-listener"
    endpoint {
      address {
        external_ipv4_address {
      
        }
      }
      ports = [ 9000 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}
