
```bash
flux create tenant tenant-a \
    --with-namespace=tenant-a-staging \
    --with-namespace=tenant-a-production \
    --with-namespace=tenant-a-flux \
    --export > rbac.yaml

flux create source git tenant-a \
    --namespace=tenant-a-flux \
    --url=https://github.com/rohits-dev/tenant-a \
    --branch=main \
    --export > ./sync.yaml

flux create kustomization tenant-a \
    --namespace=tenant-a-flux \
    --service-account=tenant-a \
    --source=GitRepository/tenant-a \
    --path="./tenant-a" \
    --export >> ./sync.yaml

```