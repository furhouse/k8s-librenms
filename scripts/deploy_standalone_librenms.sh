#!/bin/sh
##
# Script to deploy a Kubernetes LibreNMS Stateful Set.
##

echo
echo "Deploying Standalone LibreNMS Stateful Set."
echo
kubectl create -f ../standalone/librenms-statefulset.yaml

echo
echo "If you wish to see the progress of the initContainer, you could use docker logs:"
echo "docker ps -a | awk '/librenmsdb/ { print \$1, \$NF }'"
echo "53009d407a51 k8s_init-librenmsdb_librenms-0_default_d12b79c4-e365-11e7-842d-080027fde215_0"
echo "docker logs -f 53009d407a51"
echo
