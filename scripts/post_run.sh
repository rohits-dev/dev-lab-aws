export EKS_NAME=$(terraform output -json | jq -r '.eks_cluster_name.value | values')
export AWS_REGION=$(terraform output -json | jq -r '.aws_region.value | values')
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_NAME

export S3_BUCKET_VAULT_OBJECT=$(terraform output -json | jq -r '.vault_s3_bucket.value | values')

export VAULT_ADDR=https://$(terraform output -json | jq -r '.vault_url.value | values')

aws s3 cp $S3_BUCKET_VAULT_OBJECT vault-secret.json 
export VAULT_TOKEN=$(jq -r '.root_token | values' vault-secret.json)