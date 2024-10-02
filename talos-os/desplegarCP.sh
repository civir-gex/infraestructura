#!/bin/bash
OUT="$HOME/.talos/out"

while [ ! "$ON" ]; do
    ON=$(./chkip.sh $1 | grep up)
    [ "$ON" ] && break
    ./esperar.sh 3 "a la maquina $1. Revisa que este en linea"
done

$(talosctl apply-config --insecure -n $1 --file $OUT/controlplane.yaml)

while [ ! "$OFF" ]; do
    OFF=$(./chkip.sh $1 | grep down)
    ./esperar.sh 3 "a que la maquina $1 se apage       "
done

while [ ! "$RST" ]; do
    RST=$(./chkip.sh $1 | grep up)
    ./esperar.sh 3 "reinicio de la maquina $1          "
done

echo "ControlPlane instalado en la maquina $1          "