# LibreNMS Deployment Demo for Kubernetes on Minikube (i.e. running on local workstation)

An example project demonstrating the deployment of two LibreNMS Stateful Sets via Kubernetes on Minikube (Kubernetes running locally on a workstation).

Contains example Kubernetes YAML resource files (in the 'distributed/standalone' folder) and associated Kubernetes based Shell scripts (in the 'scripts' folder) to configure the environment and deploy a LibreNMS Stateful Set, both a standalone and distributed setup.

## Quick Links

* [Standalone Setup](#21-standalone-librenms-deployment-steps)
* [Distributed Setup](#31-distributed-librenms-deployment-steps)
* [Customizing LibreNMS with Kubernetes Objects](#4-customizing-the-librenms-setup)

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

## 4 Customizing the LibreNMS Setup

### 4.1 Kubernetes Secrets

The [Secret Object](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L2) contains base64 encoded strings for the admin username, password and email address.

```
$ echo "YWRtaW4=" | base64 --decode
> admin
$ echo "dGVzdEBleGFtcGxlLmNvbQ==" | base64 --decode
> test@example.com
```

Create your own secrets by base64 encoding the items:

```
$ echo -n "admin" | base64
YWRtaW4=
$ echo -n "test@example.com" | base64
dGVzdEBleGFtcGxlLmNvbQ==
```

### 4.2 Kubernetes ConfigMap

The [ConfigMap Object](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L12) contains additional LibreNMS configuration, which will be mounted at `/opt/librenms/conf.d`.

If you add additional key-value pairs to the ConfigMap, you'd also need to add them to the [items](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L148) volume.

The ConfigMap keys basically contain PHP snippets, which allows for easy modification of the default LibreNMS configuration. The [Distrubuted ConfigMap Object](https://github.com/furhouse/k8s-librenms/blob/master/distributed/librenms-statefulset-pollers.yaml#L2) is an example of multiple snippets in one ConfigMap.

### 4.3 Kubernetes Service

To access the LibreNMS web interface, a [Service Object](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L31) is defined. This service targets the LibreNMS Pods based on the `app: librenms` selector, and ties port `80` of the Pod to port `31971` on the Minikube VM. The service is accessible outside of the Kubernetes cluster because `type` is set to `NodePort`. The `nodePort` is also used in the LibreNMS `BASE_URL` [variable](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L76).

Other services, for example [memcached in the distributed setup](https://github.com/furhouse/k8s-librenms/blob/master/distributed/memcached-statefulset.yaml#L2), is only available inside of the Kubernetes cluster. Port 11211 of the Pod is exposed, and can be used by other Pods.

You can access services that are exposed to the Minikube VM by using `$ minikube service <name> --url`:

```
$ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP                      1h
librenms     NodePort    10.109.170.147   <none>        80:31971/TCP,443:32459/TCP   1h
memcached    ClusterIP   None             <none>        11211/TCP                    1h
mysql        ClusterIP   None             <none>        3306/TCP                     1h
rrdcached    ClusterIP   None             <none>        42217/TCP                    1h

$ minikube service librenms --url
http://192.168.99.100:31971
```

```
$ kubectl run -it --rm --restart=Never nslookup --image=busybox nslookup librenms
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      librenms
Address 1: 10.109.170.147 librenms.default.svc.cluster.local

```

```
$ kubectl run -it --rm --restart=Never nslookup --image=busybox nslookup memcached
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      memcached
Address 1: 172.17.0.5 memcached-0.memcached.default.svc.cluster.local
```

### 4.4 Kubernetes StatefulSet

The [StatefulSet Controller](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L49) manages the deployment of the different Pods for the standalone or distributed setup.

Initially, the setup of LibreNMS will prepare the database and create an admin user, which is managed by the [initContainer](https://github.com/furhouse/k8s-librenms/blob/master/standalone/librenms-statefulset.yaml#L63). The initContainer should finish gracefully before the LibreNMS container will be started. If the initContainer fails (for example, when MySQL is unavailable), the Pod will be restarted until it succeeds.

In the distributed setup, other services are also declared as StatefulSets, for example rrdcached, since it requires persistent storage. In retrospect, I think I might refactor memcached and pollers as [Deployment Controllers](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), since those services do not require storage or bootstrapping, and should be stateless.

## 5 Project Details

### 5.1 Factors Addressed by This Project

* Deployment of a LibreNMS on a local Minikube Kubernetes platform.
* Use of Kubernetes StatefulSets and PersistentVolumeClaims to ensure data is not lost when containers are recycled.
* Proper configuration of a LibreNMS StatefulSet for fault tolerance.

### 5.2 Factors to Be Addressed by This Project

* Securing the LibreNMS installtion with SSL certificates.
* Disabling Transparent Huge Pages to improve performance _(this is disabled by default in the Minikube host nodes)_.
* Disabling NUMA to improve performance.
* Controlling CPU & RAM resource allocation.
* Adding a [replicated MySQL setup](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/).

### 5.3 Factors to Be Potentially Addressed by This Project

* TBD

### 5.4 Acknowledgements

* [Run a Single-Instance Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/), re-used the MySQL deployment.
* [pkdone/minikube-mongodb-demo by pkdone](https://github.com/pkdone/minikube-mongodb-demo), re-used script and [README.md](https://github.com/pkdone/minikube-mongodb-demo/blob/master/README.md) layout.
