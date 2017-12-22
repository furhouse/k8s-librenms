#!/bin/sh
##
# Script to remove the MySQL Deployment.
##

echo
echo "Removing MySQL Deployment."
echo
kubectl delete -f ../standalone/mysql.yaml
sleep 3

echo
echo "Removing persistent volume claims."
echo
kubectl delete pvc -l app=librenms
