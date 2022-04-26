# dev-lab-aws

# local tools

## vault cli for local
It would be a good idea to have vault cli locally

```bash
brew tap hashicorp/tap       
brew install hashicorp/tap/vault
```
## install openvpn
brew install --cask openvpn-connect



# apply terraform
Fork this repo and https://github.com/rohits-dev/dev-lab-k8s-aws 
Change variables to run to create resources for you.



Update the terraform.tfvars as per you.


```
GITHUB_OWNER = "<your-github-account>"
GITHUB_TOKEN = "<your-github--token>"
REPOSITORY_NAME = "dev-lab-k8s-aws"
REPOSITORY_VISIBILITY = "public"
BRANCH = "main"
TARGET_PATH = ""

AWS_REGION      = "<your-desired-region>"
RESOURCE_PREFIX = "<your-name/any-prefix>"
```

## apply changes
Due to the dependency of EKS for kube config to add any kubernetes manifests, run the terraform apply in 2 steps. 

There is a variable ADD_FLUXCD which is set to false in tfvars, so first run wouldn't create any k8s resources. Run the below to create the VPC, EKS and etc.

```bash
terraform plan 
terraform apply --auto-approve
```
> **_NOTE:_** Once the resources are provisioned, it would have configured the open vpn client, **_connect the VPN_** and run the below command. 

```bash
terraform plan -var="ADD_FLUXCD=true"
terraform apply -var="ADD_FLUXCD=true" --auto-approve
```

> **TIP:_**  If you get dns resolution error, please disconnect the VPN and connect again, sometimes it fails to resolve the dns. 

# setup kubeconfig

Change the name & region of the cluster as per your variables.

```bash
export EKS_NAME=$(terraform output -json | jq -r '.eks_cluster_name.value | values')
export AWS_REGION=$(terraform output -json | jq -r '.aws_region.value | values')
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_NAME
```
# get vault token 



```bash
export S3_BUCKET_VAULT_OBJECT=$(terraform output -json | jq -r '.vault_s3_bucket.value | values')

export VAULT_ADDR=https://$(terraform output -json | jq -r '.vault_url.value | values')

aws s3 cp $S3_BUCKET_VAULT_OBJECT vault-secret.json 
export VAULT_TOKEN=$(jq -r '.root_token | values' vault-secret.json)
```

# add custom certs to trust store
For ease you can run below commands to add the root ca to trusted root on your mac

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./generated_certs/root_ca.crt
sudo security remove-trusted-cert -d  ./generated_certs/root_ca.crt   
```
