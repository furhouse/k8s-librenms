#!/bin/sh
##
# Script to remove the components of the standalone LibreNMS setup.
##

echo
echo "Removing LibreNMS Pollers Stateful Set."
echo
kubectl delete cm librenms-pollers-conf
kubectl delete statefulset librenms-pollers
sleep 3

# kubectl delete -f ../standalone/librenms-statefulset.yaml
echo
echo "Removing LibreNMS Stateful Set."
echo
kubectl delete secret librenms-admin-user
kubectl delete cm librenms-conf
kubectl delete svc,statefulset librenms
sleep 3

echo
echo "Removing rrdcached Stateful Set."
echo
kubectl delete svc,statefulset rrdcached
sleep 3

echo
echo "Removing memcached Stateful Set."
echo
kubectl delete svc,statefulset memcached
sleep 3

echo
echo "Removing persistent volume claims."
echo
kubectl delete pvc -l app=librenms
kubectl delete pvc -l app=rrdcached
