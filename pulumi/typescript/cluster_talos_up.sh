#!/bin/bash
shopt -s expand_aliases

pbase="$HOME/talos2"

if [ -d "$pbase" ] && rm -rf "$pbase/*" || mkdir "$pbase"


# rm -rf $HOME/talos2
# export PROXMOX_VE_ENDPOINT=https://10.177.73.109:8006
# export PROXMOX_VE_PASSWORD=aabo110295
# export PROXMOX_VE_USERNAME=root@pam
# export PROXMOX_VE_INSECURE=true

# pulumi up -y