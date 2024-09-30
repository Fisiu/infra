resource "proxmox_vm_qemu" "vm" {
  for_each = { for id, config in var.vm_configs : id => config }

  depends_on = [
    null_resource.cloud_init_config_files
  ]

  target_node = var.target_node
  clone       = each.value.clone
  name        = each.value.name
  agent       = each.value.agent

  disks {
    scsi {
      scsi0 {
        disk {
          size     = each.value.disk_size
          storage  = "local-lvm"
          asyncio  = "native"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    model    = "virtio"
    bridge   = each.value.network_bridge
    tag      = each.value.network_vlan
    firewall = each.value.network_firewall
    macaddr  = each.value.network_mac
  }

  sockets  = 1
  cores    = each.value.cores
  memory   = each.value.memory
  scsihw   = "virtio-scsi-single"
  boot     = "order=scsi0"

  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"
  cicustom  = "user=local:snippets/cloud_init_${each.value.name}_user_data_vm.yml"
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

resource "local_file" "cloud_init_user_data_file" {
  for_each = { for id, config in var.vm_configs : id => config }

  content = templatefile("${path.module}/userdata.tftpl", {
    hostname = each.value.name,
    password = each.value.password
    ssh_keys = each.value.ssh_pub_keys
    # packages = var.packages
  })
  filename = "${path.module}/cloud-init/${each.value.name}-user-data"
}

resource "null_resource" "cloud_init_config_files" {
  for_each = { for id, config in var.vm_configs : id => config }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = var.ssh_host
      user     = var.ssh_user
      password = var.ssh_password
    }

    inline = [
      "echo 'Hello, world!'"
    ]
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[each.key].filename
    destination = "/var/lib/vz/snippets/cloud_init_${each.value.name}_user_data_vm.yml"

    connection {
      type     = "ssh"
      host     = var.ssh_host
      user     = var.ssh_user
      password = var.ssh_password
    }
  }
}
