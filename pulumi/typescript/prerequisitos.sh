#!/bin/bash
RUTA="$HOME/.local/bin"
PULUMI="$HOME/.pulumi/bin"
PBASE="$HOME/.talos"
encontrado=false

clear

ChecaPath() {
    IFS=':' read -ra PATH_DIRS <<< "$PATH"
    for dir in "${PATH_DIRS[@]}"; do
        if [ "$1" == "$dir" ]; then
            encontrado=true
            break
        fi
    done

    if [ ! $encontrado ]; then
        export PATH="$1:$PATH"
        echo " " >> $HOME/.bashrc
        echo 'export PATH="'$1':'$PATH'"' >> $HOME/.bashrc
    fi

    if ! grep -q "$1:" <<< cat $HOME/.zshrc; then
        echo " " >> $HOME/.zshrc
        echo 'export PATH="'$1':'$PATH'"' >> $HOME/.zshrc
    fi
}

# verificando que se encuentre las herramientas necesarias
if [ -d "$PBASE" ]; then
    $(mv -f $PBASE "$PBASE.old")
    $(mkdir $PBASE)
else
    $(mkdir $PBASE) 
fi

[ ! -d "$PULUMI" ] && $(curl -fsSL https://get.pulumi.com | sh)

if  ! ([ -f "$RUTA/talosctl" ] && [ -f "$RUTA/kubectl" ] && [ -f "$RUTA/helm" ]); then 
    PQT="$RUTA/../cmd_k8s.zip"
    DPQT="$RUTA/../k8s"
    HTTP_CODE=$(curl 'https://drive.usercontent.google.com/download?id=1wRxC9Zqae-05TnyW3b1c-Qry3sqXGp4X&confirm=xxx' -o $PQT)
    $(echo "unzip -o $PQT -d $DPQT" )
    $(echo "chmod -R +x $DPQT")
    $(echo "mv -f $DPQT/* $RUTA/")
    $(rm -rf "$PQT" "$DPQT" )
fi

# verifica si el path de ejecutables se encuentra en la variable path, si no esta lo agrega
ChecaPath $RUTA
ChecaPath $PULUMI

[ ! -f "$PULUMI/../credentials.json" ] $(cp $(pwd)/../credentials.json $PULUMI/../credentials.json)

if [ -f ".env" ]; then
    sed -i '/export PROXMOX_VE/d' $HOME/.zshrc
    sed -i '/export PROXMOX_VE/d' $HOME/.bashrc
    ENV=($(cat .env))
    for v in "${ENV[@]}"; do 
        v=$(echo $v | sed 's/=/="/' ) 
        echo "export $v\"" >> $HOME/.zshrc
        echo "export $v\"" >> $HOME/.bashrc
    done
else
    echo "El archivo de variables de entorno para proxmox no existe"
    echo "se creara uno pero debes completar los datos los datos del archivo .env"
    $(touch .env)
    $(echo "PROXMOX_VE_ENDPOINT=https://<ip_servidor>:8006" >> .env)
    $(echo "PROXMOX_VE_PASSWORD=<contraseña>" >> .env)
    $(echo "PROXMOX_VE_USERNAME=root@pam" >> .env)
    $(echo "PROXMOX_VE_INSECURE=true" >> .env)
    echo -e "Ejecuta nuevamente el script cuando estes listo"
    exit 0
fi



# if ! grep -q "$RUTA" <<< "$PATH"; then
#     p="$RUTA$PATH"
#     echo $PATH
#     export PATH="$p"
#     echo $PATH
#     echo 'export PATH="'$p'"' >> $HOME/.zshrc
#     echo $PATH
# fi

[ -d "$PBASE.old" ] && $(rm -rf $PBASE) && $(mv -f "$PBASE.old" $PBASE) 







