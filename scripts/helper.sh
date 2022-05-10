  kubectl create secret generic ca-secret -ncert-manager \
  --from-file=tls.crt=generated_certs/root_ca.crt \
  --from-file=tls.key=generated_certs/root_ca.key
# reinstall vault, will generate new keys & token
  helm uninstall vault -nvault
  kubectl delete pvc audit-vault-0 data-vault-0 audit-vault-1 data-vault-1 audit-vault-2 data-vault-2 -nvault
  kubectl delete job vault-init -nvault
