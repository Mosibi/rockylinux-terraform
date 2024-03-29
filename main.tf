variable "vm_name" {
  type = string
  default = "my-test-vm"
}

variable "domain" {
  type = string
  default = "example.com"
}

variable "memory" {
  type = string
  default = "2048"
}

variable "cpu" {
  type = number
  default = 2
}

variable "disk_size" {
  type = number
  default = 10737418240
}

variable "vm_count" {
  type = number
  default = 1
}

variable "installation_image" {
  type = string
  default = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
}

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


###
# Virtual Machine(s)
###

### BEGIN: Cloud init disk ###
data "template_file" "cloudinit" {
  count    = var.vm_count
  template = file("${path.module}/cloud_init.cfg")

  vars = {
   hostname = "${var.vm_name}-${count.index + 1}"
   domain   = var.domain
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  count     = var.vm_count
  name      = "${var.vm_name}-cloudinit-${count.index + 1}.iso"
  user_data = data.template_file.cloudinit[count.index].rendered
  pool      = "default"
}
### END: Cloud init disk ###

### Libvirt volume
resource "libvirt_volume" "cloud_image_disk" {
  name   = "${var.vm_name}-basedisk.img"
  pool   = "default"
  source = var.installation_image
  format = "qcow2"
}

resource "libvirt_volume" "qcow_volume" {
  count          = var.vm_count
  name           = "${var.vm_name}-${count.index + 1}.img"
  base_volume_id = libvirt_volume.cloud_image_disk.id
  pool           = "default"
  size           = var.disk_size
  format         = "qcow2"
}

### BEGIN: Define Virtual Machine to create
resource "libvirt_domain" "virtual_machine" {
  count  = var.vm_count
  name   = "${var.vm_name}-${count.index + 1}"
  memory = var.memory
  vcpu   = var.cpu

  cloudinit = libvirt_cloudinit_disk.cloudinit[count.index].id

  cpu = {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.qcow_volume[count.index].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }
}

output "ips" {
  value = "${libvirt_domain.virtual_machine.*.network_interface.0.addresses.0}"
}
