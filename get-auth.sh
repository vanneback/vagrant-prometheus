#!/bin/bash
#Prints credentials for service account in arg 1
#If no arguments are given the service account will default to "default"

if [ -z $1 ]; then
  SA=default
else 
  SA=$1
fi

echo "Service account = $SA"
SECRET=`kubectl get sa $SA -o json  | jq '.secrets[0].name' -r`

echo "API URL="
kubectl cluster-info | grep 'Kubernetes master' | awk '/http/ {print $NF}'

echo "\nTOKEN="
kubectl get secret $SECRET -o jsonpath="{['data']['token']}" | base64 -d
#kubectl get secret $SECRET -o jsonpath="{['data']['token']}" 
echo ""
echo "\nCA="
kubectl get secret $SECRET -o jsonpath="{['data']['ca\.crt']}" | base64 -d
