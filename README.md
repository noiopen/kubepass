# Deploying microk8s cluster on multipass

## Prerequisites

```
0_pre-req.sh
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
This should create a cluster with default configuration (4G memory, 15G disk and 2 VCPU)
At the end, you should have a kubernetes cluster accessible from your machine, knative is deployed too.

```
./2_deploy_openwhisk.sh
```
At the end, you should be able to access openwhisk deployment through wsk cli, ie:
```
wsk -i list
```

Happy whisking!


