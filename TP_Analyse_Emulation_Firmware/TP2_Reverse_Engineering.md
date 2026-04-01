# TP 2 — Reverse Engineering

## Objectifs
* Identifier les fonctions clés du firmware
* Comprendre les mécanismes d'authentification et les services
* Repérer d'éventuelles backdoors

## Étape 1 : Navigation dans le binaire extrait
Nous nous concentrons sur le fichier binaire principal qui gère l'interface web, `/htdocs/cgibin`, et le démon HTTP `/sbin/httpd`.

```bash
cd ~/IoT/formation-Jour2/squashfs-root/htdocs/
```

## Étape 2 : Vérification du type et architecture
Nous utilisons `file` et `readelf` pour déterminer l'architecture du binaire cible.

```bash
$ file cgibin
cgibin: ELF 32-bit LSB executable, MIPS, MIPS32 version 1 (SYSV), dynamically linked, interpreter /lib/ld-uClibc.so.0, stripped

$ readelf -h cgibin
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           MIPS R3000
  Flags:                             0x50001007, noreorder, pic, cpic, o32, mips32
```
**Observation :** Il s'agit d'un exécutable MIPS 32 bits (Little Endian), typique des routeurs grand public.

## Étape 3 : Analyse des chaînes de caractères (strings)
L'analyse des chaînes de caractères nous permet d'identifier les mots de passe codés en dur, les chemins de fichiers sensibles et les fonctions utilisées.

```bash
$ strings cgibin | grep -i "password\|admin\|login"
authenticationcgi_main
authentication
login_antihacker
weblogin_log
authentication_result
Web login success from %s
Web login failure from %s
AUTHORIZED_GROUP=%d
ERR_UNAUTHORIZED_SESSION
/runtime/login_antihacker/login_fail_count
/runtime/login_antihacker/captcha
login_plaintext
login_digest
```

## Étape 4 : Zones critiques investiguées

### A. Exécution de commandes système
La présence de références à `system` et `popen` dans un binaire web est souvent synonyme de vulnérabilités d'injection de commandes.
```bash
$ strings cgibin | grep -E "system|popen|execve|/bin/sh"
lxmldbc_system
popen
```

### B. Gestion des paramètres utilisateur
L'utilisation de fonctions non sécurisées pour la gestion des chaînes de caractères est une cause majeure de débordements de tampon (Buffer Overflows).
```bash
$ strings cgibin | grep -E "strcmp|strcpy|sprintf|strcat"
sprintf
strcat
strcpy
sobj_strcmp
```
**Observation :** Les fonctions `strcpy` et `sprintf` sont utilisées. Si les entrées utilisateur ne sont pas correctement validées avant d'être passées à ces fonctions, le binaire est vulnérable.

### C. Fichiers sensibles système
```bash
$ strings cgibin | grep "/var/"
/var/session/configsize
/var/session/imagesize
/var/session
/var/passwd
/var/session/sesscfg
```
**Observation :** L'authentification s'appuie sur le fichier temporaire `/var/passwd` généré au démarrage par le script `/etc/defnodes/S90sessions.php` à partir de la configuration par défaut.

## Conclusion de l'analyse statique
L'analyse révèle que l'interface d'administration repose sur un binaire centralisé (`cgibin`) qui multiplexe de nombreux scripts CGI (authentification, firmware update, UPnP). L'utilisation conjointe de `strcpy`/`sprintf` et de `lxmldbc_system` (un wrapper autour de `system()`) indique un risque élevé d'exécution de code à distance (RCE) via l'interface web, comme documenté par exemple dans la vulnérabilité CVE-2019-16920.


