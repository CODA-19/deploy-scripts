# JSONKNIFE

This extension is used by AidBox and is not available from official repos.

Since we don't want to install development packages on server, we build extensions
in a container.

Source code: https://github.com/niquola/jsonknife


# Building extension

First start a container like this:

```bash
# For CentOS 7:
podman run --rm -it --name jsonknife_build centos:7

# For CentOS 8:
podman run --rm -it --name jsonknife_build centos:8
```

Install EPEL and update system:

```bash
yum install -y epel-release
yum update -y
```

Install PGDG YUM repository package:

```bash
# For CentOS 7
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# For CentOS 8
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

For CentOS 8, disable postgresql module:

```bash
dnf -qy module disable postgresql
```

For CentOS 7, install SCL:

```bash
yum install -y centos-release-scl
```

Install development packages:

```bash
yum groupinstall -y "Development Tools"

export PGVER=13
yum install -y postgresql${PGVER}-server postgresql${PGVER}-contrib postgresql${PGVER}-devel
```

Clone jsonkife and build accordingly:

```bash
git clone https://github.com/niquola/jsonknife
cd jsonknife

export PATH=/usr/pgsql-${PGVER}/bin:${PATH}
export USE_PGXS=1

make
make install
```

# Getting files

To get resulting files, you must open another terminal and copy files locally:

```bash
export PGVER=13

podman cp jsonknife_build:/usr/pgsql-${PGVER}/share/extension/jsonknife--1.0.sql  .
podman cp jsonknife_build:/usr/pgsql-${PGVER}/share/extension/jsonknife.control .
podman cp jsonknife_build:/usr/pgsql-${PGVER}/lib/jsonknife.so .
podman cp jsonknife_build:/usr/pgsql-${PGVER}/lib/bitcode/jsonknife/jsonknife.bc .
podman cp jsonknife_build:/usr/pgsql-${PGVER}/lib/bitcode/jsonknife/jsonknife.index.bc .
```

After that, you must put these files at the right destinations. This can be deduced from `make install` output that should looks like this:

```
/usr/bin/mkdir -p '/usr/pgsql-13/lib'
/usr/bin/mkdir -p '/usr/pgsql-13/share/extension'
/usr/bin/mkdir -p '/usr/pgsql-13/share/extension'
/usr/bin/install -c -m 755  jsonknife.so '/usr/pgsql-13/lib/jsonknife.so'
/usr/bin/install -c -m 644 .//jsonknife.control '/usr/pgsql-13/share/extension/'
/usr/bin/install -c -m 644 .//jsonknife--1.0.sql  '/usr/pgsql-13/share/extension/'
/usr/bin/mkdir -p '/usr/pgsql-13/lib/bitcode/jsonknife'
/usr/bin/mkdir -p '/usr/pgsql-13/lib/bitcode'/jsonknife/
/usr/bin/install -c -m 644 jsonknife.bc '/usr/pgsql-13/lib/bitcode'/jsonknife/./
cd '/usr/pgsql-13/lib/bitcode' && /usr/bin/llvm-lto -thinlto -thinlto-action=thinlink -o jsonknife.index.bc jsonknife/jsonknife.bc
```
