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

## install flux cli

Solution uses flux to sync resources to EKS cluster, so please install flux cli. Refer brew install fluxcd/tap/flux

```bash
brew install fluxcd/tap/flux
```

# apply terraform (up)

Fork this repo and change variables to run to create resources for you. It's recommended to create a branch from main and use the branch instead of using `main` as all the commits done by the the terraform would remain in a branch and you can discard the branch once you destroy the environment.

Update the terraform.tfvars as per you.

```
OWNER_EMAIL           = "xxx@xxx.xxx"
GITHUB_OWNER          = "<your-github-account>"
GITHUB_TOKEN          = "<your-github--token>"
REPOSITORY_NAME       = "dev-lab-aws"
REPOSITORY_VISIBILITY = "public"
BRANCH                = "a-branch" # change the branch


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

## run

To run, make use of a small script located in `./script/up.sh`

```bash
./script/up.sh
```

> **_RETRY:_** If it fails, try one more time. There is an unknown issue where sometimes it fails for the first time.

## DNS resolution

Solution creates a private hosted zone to work with and use from the kubernetes cluster. You can resolve this from your machine once you are connected to VPN.

One caveat is if you have any software which manages your DNS server then you may have to either disable it or use a VPN client which allows you to change the DNS configuration while connecting to VPN. e.g. If you have Cloudflare WARP installed then you can disable it while you are working with the VPN and enable it once you don't need it. After disabling you may need to reset the WIFI or Ethernet connection to reestablish the internet connection and then connect to VPN. To test you can run nslookup `vault.<resource_prefix>.local` it should resolve to a private IP address in 10.0.0.0/16 range.

## force sync git (optional)

Flux is scheduled to sync Git Repository evert minute, if you would like to force sync then run `./scripts/sync_git.sh` to sync immediately.

# set local variables

After successful run, you may run `source ./scripts/post_run.sh` to set local env variables to connect to vault and eks. Alternatively, you may run these as below.

### (alternatively) setup kubeconfig

If you didn't run post_run.sh then you can manually setup.

```bash
export EKS_NAME=$(terraform output -json | jq -r '.eks_cluster_name.value | values')
export AWS_REGION=$(terraform output -json | jq -r '.aws_region.value | values')
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_NAME
```

### (alternatively) get vault token

Export vault token

```bash
export S3_BUCKET_VAULT_OBJECT=$(terraform output -json | jq -r '.vault_s3_bucket.value | values')

export VAULT_ADDR=https://$(terraform output -json | jq -r '.vault_url.value | values')

aws s3 cp $S3_BUCKET_VAULT_OBJECT vault-secret.json 
export VAULT_TOKEN=$(jq -r '.root_token | values' vault-secret.json)
```

# (Optional) add custom certs to trust store

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

# rough notes

<!-- kubectl patch deployment coredns \                       
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]' -->
