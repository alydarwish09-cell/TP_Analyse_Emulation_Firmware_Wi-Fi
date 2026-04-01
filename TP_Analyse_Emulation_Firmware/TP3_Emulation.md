# TP 3 — Émulation avec Firmadyne et QEMU

## Objectifs
* Lancer le firmware en environnement isolé
* Observer le comportement des services réseau

L'émulation consiste à reproduire le fonctionnement d'un appareil matériel sur son ordinateur, comme si cet appareil était virtuellement présent.

## Étape 1 : Cloner et configurer Firmadyne
Pour cette étape, nous utiliserons `firmadyne`, un framework automatisé basé sur QEMU pour émuler des firmwares basés sur Linux.

```bash
$ git clone https://github.com/firmadyne/firmadyne.git
$ cd firmadyne
$ ./setup.sh
```

## Étape 2 : Importer le firmware
Nous importons l'image de notre routeur D-Link DIR-300 dans la base de données de Firmadyne.

```bash
$ ./scripts/extract.sh /home/ubuntu/IoT/formation-Jour2/firmware.bin
```
L'outil identifie automatiquement le système de fichiers SquashFS et crée une image du système racine pour l'émulation. L'ID attribué à notre image est `1`.

## Étape 3 : Identifier l'architecture
Firmadyne analyse les binaires du firmware pour déterminer l'architecture matérielle (MIPS Little Endian, comme vérifié lors du TP2).

```bash
$ ./scripts/getArch.sh ./images/1.tar.gz
mipseb
```
**Observation :** Firmadyne détecte l'architecture MIPS.

## Étape 4 : Création de l'image disque
Nous construisons l'image QEMU bootable avec les composants réseau virtuels (interfaces TAP/TUN).

```bash
$ ./scripts/makeImage.sh 1
```

## Étape 5 : Lancer l'émulation
Nous démarrons l'émulateur QEMU avec l'image préparée et nous configurons le réseau virtuel.

```bash
$ ./scripts/inferNetwork.sh 1
$ ./scratch/1/run.sh
```

Le noyau Linux démarre, charge le système de fichiers SquashFS, et exécute les scripts d'initialisation situés dans `/etc/init.d/rcS`. Le serveur web (`httpd`) et les services réseau (UPnP, DHCP) sont démarrés.

## Étape 6 : Accéder à la VM émulée
Une fois le système complètement initialisé, une interface réseau virtuelle est créée sur l'hôte (ex: `tap1`), liée à l'IP par défaut du routeur.

```bash
$ ifconfig tap1
tap1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.2  netmask 255.255.255.0  broadcast 192.168.0.255
```

L'interface web du routeur D-Link est alors accessible depuis le navigateur de la machine hôte :
`http://192.168.0.1`

**Observations :**
L'émulation réussit. Le portail de connexion de l'administration web est affiché. L'analyse réseau montre que le routeur répond aux requêtes ARP et ICMP (ping).


