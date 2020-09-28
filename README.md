# deploy-scripts

Deployment scripts for the different CODA-19 components.

## Bootstrap

Ensure `curl` is installed:

```bash
yum install -y curl
```

Download bootstrap script, execute it and complete informations:

```bash
curl -s https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/scripts/bootstrap.sh | bash
```
