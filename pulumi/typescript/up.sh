#!/bin/bash
IPB="172.16.1."
CP=($IPB"11" $IPB"12" $IPB"13")
WRK=($IPB"241" $IPB"242" $IPB"243")
CHKIP="../../talos-os/chkip.sh"
online=false

function handler() 
{
  clear 
  echo "Proceso terminado"
  exit 1
}

clear

trap 'handler' SIGINT

./prerequisitos.sh

./iac_talos.sh

while ! $online; do
    echo "Verificando las VM asignadas a ControlPlane"
    ($CHKIP ${CP[0]} | grep up && $CHKIP ${CP[1]} | grep up && $CHKIP ${CP[2]} | grep up) && cp=true || cp=false
    echo "Verificando las VM asignadas a Worker"
    ($CHKIP ${WRK[0]} | grep up && $CHKIP ${WRK[1]} | grep up && $CHKIP ${WRK[2]} | grep up) && wrk=true || wrk=false
    if $cp && $wrk; then
        online=true
        msg="continuar"
    else 
        online=false
        msg="reintentar"
    fi
     ../../talos-os/esperar.sh 10 "para $msg"
    clear
done

# echo "Para continuar desplegando kubernetes presiona <intro>"
# read -p "Para salir <ctrl>+<c>"

cd ../../talos-os/
./talos_conf.sh
