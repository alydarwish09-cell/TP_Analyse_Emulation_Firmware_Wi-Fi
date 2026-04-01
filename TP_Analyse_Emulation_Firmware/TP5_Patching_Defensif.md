# TP 5 — Patching Défensif

## Objectif
* Corriger des failles de sécurité sans introduire de malwares
* Reconstruire le firmware avec les correctifs

## Étape 1 : Corriger le mot de passe administrateur par défaut
La première faille critique est l'absence de mot de passe administrateur dans la configuration par défaut du routeur. Nous devons modifier le fichier XML de configuration par défaut pour forcer un mot de passe sécurisé.

**Fichier à modifier :** `rootfs/etc/defnodes/defaultvalue.xml`

Nous modifions le nœud `<account>` pour ajouter un mot de passe par défaut robuste (ex: `Ch@ng3M3!` en clair ou hashé selon le support du firmware) :
```xml
<account>
    <count>1</count>
    <max>1</max>
    <entry>
        <name>admin</name>
        <password>Ch@ng3M3!</password>
        <group>0</group>
    </entry>
</account>
```

```bash
$ sed -i 's/<password><\/password>/<password>Ch@ng3M3!<\/password>/g' rootfs/etc/defnodes/defaultvalue.xml
```

## Étape 2 : Désactiver le service Telnet non sécurisé (Backdoor)
Le script `/etc/init0.d/S80telnetd.sh` démarre une backdoor Telnet si la configuration est celle par défaut. Nous allons désactiver complètement ce script pour fermer cette porte dérobée.

**Fichier à modifier :** `rootfs/etc/init0.d/S80telnetd.sh`

Deux approches sont possibles :
1. Rendre le script inopérant en le vidant ou en commentant les lignes.
2. Retirer les droits d'exécution du binaire `telnetd` ou du script.

Nous optons pour la désactivation du binaire `telnetd` lui-même pour garantir qu'aucun autre script ne puisse le lancer :
```bash
$ chmod -x rootfs/usr/sbin/telnetd
```
Ou bien, nous supprimons simplement le script d'initialisation :
```bash
$ rm rootfs/etc/init0.d/S80telnetd.sh
```

## Étape 3 : Sécuriser les scripts CGI
Les binaires CGI comme `/htdocs/cgibin` (qui inclut `hedwig.cgi` et `HNAP1`) sont compilés, ce qui rend leur modification directe complexe sans le code source. Cependant, nous pouvons mitiger les attaques de type RCE (exécution de code à distance) en appliquant des filtres ou en désactivant les endpoints vulnérables non essentiels.

**Mitigation : Désactiver HNAP**
Si le protocole HNAP (Home Network Administration Protocol) n'est pas strictement nécessaire, nous pouvons supprimer son script d'initialisation ou son point de montage.

```bash
$ rm -rf rootfs/htdocs/HNAP1/
```
De plus, nous pouvons supprimer les liens symboliques vulnérables pointant vers `cgibin` :
```bash
$ rm rootfs/htdocs/web/hedwig.cgi
```

## Étape 4 : Reconstruction du firmware
Une fois les modifications effectuées sur le système de fichiers `rootfs`, nous devons reconstruire l'image SquashFS et recréer le firmware complet avec l'outil `firmware-mod-kit` ou `mksquashfs`.

```bash
$ mksquashfs rootfs/ new_squashfs.bin -comp lzma -b 131072
```

Pour reconstruire le firmware complet (incluant l'en-tête DLOB et le kernel) :
```bash
$ /tmp/fmk/build-firmware.sh /tmp/fmk-extracted/
```
Le nouveau firmware sécurisé sera généré dans le dossier `/tmp/fmk-extracted/fmk/new-firmware.bin` et pourra être flashé sur le routeur.

---
**Auteur :** Manus AI
