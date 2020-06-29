#!/bin/bash
set -x

CMD="${1:-help}"
NUM="${2:-2}"
MEM="${3:-4}"
DISK="${4:-15}"
VCPU="${5:-1}"

MULTIPASS=multipass

if ! "$MULTIPASS" -h >/dev/null 
then echo "Install multipass"
     echo "sudo snap install multipass"
     exit 1
fi

build() {
   COUNT="$1"
   ARGS_MASTER="$2"
   ARGS_WORKERS="$3"
   "$MULTIPASS" launch -n kube-master $ARGS_MASTER
   for (( I=1 ; I<= $COUNT; I++))
      do "$MULTIPASS" launch -n "kube-node-$I" $ARGS_WORKERS
   done
   "$MULTIPASS" exec kube-master -- sudo snap install microk8s --classic
   "$MULTIPASS" exec kube-master -- sudo /snap/bin/microk8s.start
   "$MULTIPASS" exec kube-master -- sudo usermod -a -G microk8s ubuntu
   "$MULTIPASS" exec kube-master -- sudo chown -f -R ubuntu ~/.kube
   for (( I=1 ; I<= $COUNT; I++))
      do "$MULTIPASS" exec "kube-node-$I" -- sudo snap install microk8s --classic
         "$MULTIPASS" exec "kube-node-$I" -- sudo usermod -a -G microk8s ubuntu
         "$MULTIPASS" exec "kube-node-$I" -- sudo chown -f -R ubuntu ~/.kube
         JOIN=$("$MULTIPASS" exec kube-master -- /snap/bin/microk8s.add-node | tail -n2 | head -n1)
         JOIN=$(echo $JOIN | sed 's/ *$//g')
	 "$MULTIPASS" exec "kube-node-$I" -- /snap/bin/$JOIN
      done
   "$MULTIPASS" exec kube-master -- /snap/bin/microk8s.enable dns storage knative
   echo "Ready!"
}

destroy() {
   COUNT="$1"
   echo "Deleting kube-master"
   "$MULTIPASS" -v delete kube-master
   for (( I=1 ; I<= $COUNT; I++))
   do  echo "Deleting kube-node-$I"
       "$MULTIPASS" delete "kube-node-$I"
   done
   "$MULTIPASS" -v purge
}

are_you_sure() {
   read -p "Are you sure? " -n 1 -r
   echo ""
   if [[ $REPLY =~ ^[Yy]$ ]]
   then return
   fi
   echo "Aborting..."
   exit 1
}


config() {
    if test -f ~/.kube/config
    then old=~/.kube/config.$(date +"%s")
         mv ~/.kube/config "$old"
         echo "Renamed ~/.kube/config to $old"
     fi
    "$MULTIPASS" exec kube-master -- /snap/bin/microk8s.config >~/.kube/config
    if ! kubectl get nodes
    then echo "please install kubectl"
    fi
}

case "$CMD" in
 create)
   echo "Creating Kubernetes Cluster: master ${MEM}G 2cpu, $NUM workers with ${VCPU} cpu, ${MEM}G mem, ${DISK}G disk"
   build $NUM "-c 2 -d ${DISK}G -m ${MEM}G" "-c $VCPU -d ${DISK}G -m ${MEM}G"
   config
 ;;
 destroy)
   echo "Destroying the cluster"
   are_you_sure
   destroy $NUM
 ;;
 config)
    config
 ;;
 nodes)
   "$MULTIPASS" exec kube-master -- sudo kubectl get nodes
 ;;
 *)
    echo "usage: (create|config|destroy) [#workers] [mem] [disk] [#vcpu]"
    echo "mem and disk are in giga, workers and vcpu a count"
    echo "defaults: 2 workers with 1 vcpu with 4G mem 15G disk"
  ;;
esac
