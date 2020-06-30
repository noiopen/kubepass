#!/bin/bash
set -x

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

MULTIPASS=multipass

"$MULTIPASS" exec kube-master -- /snap/bin/microk8s.enable helm3

"$MULTIPASS" exec kube-master -- /snap/bin/microk8s.kubectl label nodes kube-node-1 openwhisk-role=invoker
"$MULTIPASS" exec kube-master -- /snap/bin/microk8s.kubectl label nodes kube-node-2 openwhisk-role=invoker

INVOKER_IP=$(multipass exec kube-master -- /snap/bin/microk8s.kubectl describe node kube-node-1 | grep InternalIP: | awk '{print $2}')
sed -i "s/<INTERNAL_IP>/$INVOKER_IP/g" mycluster.yaml

helm install owdev ./helm/openwhisk -n openwhisk --create-namespace -f mycluster.yaml

wsk property set --apihost $INVOKER_IP:31001
wsk property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP

echo "Ready!"
echo "Use wsk -i to access you openwhisk deployment"

