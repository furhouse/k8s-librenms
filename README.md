# LibreNMS Deployment Demo for Kubernetes on Minikube (i.e. running on local workstation)

An example project demonstrating the deployment of two LibreNMS Stateful Sets via Kubernetes on Minikube (Kubernetes running locally on a workstation).

Contains example Kubernetes YAML resource files (in the 'distributed/standalone' folder) and associated Kubernetes based Shell scripts (in the 'scripts' folder) to configure the environment and deploy a LibreNMS Stateful Set, both a standalone and distributed setup.

## Quick Links

* [Standalone Setup](#21-standalone-librenms-deployment-steps)
* [Distributed Setup](#31-distributed-librenms-deployment-steps)

## 1 How To Run

### 1.1 Prerequisites

Ensure the following dependencies are already fulfilled on your host Linux/Windows/Mac Workstation/Laptop:

1. The [VirtualBox](https://www.virtualbox.org/wiki/Downloads) hypervisor has been installed.
2. The [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) command-line tool for Kubernetes has been installed.
3. The [Minikube](https://github.com/kubernetes/minikube/releases) tool for running Kubernetes locally has been installed.
4. The Minikube cluster has been started, inside a local Virtual Machine, using the following command (also includes commands to check that kubectl is configured correctly to see the running minikube pod):

```
$ minikube start
$ kubectl get nodes
$ kubectl describe nodes
$ kubectl get services
```

## 2 Standalone LibreNMS on Kubernetes

### 2.1 Standalone LibreNMS Deployment Steps

1. LibreNMS depends on MySQL/MariaDB, and to bootstrap a single MySQL database, execute the following:

```
$ cd scripts
$ ./deploy_mysql.sh
```

2. To deploy the LibreNMS Service, execute the following:

```
$ ./deploy_standalone_librenms.sh
```

3. Re-run the following command, until the librenms-0 pod has successfully started ("Status=Running"; usually takes about a minute).

```
$ kubectl get po -l app=librenms
```

4. Execute the following command, to validate the LibreNMS installation.

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php validate.php"
```

You should now have a LibreNMS Stateful Set initialised, backed by a MySQL deployment.

You can also view the the state of the deployed environment, via the Kubernetes dashboard, which can be launched in a browser with the following command: `$ minikube dashboard`


### 2.2 Example Tests to Validate If LibreNMS Is Working

Use this section to prove:

1. The LibreNMS web interface is working as intended.
2. Devices can be added and polled.
3. Data is retained even when the LibreNMS StatefulSet is removed and then re-created (by virtue of re-using the same Persistent Volume Claims).

#### 2.2.1 Web Interface Test

Use minikube to find the LibreNMS URL, so you can connect to the web interface using your browser:

```
$ minikube service librenms --url
> http://192.168.99.100:31971
```

Out of the box, a single user is created during deployment:

```
username: admin
password: admin
email: test@example.com
```

You should see an empty LibreNMS dashboard.

#### 2.2.2 Polling Devices Test

To test if LibreNMS is able to poll devices, add a device through the web interface or use `$ kubectl exec`:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php addhost.php example.com public v2c"
```

Now wait for the every-5-minute poller cronjob to complete, and use either the web interface or `$ kubectl exec` to validate if the device has been polled:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cat /opt/librenms/logs/librenms.log"
```

#### 2.2.3 Data Persistence Test

To see if Persistent Volume Claims really are working, run a script to drop the Service & StatefulSet (thus stopping the librenms pod) and then a script to re-create them again:

```
$ ./delete_standalone_service.sh
$ ./recreate_standalone_service.sh
$ kubectl get po -l app=librenms
```

As before, keep re-running the last command above, until you can see that "librenms" pod and their containers have been successfully started again. Then use `$ kubectl exec` to validate the LibreNMS installation, and use your browser to check the web interface:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php validate.php"
$ minikube service  librenms --url
> http://192.168.99.100:31971
```

You should see that the graphs of the device you have added earlier, are still present..

### 2.4 Tearing down the Standalone LibreNMS StatefulSet

Run the following script to undeploy the LibreNMS Service & StatefulSet.

```
$ ./teardown_standalone.sh
$ ./teardown_mysql.sh
```

If you want, you can shutdown the Minikube virtual machine with the following command.

```
$ minikube stop
```

## 3 Distributed LibreNMS on Kubernetes

### 3.1 Distributed LibreNMS Deployment Steps

1. LibreNMS depends on MySQL/MariaDB, and to bootstrap a single MySQL database, execute the following:

```
$ cd scripts
$ ./deploy_mysql.sh
```

2. To deploy the LibreNMS Service, execute the following:

```
$ ./deploy_distributed_librenms.sh
```

3. Re-run the following command, until the librenms-0 pod has successfully started ("Status=Running"; usually takes about a minute).

```
$ kubectl get po -l app=librenms
```

4. Execute the following command, to validate the LibreNMS installation.

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php validate.php"
$ kubectl exec -ti librenms-pollers-0 -- su -p librenms -c "cd /opt/librenms && php validate.php"
```

You should now have a LibreNMS Stateful Set initialised, backed by a MySQL deployment.

You can also view the the state of the deployed environment, via the Kubernetes dashboard, which can be launched in a browser with the following command: `$ minikube dashboard`


### 3.2 Example Tests to Validate If LibreNMS Is Working

Use this section to prove:

1. The LibreNMS web interface is working as intended.
2. Devices can be added and polled.
3. Data is retained even when the LibreNMS StatefulSet is removed and then re-created (by virtue of re-using the same Persistent Volume Claims).

#### 3.3.1 Web Interface Test

Use minikube to find the LibreNMS URL, so you can connect to the web interface using your browser:

```
$ minikube service librenms --url
> http://192.168.99.100:31971
```

Out of the box, a single user is created during deployment:

```
username: admin
password: admin
email: test@example.com
```

You should see an empty LibreNMS dashboard.

#### 3.3.2 Polling Devices Test

To test if LibreNMS is able to poll devices, add a device through the web interface or use `$ kubectl exec`:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php addhost.php example.com public v2c"
```

Now wait for the every-5-minute poller cronjob to complete, and use either the web interface or `$ kubectl exec` to validate if the device has been polled:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cat /opt/librenms/logs/librenms.log"
```

#### 3.3.3 Data Persistence Test

To see if Persistent Volume Claims really are working, run a script to drop the Service & StatefulSet (thus stopping the librenms pod) and then a script to re-create them again:

```
$ ./delete_distributed_service.sh
$ ./recreate_distributed_service.sh
$ kubectl get po -l app=librenms
$ kubectl get po -l app=rrdcached
```

As before, keep re-running the last command above, until you can see that "librenms" pod and their containers have been successfully started again. Then use `$ kubectl exec` to validate the LibreNMS installation, and use your browser to check the web interface:

```
$ kubectl exec -ti librenms-0 -- su -p librenms -c "cd /opt/librenms && php validate.php"
$ minikube service  librenms --url
> http://192.168.99.100:31971
```

You should see that the graphs of the device you have added earlier, are still present..

### 3.4 Tearing down the Distributed LibreNMS StatefulSet

Run the following script to undeploy the LibreNMS Service & StatefulSet.

```
$ ./teardown_distributed.sh
$ ./teardown_mysql.sh
```

If you want, you can shutdown the Minikube virtual machine with the following command.

```
$ minikube stop
```

## 4 Project Details

### 4.1 Factors Addressed by This Project

* Deployment of a LibreNMS on a local Minikube Kubernetes platform.
* Use of Kubernetes StatefulSets and PersistentVolumeClaims to ensure data is not lost when containers are recycled.
* Proper configuration of a LibreNMS StatefulSet for fault tolerance.

### 4.2 Factors to Be Addressed by This Project

* Securing the LibreNMS installtion with SSL certificates.
* Disabling Transparent Huge Pages to improve performance _(this is disabled by default in the Minikube host nodes)_.
* Disabling NUMA to improve performance.
* Controlling CPU & RAM resource allocation.
* Adding a [replicated MySQL setup](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/).

### 4.3 Factors to Be Potentially Addressed by This Project

* TBD

### 4.4 Acknowledgements

* [Run a Single-Instance Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/), re-used the MySQL deployment.
* [pkdone/minikube-mongodb-demo by pkdone](https://github.com/pkdone/minikube-mongodb-demo), re-used script and [README.md](https://github.com/pkdone/minikube-mongodb-demo/blob/master/README.md) layout.
