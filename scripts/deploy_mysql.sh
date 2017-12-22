#!/bin/sh
##
# Script to deploy a Kubernetes MySQL Deployment Set.
##

echo
echo "Deploying MySQL."
echo
kubectl apply -f ../standalone/mysql.yaml
echo "Sleeping 20 seconds, before attempting to create a mysql user."
sleep 20

DBUSER="CREATE USER 'newuser'@'%' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'%';"

kubectl run mysql-client --image=mysql:5.6 -i --rm --restart=Never --\
  mysql -h mysql <<EOF
${DBUSER}
EOF
