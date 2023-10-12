resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name  = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_security_group" "default-sg" {
  name        = "default-sg"
  description = "Default security group"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow ICMP"
    protocol          = "ICMP"
    port              = 443
  }

  egress {
    description       = "Permit ANY"
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web-sg" {
  name        = "web-sg"
  description = "Security group for web servers"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow HTTPS"
    protocol          = "TCP"
    port              = 443
  }

  ingress {
    description       = "Allow HTTP"
    protocol          = "TCP"
    port              = 80
  }
}

resource "yandex_vpc_security_group" "internal-ssh-sg" {
  name        = "internal-ssh-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow SSH"
    protocol          = "TCP"
    port              = 21
    v4_cidr_blocks = [yandex_vpc_subnet.public-subnet.v4_cidr_blocks[*],
                      yandex_vpc_subnet.private-subnet-a.v4_cidr_blocks[*],
                      yandex_vpc_subnet.private-subnet-b.v4_cidr_blocks[*]]
  }
}

resource "yandex_vpc_security_group" "external-ssh-sg" {
  name        = "external-ssh-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow SSH"
    protocol          = "TCP"
    port              = 21
  }
}

resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow 5601"
    protocol          = "TCP"
    port              = 5601
  }
}
resource "yandex_vpc_security_group" "es-sg" {
  name        = "es-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow 9200"
    protocol          = "TCP"
    port              = 9200
  }
}

resource "yandex_vpc_security_group" "grafana-sg" {
  name        = "grafana-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow 3000"
    protocol          = "TCP"
    port              = 3000
  }
}

resource "yandex_vpc_security_group" "prometheus-sg" {
  name        = "prometheus-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow 9090"
    protocol          = "TCP"
    port              = 9090
  }
}

resource "yandex_vpc_security_group" "metrics-sg" {
  name        = "metrics-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    description       = "Allow nginxlog_exporter"
    protocol          = "TCP"
    port              = 4040
  }

    ingress {
    description       = "Allow node_exporter"
    protocol          = "TCP"
    port              = 9100
  }

}