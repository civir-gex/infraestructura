#!/bin/bash
shopt -s expand_aliases
export PROXMOX_VE_ENDPOINT=https://10.177.73.109:8006
export PROXMOX_VE_PASSWORD=aabo110295
export PROXMOX_VE_USERNAME=root@pam
export PROXMOX_VE_INSECURE=true

pbase="$HOME/.talos"

clear

[ -d "$pbase" ] && $(rm -f $pbase/*.*) || $(mkdir $pbase) 

[ -d "$pbase/out" ] && $(rm -f $pbase/out/*.*) || $(mkdir $pbase/out) 

if [ -d "$pbase/cmd/.pulumi" ] && [ -f "$pbase/cmd/helm" ] && [ -f "$pbase/cmd/kubectl" ] && [ -f "$pbase/cmd/talosctl" ]; then 
    echo "scrips presentes" 
else
    $(rm -rf $pbase/cmd/*.*)
    [ -f "$pbase/cmd_k8s.zip" ] && echo "paquete presente" || HTTP_CODE=$(curl 'https://drive.usercontent.google.com/download?id=1iZO8cjzR57ardswlBZgv4QsZ63EtJ9aI&confirm=xxx' -o $pbase/cmd_k8s.zip)
    $(unzip -o $pbase/cmd_k8s.zip -d $pbase/cmd)
    $(rm -f $pbase/cmd_k8s.zip)
    $(chmod +x $pbase/cmd/.pulumi/bin/pulumi)
fi  

alias t="$pbase/cmd/talosctl"
alias k="$pbase/cmd/kubectl"
alias p="$pbase/cmd/.pulumi/bin/pulumi"

p up -y