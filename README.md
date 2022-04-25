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
Fork the repo and change variables to run to create resources for you.

dev-lab-k8s-aws

Update the terraform.tfvars as per you.


```
GITHUB_OWNER = "<your-github-account>"
GITHUB_TOKEN = "<your-github--token>"
REPOSITORY_NAME = "dev-lab-k8s-aws"
REPOSITORY_VISIBILITY = "private"
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

# setup kubeconfig
aws eks update-kubeconfig --region eu-west-2 --name rohit-eks-1

# add custom certs to trust store
For ease you can run below commands to add the root ca to trusted root on your mac

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./generated_certs/root_ca.crt
sudo security remove-trusted-cert -d  ./generated_certs/root_ca.crt   
```
