# Download Archlinux cloud image
```
mkdir -p /var/lib/vz/template/qcow
wget -P /var/lib/vz/template/qcow \
https://mirroronet.pl/pub/mirrors/archlinux/images/latest/Arch-Linux-x86_64-cloudimg.qcow2
```

# Create a VM template
Set VM variables for latter use:
```
export VM_ID=9000 \
export VM_NAME="demeter" \
export VM_IMAGE=/var/lib/vz/template/qcow/Arch-Linux-x86_64-cloudimg.qcow2 \
export VM_STORAGE="local-lvm"
```

Create VM as base for template:
```
qm create "${VM_ID}" \
  --name "${VM_NAME}" \
  --description "Created on $(date)<br>https://archlinux.org" \
  --ostype l26 \
  --agent enabled=1 \
  --bios seabios \
  --machine q35 \
  --scsihw virtio-scsi-pci \
  --cpu cputype=host \
  --memory 512 \
  --serial0 socket --vga serial0 \
  --net0 virtio,bridge=vmbr0,tag=10
```

# Import the cloud image (it does not work, thats why we use ISO)
```
qm disk import "${VM_ID}" "${VM_IMAGE}" "${VM_STORAGE}"
```

# Attach the disk to the VM and set it as boot
```
qm set "${VM_ID}" --boot order=scsi0 \
  --scsi0 "${VM_STORAGE}":vm-"${VM_ID}"-disk-0,cache=writeback,discard=on,ssd=1
```

# Convert the VM into a template
```
qm template "${VM_ID}"
```
