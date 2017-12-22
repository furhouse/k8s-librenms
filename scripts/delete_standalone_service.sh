#!/bin/sh
##
# Script to remove the librenms service and statefulset.
##

echo
echo "Removing some librenms resources."
echo
kubectl delete svc,statefulset librenms

echo
echo "Show reserved persistent volume claims."
echo
kubectl get pv
