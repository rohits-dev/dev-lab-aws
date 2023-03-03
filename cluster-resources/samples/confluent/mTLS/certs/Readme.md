k get nodes -o=custom-columns=NODE:.metadata.name,ZONE:.metadata.labels."topology\.kubernetes\.io/zone"

 kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name

kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=ip-10-0-1-231.eu-west-2.compute.internal
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=ip-10-0-1-202.eu-west-2.compute.internal
