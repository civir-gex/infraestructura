#!/bin/bash

clear

IPb="172.16.1."
PBASE="$HOME/.talos"
CMD="$PBASE/cmd"
OUT="$PBASE/out"
HELM="$CMD/helm"
KUBE="$CMD/kubectl"
TALOS="$CMD/talosctl"

if [ -f "$TALOS" ] && [ -f "$KUBE" ] && [ -f "$HELM" ]; then
    echo -e "Generando secretos\r" 
else
    echo "Faltan archivos, imposible continuar "
    exit 0
fi 

$TALOS gen secrets -o $OUT/secrets.yaml --force
echo -en "Generando archivos de configuracion\r\n"
$TALOS gen config --with-secrets $OUT/secrets.yaml k8sgex https://$IPb"10:6443" -o $OUT/ --force
$TALOS --talosconfig $OUT/talosconfig config endpoint $IPb"11" $IPb"12" $IPb"13"
$TALOS --talosconfig $OUT/talosconfig config node $IPb"11" $IPb"12" $IPb"13" $IPb"241" $IPb"242" $IPb"243"
cp $OUT/talosconfig $OUT/../config
  
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/metallb.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/nfs.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/vip.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/metrics-server.yaml'  $OUT/controlplane.yaml
sed -i 's/extraManifests: \[\]/extraManifests:/g'  $OUT/controlplane.yaml

./esperar.sh 30 "a que esten listas las VM's"

echo -en "Generando ControlPlane 1                                  \r"
$TALOS apply-config --insecure -n $IPb"11" --file $OUT/controlplane.yaml 
./esperar.sh 15 "para generar ControlPlane 2                                  "
$TALOS apply-config --insecure -n $IPb"12" --file $OUT/controlplane.yaml
./esperar.sh 15 "para generar ControlPlane 3                                  "
$TALOS apply-config --insecure -n $IPb"13" --file $OUT/controlplane.yaml
./esperar.sh 160 "a que se aplique la configuración de los ControlPlane"
clear

echo -en "Generando Worker 1                                         \r"
$TALOS apply-config --insecure -n $IPb"241" --file $OUT/worker.yaml
./esperar.sh 15 "para generar Worker 2                                  "
$TALOS apply-config --insecure -n $IPb"242" --file $OUT/worker.yaml
./esperar.sh 15 "para generar Worker 3                                  "
$TALOS apply-config --insecure -n $IPb"243" --file $OUT/worker.yaml
./esperar.sh 160 "a que se aplique la configuración de los Worker"
clear

./esperar.sh 120 "para que los servidores (VM) esten listos"
clear

echo -en "Haciendo Bootstrap                                             \r\n"
$TALOS -n $IPb"11" -e $IPb"11" bootstrap
./esperar.sh 240 "para desplegar el Cluster en todos los nodos"
clear

echo -e "\nAplicando la configuracion para kubectl                         "
$TALOS kubeconfig -n $IPb"10" --talosconfig=$PBASE/config --force
$TALOS kubeconfig -n $IPb"10" --talosconfig=$PBASE/config $OUT --force

# $TALOS kubeconfig -n $IPb"10" -e $IPb"10" --force
# $TALOS kubeconfig -n $IPb"10" -e $IPb"10" $OUT --force

# sed -i "s/$IPb"10":6443/$IPb"11":6443/g" $HOME/.kube/config

# echo "Dotando al cluster de HA mediante VIP"
# $KUBE apply -f vip.yaml

# echo "Estableciendo clase de almacenamiento NFS"
# $KUBE apply -f nfs.yaml

echo "Cluster listo "
# sed -i "s/$IPb"11":6443/$IPb"10":6443/g" $HOME/.kube/config
echo "Agregando dashboard "
$HELM repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
$HELM --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard 

$KUBE apply -f https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/dashboard-admin.yaml
$KUBE 

./esperar.sh 15 "para asegurar que los pods esten en linea"
$KUBE get nodes -o wide
$KUBE get pods -A
$KUBE get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d > $OUT/long_token.txt

echo "El token de administrador lo encontraras en $OUT"
