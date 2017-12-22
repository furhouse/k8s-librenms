#!/bin/sh
##
# Script to remove the components of the standalone LibreNMS setup.
##

# kubectl delete -f ../standalone/librenms-statefulset.yaml
echo
echo "Removing LibreNMS Stateful Set."
echo
kubectl delete secret librenms-admin-user
kubectl delete cm librenms-conf
kubectl delete svc,statefulset librenms
sleep 3

echo
echo "Removing persistent volume claims."
kubectl delete pvc -l app=librenms
