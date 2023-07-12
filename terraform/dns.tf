resource "yandex_dns_zone" "zone1" {
  name        = "my-private-zone"
  description = "Test private zone"

  labels = {
    label1 = "test-private"
  }

  public           = false
  private_networks = [yandex_vpc_network.network-1.id]
  zone = "dip.lom."
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "web1.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.www-1.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "web2.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.www-2.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs3" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "es.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.elasticsearch.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs4" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "kibana.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.kibana.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs5" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "prometheus.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.prometheus.network_interface.0.ip_address]
}

resource "yandex_dns_recordset" "rs6" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "grafana.dip.lom."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.grafana.network_interface.0.ip_address]
}
