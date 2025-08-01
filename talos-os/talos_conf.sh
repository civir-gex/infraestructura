#!/bin/bash
PBASE="$HOME/.talos"
OUT="$HOME/.talos/out"
IPB="172.16.1."
VIP=$IPB"10"
CP=($IPB"11" $IPB"12" $IPB"13")
WRK=($IPB"241" $IPB"242" $IPB"243")

[ ! -d "$OUT" ] && mkdir -p $OUT
clear

$(talosctl gen secrets -o $OUT/secrets.yaml --force)
$(talosctl gen config --with-secrets $OUT/secrets.yaml k8sgex https://$VIP:6443 -o $OUT/ --force)
$(talosctl --talosconfig $OUT/talosconfig config endpoint ${CP[0]} ${CP[1]} ${CP[2]})
$(talosctl --talosconfig $OUT/talosconfig config node ${CP[0]} ${CP[1]} ${CP[2]} ${WRK[0]} ${WRK[1]} ${WRK[2]})
$(cp $OUT/talosconfig $OUT/../config)

sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/metallb.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/nfs.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/vip.yaml'  $OUT/controlplane.yaml
sed -i -e '/extraManifests: \[\]/a\' -e '      - https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/metrics-server.yaml'  $OUT/controlplane.yaml
sed -i 's/extraManifests: \[\]/extraManifests:/g'  $OUT/controlplane.yaml

for v in "${CP[@]}"; do 
    ./desplegarCP.sh $v
done

for v in "${WRK[@]}"; do 
    ./desplegarWRK.sh $v
done

while [ ! "$BOOTSTRAP" ]; do
    BOOTSTRAP=$(talosctl containers 2> /dev/null && BOOTSTRAP=true || BOOTSTRAP=false)
    ./esperar.sh 10 "para aplicar bootstrap a la maquina ${CP[0]}               "
    clear
done

talosctl -n ${CP[0]} bootstrap

while [ ! "$VIP_ON" ]; do
    VIP_ON=$(./chkip.sh $VIP | grep up)
    [ "$VIP_ON" ] && break
    ./esperar.sh 10 "a que la VIP este lista                                      "
done

talosctl kubeconfig -n $VIP --talosconfig=$PBASE/config --force
talosctl kubeconfig -n $VIP --talosconfig=$PBASE/config $OUT --force

./esperar.sh 20 "para asegurar que los pods esten en linea"
kubectl get nodes -o wide
kubectl get pods -A

kubectl apply -f https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/kubernetes-skooner.yaml

kubectl get secret skooner-sa -n default -o jsonpath={".data.token"} | base64 -d > $OUT/long_token.txt

echo "Para ingresar al dashboard del cluster ve a la direccion VIP e ingresa el token localizado en el archivo $HOME/.talos/out/long_token.txt"

kubectl apply -f https://raw.githubusercontent.com/civir-gex/Extras/refs/heads/main/npm.yaml

echo
echo "Ingresa a Nginx Proxy Manager en la primera direccion del pool, puerto 81, con las credenciales:"
echo "Email: admin@example.com"
echo "Password: changeme"