#!/bin/sh
##
# Script to remove the rrdcached/librenms service and statefulset.
##

echo
echo "Removing some rrdcached/librenms resources."
echo
kubectl delete svc,statefulset rrdcached
kubectl delete svc,statefulset librenms

echo
echo "Show reserved persistent volume claims."
echo
kubectl get pv
