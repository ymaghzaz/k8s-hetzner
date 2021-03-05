# Terraform Kubernetes on Hetzner Cloud

This repository will help to setup a Kubernetes Cluster with [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) on [Hetzner Cloud](https://www.hetzner.com/cloud?country=us).

### Initial setup

create a token in hetzner console.

![Hetzner Cloud](docs/token.png)


## Usage

To create a kubernetes with one master and 2 nodes (machine type cx11)

```
$ terraform init
$ terraform apply -var="hcloud_token=token" -var="node_count=2"
```

you can create kubernetes with one or multiple node by update the node_count variable in terraform command

```
$ terraform init
$ terraform apply -var="hcloud_token=token" -var="node_count=1"
```

you can update the machine type for both the master and the node :

```
$ terraform apply -var="hcloud_token=token"  -var="master_type=cx11"-var="node_type=cx21" 
```


## Container Storage Interface driver for Hetzner Cloud


1. Create a secret containing the token:

```yaml
   # secret.yml
   apiVersion: v1
   kind: Secret
   metadata:
     name: hcloud-csi
     namespace: kube-system
   stringData:
     token: YOURTOKEN
   ```

   and apply it:
   ```
   kubectl apply -f <secret.yml>
   ```
   

2. Deploy the CSI driver and wait until everything is up and running:

   Have a look at our [Version Matrix](README.md#versioning-policy) to pick the correct deployment file.
   ```
   kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v1.5.1/deploy/kubernetes/hcloud-csi.yml
   ```


3. To verify everything is working, create a persistent volume claim and a pod
   which uses that volume:
   
```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: csi-pvc
   spec:
     accessModes:
     - ReadWriteOnce
     resources:
       requests:
         storage: 10Gi
     storageClassName: hcloud-volumes
   ---
   kind: Pod
   apiVersion: v1
   metadata:
     name: my-csi-app
   spec:
     containers:
       - name: my-frontend
         image: busybox
         volumeMounts:
         - mountPath: "/data"
           name: my-csi-volume
         command: [ "sleep", "1000000" ]
     volumes:
       - name: my-csi-volume
         persistentVolumeClaim:
           claimName: csi-pvc
```

   Once the pod is ready, exec a shell and check that your volume is mounted at `/data`.

   ```
   kubectl exec -it my-csi-app -- /bin/sh
   ```
   
more info : [Container Storage Interface driver for Hetzner Cloud](https://github.com/hetznercloud/csi-driver)


## Cloud controller manager 

Now that we have access to the cluster, we need to install the Hetzner cloud controller manager so that we can use load balancers and run workloads on the nodes:

```

kubectl -n kube-system create secret generic hcloud --from-literal=token=<hcloud API token> --from-literal=network=default
kubectl apply -f  https://raw.githubusercontent.com/hetznercloud/hcloud-cloud-controller-manager/master/deploy/ccm.yaml

```

# Load Balancers

Load Balancer support is implemented in the Cloud Controller as of
version v1.6.0. For using the Hetzner Cloud Load Balancers you need to
deploy a `Service` of type `LoadBalancer`.
 
[more](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/master/docs/load_balancers.md)

# Example 

```yaml
# hello-kubernetes.custom-message.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-custom
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes-custom
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes-custom
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes-custom
  template:
    metadata:
      labels:
        app: hello-kubernetes-custom
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.9
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: I just deployed this on Kubernetes!
```

```bash
$ kubectl apply -f yaml/hello-kubernetes.custom-message.yaml
```
