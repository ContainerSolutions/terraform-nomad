# provider stuff for connecting to google
provider "google" {
    account_file = "${var.account_file}"
    project = "${var.project}"
    region = "${var.region}"
}

# the instance
resource "google_compute_instance" "nomad-node" {
    count = "${var.numberofnodes}"
    name = "nomad${count.index+1}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"
    
    disk {
      image = "${var.image}"
      type = "pd-ssd"
    }

    # network interface
    network_interface {
      network = "${google_compute_network.nomad-net.name}"
      access_config {
        // ephemeral address
      }
    }
    
    # nomad version
    metadata {
      nomad_version = "${var.nomad_version}"
    }

    # define default connection for remote provisioners
    connection {
      user = "${var.gce_ssh_user}"
      key_file = "${var.gce_ssh_private_key_file}"
      agent = "false"
    }

    # copy files
    provisioner "file" {
      source = "resources/server.hcl"
      destination = "/home/ubuntu/server.hcl"
    }

    # install 
    provisioner "remote-exec" {
      scripts = [
        "resources/install.sh"
      ]
    }
}

resource "google_compute_network" "nomad-net" {
    name = "${var.name}-net"
    ipv4_range ="${var.network}"
}

resource "google_compute_firewall" "nomad-ssh" {
    name = "${var.name}-nomad-ssh"
    network = "${google_compute_network.nomad-net.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["ssh"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "nomad-internal" {
    name = "${var.name}-nomad-internal"
    network = "${google_compute_network.nomad-net.name}"

    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "icmp"
    }

    source_ranges = ["${google_compute_network.nomad-net.ipv4_range}","${var.localaddress}"]

}

