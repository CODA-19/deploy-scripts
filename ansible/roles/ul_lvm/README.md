
ul_lvm
======

Ce role permet de gérer les différentes composantes de stockage (PVs, VGs, LVs, FSs, mounts, ...) à l'aide du Logical Volume Manager (LVM).

Outre l'installation des dépendances, l'inclusion de ce rôle n'effectue rien s'il n'est pas activé explicitement à l'aide de la variable ul_lvm_enabled ne retourne pas _vrai_.

Le rôle permet:
- la détection de nouveaux bus/devices/disks SCSI
- la détection de l'expansion de disques existants
- création des PVs, VGs et LVs- la détection de nouveaux disques sur les bus SCSI
- création des systèmes de fichiers et des points de montage désirés
- expansion automatique des LVs et FSs associés

Ces fonctionnalités sont particulièrement intéressantes dans les environnements où les block devices sont augmentés dynamiquement en taille même lorsque la machine l'utilise. C'est notamment le cas des environnements de virtualisation tels Hyper-V.

Requirements
------------

Ce role est autoportant et ne nécessite rien en dehors d'Ansible et des tâches du présent rôle.

Role Variables
--------------
Voici la liste des variables avec leurs valeurs par défaut.

Activation des tâches de gestion de type LVM:
```yaml
ul_lvm_enabled: false
```

Activation de la commande pvresize:
```yaml
ul_lvm_pvresize_enabled: false
```

Il est possible, lorsque requis, d'executer la commande pvresize sur les disques configurés. Cela permet d'étendre automatiquement les physical volumes qui ont été augmentés en taille. Toutefois, activer systématiquement cette option fait en sorte d'effectuer des invalidations au niveau de certaines configurations et caches LVM. Il faut donc activer cette option que lorsque requis, idéalement en ligne de commande (option -e) lors de l'invocation du playbook.

La structure de définition des PV, VG, LV, FS, MOUNT, etc. est vide par défaut:

```yaml
ul_lvm_groups: []
```

Pour bien comprendre l'essence même du rôle, voici quelques exemples pouvant être utiles.

Exemple #1: utilisation d'un seul VG et deux LVs

```yaml
ul_lvm_groups:
  - vgname: VGPgDefault
    disks:
      - "/dev/sdb"
    create: true

    lvnames:
      - lvname: LVPgWAL
        size: 10g
        create: true
        filesystem: xfs
        mount: true
        mount_point: /srv/pgsql/wal

      - lvname: LVPgData
        size: +100%FREE
        create: true
        filesystem: xfs
        mount: true
        mount_point: /srv/pgsql/data
```

Exemple #2 utilisation de plusieurs VG

```yaml
ul_lvm_groups:
  - vgname: VGPgWAL
    create: true
    disks:
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:1"
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:2"

    lvnames:
      - lvname: LVPgWAL
        size: +100%FREE
        create: true
        opts: "--stripes 2 --stripesize 512"
        filesystem: xfs
        mount: true
        mount_point: /srv/pgsql/wal

  - vgname: VGPgData
    create: true
    disks:
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:3"
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:4"
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:5"
      - "/dev/disk/by-path/acpi-VMBUS:00-scsi-0:0:0:6"

    lvnames:
      - lvname: LVPgData
        size: +100%FREE
        create: true
        opts: "--stripes 4 --stripesize 512"
        filesystem: xfs
        mount: true
        mount_point: /srv/pgsql/data        

```

Dependencies
------------
S.O.

Example Playbook
----------------
S.O.

License
-------
S.O.

Author Information
------------------
Bruno Lavoie <bruno.lavoie@dti.ulaval.ca>
