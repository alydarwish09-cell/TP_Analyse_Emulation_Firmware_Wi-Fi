# TP 1 — Analyse Statique avec Binwalk

## Objectifs
* Extraire le firmware d'un routeur Wi-Fi (D-Link DIR-300 REVB)
* Identifier le système de fichiers et les composants
* Rechercher des informations sensibles et des vulnérabilités

## Étape 1 : Téléchargement du firmware
Nous avons sélectionné le firmware public du routeur **D-Link DIR-300 REVB**, version `2.15.B01_WW`. Ce routeur a fait l'objet de nombreuses vulnérabilités par le passé, ce qui en fait une cible idéale pour l'apprentissage.

Le fichier a été téléchargé depuis les serveurs FTP publics de D-Link :
```bash
wget "https://support.dlink.com/resource/products/DIR-300/REVB/DIR-300_REVB5_FIRMWARE_2.15.B01_WW.BIN" -O firmware.bin
```

Vérification du fichier :
```bash
$ file firmware.bin
firmware.bin: data
$ ls -lh firmware.bin
-rw-rw-r-- 1 ubuntu ubuntu 3.5M Jan 25  2021 firmware.bin
```

## Étape 2 : Analyse avec Binwalk
Nous utilisons `binwalk` pour analyser l'en-tête et les sections compressées du firmware.

```bash
$ binwalk firmware.bin

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             DLOB firmware header, boot partition: "dev=/dev/mtdblock/2"
108           0x6C            LZMA compressed data, properties: 0x5D, dictionary size: 33554432 bytes, uncompressed size: 3479564 bytes
1179756       0x12006C        PackImg section delimiter tag, little endian size: 9446656 bytes; big endian size: 2461696 bytes
1179788       0x12008C        Squashfs filesystem, little endian, version 4.0, compression:lzma, size: 2459712 bytes, 1473 inodes, blocksize: 131072 bytes, created: 2013-07-12 02:07:02
```

**Observations :**
1. L'en-tête `DLOB` indique la partition de démarrage.
2. Un noyau Linux compressé en `LZMA` commence à l'offset `108` (0x6C).
3. Le système de fichiers principal est un **SquashFS** version 4.0, avec compression `lzma`, commençant à l'offset `1179788` (0x12008C).

## Étape 3 : Extraction du firmware
L'extraction récursive s'effectue avec `binwalk -Me`. Cependant, ce firmware utilise une compression LZMA non-standard modifiée par le constructeur (fréquent chez D-Link/TP-Link). L'outil `sasquatch` ou `firmware-mod-kit` est nécessaire pour extraire correctement le SquashFS.

```bash
$ binwalk -Me firmware.bin
```

Après extraction via `firmware-mod-kit` (`extract-firmware.sh`), nous obtenons le système de fichiers racine (`rootfs`).

## Étape 4 : Exploration du filesystem
Nous explorons la structure du système de fichiers embarqué.

```bash
$ cd rootfs/
$ ls -la
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 bin
drwxr-xr-x  9 ubuntu ubuntu 4096 Apr  1 06:59 dev
drwxr-xr-x 10 ubuntu ubuntu 4096 Apr  1 06:59 etc
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 home
drwxr-xr-x 10 ubuntu ubuntu 4096 Apr  1 06:59 htdocs
drwxrwxr-x  4 ubuntu ubuntu 4096 Apr  1 06:59 lib
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 mnt
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 proc
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 sbin
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 sys
lrwxrwxrwx  1 ubuntu ubuntu    8 Apr  1 06:59 tmp -> /var/tmp
drwxr-xr-x  5 ubuntu ubuntu 4096 Apr  1 06:59 usr
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 var
drwxr-xr-x  2 ubuntu ubuntu 4096 Apr  1 06:59 www
```

## Étape 5 : Analyse des fichiers critiques

### 1. Fichiers de mots de passe (`/etc/passwd` et `/etc/shadow`)
Contrairement à un système Linux classique, ces fichiers n'existent pas directement dans `/etc/` sur ce firmware. Les comptes sont générés dynamiquement au démarrage et stockés dans `/var/passwd`. 
Le fichier de configuration par défaut `/etc/defnodes/defaultvalue.xml` révèle le compte administrateur :
```xml
<account>
    <count>1</count>
    <max>1</max>
    <entry>
        <name>admin</name>
        <password></password>
        <group>0</group>
    </entry>
</account>
```
**Vulnérabilité critique :** Le routeur est configuré en usine avec le compte `admin` et **aucun mot de passe**.

### 2. Scripts d'initialisation (`/etc/init.d/` et `/etc/init0.d/`)
Les scripts de démarrage révèlent des services potentiellement sensibles. Le script `/etc/init0.d/S80telnetd.sh` est particulièrement intéressant :
```bash
is_default=`xmldbc -g /runtime/device/devconfsize`
if [ "$1" = "start" ] && [ "$is_default" = "0" ]; then
    if [ -f "/usr/sbin/login" ]; then
        image_sign=`cat /etc/config/image_sign`
        telnetd -l /usr/sbin/login -u Alphanetworks:$image_sign -i br0 &
    else
        telnetd &
    fi
```
**Observation :** Un service Telnet caché (backdoor) est démarré si la configuration est celle par défaut. Le nom d'utilisateur est `Alphanetworks` et le mot de passe est généré à partir de la signature de l'image (`wrgn49_dlob_dir300b5`).

### 3. Interface web (`/htdocs/`)
L'interface web utilise des scripts CGI (`/htdocs/cgibin`) et du PHP embarqué. De nombreux services (HTTP, UPnP, SSDP, HNAP) sont exposés, augmentant considérablement la surface d'attaque.


