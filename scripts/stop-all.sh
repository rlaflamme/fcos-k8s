#!/usr/bin/sh

ansible -i proxmox2.lan, all -m shell -a 'for vmid in 201 202 203 204 205 206; do qm stop $vmid; done'

