resource "yandex_compute_instance" "bh" {
  name = "bastion-host"

  zone = yandex_vpc_subnet.public-subnet.zone

  resources {
    cores = 2
    core_fraction = 20
    memory = 1
    
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    dns_record {
      fqdn = "bastion.dip.lom."
    }
  }

  metadata = {
    user-data = "${file("./bastion.yml")}"
  }

#  provisioner "file" {
#    source = "./ansible_controller/ansible.key"
#    destination = "/home/ansible/.ssh/ansible.key"
#  }

}

resource "yandex_compute_snapshot_schedule" "bh-snapshot" {
  name = "bastion-snapshot"

  schedule_policy {
    expression = "45 21 * * *" # Every day at 21:45
  }

  snapshot_count = 7  # Maximum snapshots

  snapshot_spec {
    labels = { target = "bastion"}
  }

  disk_ids = [ yandex_compute_instance.bh.boot_disk[0].disk_id ]

}