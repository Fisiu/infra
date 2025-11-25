# Download openSUSE MicroOS cloud image
cloud-init is supported only in openstack image
```
mkdir -p /var/lib/vz/template/qcow
wget -P /var/lib/vz/template/qcow \
https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-OpenStack-Cloud.qcow2
```

# Create a VM template
## 1. Set VM variables for latter use:
```
export VM_ID=9000 \
export VM_NAME="microos" \
export VM_IMAGE=/var/lib/vz/template/qcow/openSUSE-MicroOS.x86_64-OpenStack-Cloud.qcow2 \
export VM_STORAGE="local-lvm"
```

## 2. Create VM as base for template:
```
qm create "${VM_ID}" \
  --name "${VM_NAME}" \
  --description "Created on $(date)<br>https://opensuse.org" \
  --ostype l26 \
  --agent enabled=1 \
  --bios seabios \
  --machine q35 \
  --scsihw virtio-scsi-pci \
  --cpu cputype=host \
  --memory 512 \
  --vga qxl \
  --net0 virtio,bridge=vmbr0,tag=10
```

## 3. Import the cloud image (it does not work, thats why we use ISO)
```
qm disk import "${VM_ID}" "${VM_IMAGE}" "${VM_STORAGE}"
```

## 4. Attach the disk to the VM and set it as boot
```
qm set "${VM_ID}" --boot order=scsi0 \
  --scsi0 "${VM_STORAGE}":vm-"${VM_ID}"-disk-0,cache=writeback,discard=on,ssd=1
```

## 5. Convert the VM into a template
```
qm template "${VM_ID}"
```
