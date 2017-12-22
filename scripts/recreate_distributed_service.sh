#!/bin/sh
##
# Script to recreate the rrdcached/librenms service and statefulset.
##

echo
echo "Recreating rrdcached/librenms resources."
echo
kubectl create -f ../distributed/rrdcached-statefulset.yaml
kubectl create -f ../distributed/librenms-recreate.yaml
sleep 3

echo
echo "Show pods, rerun kubectl get po if the pods aren't running yet."
kubectl get po
