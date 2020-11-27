# RUNC

To fetch a specific runc version in this folder:

```
export VERSION=v1.0.0-rc92
wget https://github.com/opencontainers/runc/releases/download/${VERSION}/runc.amd64     -O runc.${VERSION}
wget https://github.com/opencontainers/runc/releases/download/${VERSION}/runc.sha256sum -O runc.${VERSION}.sha256sum
```

Available releases: https://github.com/opencontainers/runc/releases
