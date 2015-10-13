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

  # install 
  provisioner "remote-exec" {
    scripts = [
      "resources/install.sh"
    ]
  }

  # create a server.hcl
  provisioner "remote-exec" {
    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir        = "/opt/nomad/data"
enable_syslog   = true
syslog_facility = "LOCAL0"
log_level       = "DEBUG"
datacenter      = "${var.region}"
server {
  enabled          = true
  bootstrap_expect = "${var.numberofnodes}"
}
addresses {
  http = "127.0.0.1"
  rpc  = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
}
client {
  enabled = true
  servers = ["${self.network_interface.0.address}:4647"]
}

EOF
CMD
  }

  # copy the init file
  provisioner "file" {
    source      = "resources/nomad.service"
    destination = "/lib/systemd/system/nomad.service"
  }

  # start the service
  provisioner "remote-exec" {
    inline = "sudo systemctl enable nomad.service && sudo service nomad start"
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

