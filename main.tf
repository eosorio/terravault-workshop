provider "digitalocean" {
  token = "${var.do_token}"
}

variable "region" {
  default = "nyc1"
}

resource "digitalocean_ssh_key" "default" {
  name         = "test_key"
  public_key   = "${file("/home/eduardo/.ssh/digitaloceank8s.pub")}"
}

resource "digitalocean_droplet" "nginx_droplet" {
  image              = "ubuntu-18-04-x64"
  name               = "nginx-${count.index}"
  region             = "${var.region}"
  size               = "512mb"
  private_networking = true
  ssh_keys           = ["${digitalocean_ssh_key.default.fingerprint}"]
  count              = 2

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.pvt)}"
    timeout     = "2m"
  }

  provisioner "remote-exec"
  {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }
}

resource "digitalocean_loadbalancer" "public" {
  name   = "loadbalancer-1"
  region = "${var.region}"

  forwarding_rule {
    entry_port       = "${var.default_port}"
    entry_protocol   = "${var.http_protocol}"

    target_port      = "${var.default_port}"
    target_protocol  = "${var.http_protocol}"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.nginx_droplet.*.id}"]
}

resource "digitalocean_domain" "nginx_domain" {
   name = "osmon-fam.net"
   ip_address = "${digitalocean_loadbalancer.public.ip}"
}


resource "digitalocean_record" "CNAME-www" {
  domain = "${digitalocean_domain.nginx_domain.name}"
  type = "CNAME"
  name = "workshop"
  value = "@"
}
