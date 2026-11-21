#!/bin/bash
# Creates a VM for Proxmox Datacenter Manager on a Proxmox VE node and boots the installer.
# Download the PDM ISO first: node > local > ISO Images > Download from URL.
# Usage: STORAGE=local-zfs ISO=proxmox-datacenter-manager_1.1-1.iso ./create-pdm-vm.sh
set -euo pipefail
ID=${ID:-$(pvesh get /cluster/nextid)}
STORAGE=${STORAGE:?set STORAGE (see: pvesm status)}
ISO=${ISO:?set ISO (see: ls /var/lib/vz/template/iso)}

# UEFI (OVMF + q35) and the default CPU type. With legacy BIOS + cpu=host the installed system
# hung at "Booting from Hard Disk..." on this hardware; switching to this combination fixed it.
qm create "$ID" --name pdm --ostype l26 --cores 2 --cpu x86-64-v2-AES --memory 4096 \
  --bios ovmf --machine q35 --efidisk0 "$STORAGE:1,efitype=4m,pre-enrolled-keys=0" \
  --scsihw virtio-scsi-single --scsi0 "$STORAGE:20" --net0 virtio,bridge=vmbr0 \
  --ide2 "local:iso/$ISO,media=cdrom" --boot 'order=scsi0;ide2' --agent 1 --onboot 1
qm start "$ID"
echo "VM $ID started - open its Console and run the installer."
echo "After the first boot shows 'login:', eject the ISO:  qm set $ID --ide2 none,media=cdrom"
