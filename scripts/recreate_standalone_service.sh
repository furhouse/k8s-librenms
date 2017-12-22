#!/bin/sh
##
# Script to recreate the librenms service and statefulset.
##

echo
echo "Recreating librenms resources."
echo
kubectl create -f ../standalone/librenms-recreate.yaml
sleep 3

echo
echo "Show pods, rerun kubectl get po if the pods aren't running yet."
kubectl get po
