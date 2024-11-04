#!/usr/bin/sh

/usr/bin/ansible -i proxmox2.lan, all -m shell -a 'for vmid in 201 202 203 204 205 206; do qm shutdown $vmid; done'

