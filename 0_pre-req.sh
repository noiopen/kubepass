#!/bin/bash
MULTIPASS=multipass
KUBECTL=kubectl
HELM=helm
WSK=wsk
if ! "$MULTIPASS" -h >/dev/null
then
	echo "Install multipass"
	echo "sudo snap install multipass"
	exit 1
fi
if ! "$KUBECTL" -h >/dev/null
then
        echo "Install kubectl"
        echo "sudo snap install kubectl"
        exit 1
fi
if ! "$HELM" -h >/dev/null
then
        echo "Install helm"
        echo "sudo snap install helm"
        exit 1
fi
if ! "$WSK" -h >/dev/null
then
        echo "Install wsk"
        echo "You can download binary from https://github.com/apache/openwhisk-cli/releases"
        exit 1
fi
echo "Pre-requisites are ok!"
