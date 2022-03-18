# dev-lab-aws

# VPN Client Auth
VPN Client auth is configured using mutual auth i.e. mTLS which requires certificates to be in ACM. Create a CA and Client cert following https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual and import into ACM. Set the ROOT_CA_ARN in variables with the arn of root CA in ACM.

Upload the configuration in S3 with certificates information so that next time onwards it works. 

>>>
of course this needs improvements.
>>>

# install openvpn
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
Once the resources are provisioned, it would have configured the open vpn client, connect the VPN and run the below command. 

```bash
terraform plan -var="ADD_FLUXCD=true"
terraform apply -var="ADD_FLUXCD=true" --auto-approve
```

# setup kubeconfig
aws eks update-kubeconfig --region eu-west-2 --name <resource-prefix>-eks-1

# add custom certs to trust store
For ease you can run below commands to add the root ca to trusted root on your mac

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./generated_certs/root_ca.crt
sudo security remove-trusted-cert -d  ./generated_certs/root_ca.crt   
```