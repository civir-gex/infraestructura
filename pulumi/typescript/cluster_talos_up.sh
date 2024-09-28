#!/bin/bash

clear

echo -e "Verificando Pulumi"
PULUMI="$HOME/.pulumi/bin"
[ -d "$PULUMI" ] && echo -e "Esta instalado\n" || $(curl -fsSL https://get.pulumi.com | sh)
$(echo "export PATH=$PATH:$PULUMI")

echo -e "Preparando directorio de trabajo\n"
PBASE="$HOME/.talos"
[ -d "$PBASE" ] && $(rm -f $PBASE/*.*) || $(mkdir $PBASE) 

OUT="$PBASE/out"
[ -d "$OUT" ] && $(rm -f $OUT/*.*) || $(mkdir $OUT)

CMD="$PBASE/cmd"
HELM="$CMD/helm"
KUBECTL="$CMD/kubectl"
TALOSCTL="$CMD/talosctl"
PQT="$PBASE/cmd_k8s.zip"

([ -f "$HELM" ] && [ -f "$KUBECTL" ] && [ -f "$TALOSCTL" ]) && echo "scrips presentes" || HTTP_CODE=$(curl 'https://drive.usercontent.google.com/download?id=1wRxC9Zqae-05TnyW3b1c-Qry3sqXGp4X&confirm=xxx' -o $PBASE/cmd_k8s.zip)
if [ -f "$PQT" ]; then 
    $(unzip -o $PQT -d $CMD) 
    $(chmod -R +x $CMD) 
    $(rm -f $PBASE/cmd_k8s.zip) 
fi

[ -f "$PULUMI/../credentials.json" ] && echo "" || $(cp $(pwd)/../credentials.json $PULUMI/../credentials.json)
$(echo "pulumi login")

if [ -f ".env" ]; then
    ENV=($(cat .env))
    for v in "${ENV[@]}"; do 
        $(echo "export $v")
    done
    $(echo "pulumi up -y")
else
    echo "El archivo de variables de entorno para proxmox no existe"
    echo "se creara uno pero debes completar los datos los datos"
    $(touch .env)
    $(echo "PROXMOX_VE_ENDPOINT=https://<ip_servidor>:8006" >> .env)
    $(echo "PROXMOX_VE_PASSWORD=<contraseña>" >> .env)
    $(echo "PROXMOX_VE_USERNAME=<usuario@reino>" >> .env)
    $(echo "PROXMOX_VE_INSECURE=true" >> .env)
    echo -e "Ejecuta nuevamente el script cuando estes listo"
    exit 0
fi

$(echo "pulumi logout")
echo -e "Instalacion finalizada\n"
echo "Cambia al directorio 'cd ../../talos-os' y ejecutando talos_conf.sh para desplegar el cluster de kubernets\n\n"
../../talos-os/esperar.sh 5
cd ../../talos-os && ./talos_conf.sh