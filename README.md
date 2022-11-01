# dev-lab-aws
This repository contains terraform resources to spin up an environment in AWS. 
It provisions a VPC, EKS and required resources to make the kubernetes cluster functional.


[![asciicast](https://asciinema.org/a/492624.svg)](https://asciinema.org/a/492624?speed=1)


# local tools

## vault cli for local
It would be a good idea to have vault cli locally

```bash
brew tap hashicorp/tap       
brew install hashicorp/tap/vault
```
## install openvpn
Install openvpn to connect to VPN and accept the GDPR terms and condition so that it opens and ready to be used. TF script will add configuration to it so its necessary that it is ready to be used. 

```bash
brew install --cask openvpn-connect
```


# apply terraform
Fork this repo and change variables to run to create resources for you.


Update the terraform.tfvars as per you.


```
OWNER_EMAIL           = "xxx@xxx.xxx"
GITHUB_OWNER          = "<your-github-account>"
GITHUB_TOKEN          = "<your-github--token>"
REPOSITORY_NAME       = "dev-lab-aws"
REPOSITORY_VISIBILITY = "public"
BRANCH                = "main"


AWS_REGION      = "<your-desired-region>"
RESOURCE_PREFIX = "<your-name-or-any-prefix-you-prefer>"

AWS_AUTH_ROLES = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1" # change role name here
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

# If you want to use an existing vpc, set the vpc id. Also make sure the region is set same as vpc region. 
VPC_ID = "vpc-xxx"

# only set when you are using existing vpc, default is set to use ["*private*", "*Private*", "*PRIVATE*"] and ["*public*", "*Public*", "*PUBLIC*"], in case you have different name then set them here. 

PRIVATE_SUBNETS_NAME_FILTER = ["*my-private-filter*"]
PUBLIC_SUBNETS_NAME_FILTER = ["*my-public-filter*"]
```

## initialize terraform

First initialize the terraform to get all the modules and provider versions.

```bash
terraform init
```

## apply changes
To apply the change, make use of a small script located in `./script/up.sh`

```bash
./script/up.sh
```
> **_RETRY:_** If it fails, try one more time. There is an unknown issue where sometimes it fails for the first time. 

> **_TIP:_**  If you get dns resolution error, please disconnect the VPN and connect again, sometimes it fails to resolve the dns. 

# force sync git
Flux is scheduled to sync Git Repository evert minute, if you would like to force sync then run `./scripts/sync_git.sh` to sync immediately.

# set local variables
After successful run, you may run `./scripts/post_run.sh` to set local env variables to connect to vault and eks. Alternatively, you may run these as below. 

## setup kubeconfig

Change the name & region of the cluster as per your variables.

```bash
export EKS_NAME=$(terraform output -json | jq -r '.eks_cluster_name.value | values')
export AWS_REGION=$(terraform output -json | jq -r '.aws_region.value | values')
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_NAME
```
## get vault token 



```bash
export S3_BUCKET_VAULT_OBJECT=$(terraform output -json | jq -r '.vault_s3_bucket.value | values')

export VAULT_ADDR=https://$(terraform output -json | jq -r '.vault_url.value | values')

aws s3 cp $S3_BUCKET_VAULT_OBJECT vault-secret.json 
export VAULT_TOKEN=$(jq -r '.root_token | values' vault-secret.json)
```

<!-- kubectl patch deployment coredns \                       
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]' -->

    
# add custom certs to trust store
(Optional) For ease you can run below commands to add the root ca to trusted root on your mac

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./generated_certs/root_ca.crt
sudo security remove-trusted-cert -d  ./generated_certs/root_ca.crt   
```

# Tear down
A clean tear down is very important for all the resources to be deleted without leaving dangling resources.

- Make sure all resources which you deployed are deleted, mainly check the persistent volumes, services which are of type load-balancer. Primarily check for any resource which would have created any corresponding AWS resource such as EBS, load balancers.
- to remove all CR for confluent for kubernetes across all namespaces can be deleted by `./script/cleanup-kafka.sh`.


A multi step process to tear down the cluster and other resources is in small script at `./script/down.sh`. Its important to cleanup the k8s cluster before deleting the cluster.

```bash
./script/down.sh
```

If destroy stuck deleting  flux-system ns then edit a few resources and remove the fluxcd finalizers

```bash
k edit gitrepositories flux-system -nflux-system
k edit kustomizations flux-system -nflux-system
k edit kustomizations resources -nflux-system
```
