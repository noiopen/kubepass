# Deploying microk8s cluster using multipass

## Prerequisites

```
./0_pre-req.sh
```
will alert you if something is missing, you need:
- multipass

on ubuntu, you can snap it:
```
sudo snap install multipass --classic
```
- kubectl

you can snap it too, or install with:
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
```
- helm

snap:
```
sudo snap install helm
```
- wsk

You can download binary from https://github.com/apache/openwhisk-cli/releases

## Setup

```
./1_install_microk8s.sh create
```
This creates a cluster with default configuration (4G memory, 15G disk and 2 VCPU).

At the end, your kubernetes cluster should be accessible from your machine, knative is deployed too.

```
./2_deploy_openwhisk.sh
```
This deploys openwhisk in your cluster, wait ow-dev-controller-0 pod to be running (it tooks about 5 minutes) and you should be able to access openwhisk.

## Test

```
wsk -i list
```

## Clean up

```
./1_install_microk8s.sh destroy
```

Happy whisking!
