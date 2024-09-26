#!/bin/bash
clear
PULUMI="$HOME/.pulumi/bin"

echo -e "Verificando Pulumi"
PULUMI="$HOME/.pulumi/bin"
[ -d "$PULUMI" ] && echo -e "Esta instalado\n" || $(curl -fsSL https://get.pulumi.com | sh)
$(echo "export PATH=$PATH:$PULUMI")

[ -f "$PULUMI/../credentials.json" ] && echo "" || $(cp $(pwd)/../credentials.json $PULUMI/../credentials.json)
$(echo "pulumi login")
if [ -f ".env" ]; then
    ENV=($(cat .env))
    for v in "${ENV[@]}"; do 
        $(echo "export $v")
    done
    $(echo "pulumi destroy -y")
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