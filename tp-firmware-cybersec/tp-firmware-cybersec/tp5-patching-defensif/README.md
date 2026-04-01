# TP 5 — Patching Défensif

## Objectif

- Corriger des failles de sécurité sans introduire de malwares

---

> ⚠️ Ce TP consiste à **corriger** des vulnérabilités identifiées lors des TPs précédents. Toute modification doit être documentée et justifiée dans `observations.md`.

---

## Étapes

### 1. Corriger un mot de passe

```bash
# Se placer dans le filesystem extrait
cd ~/IoT/formation-Jour2/_firmware.bin.extracted/

# Modifier le fichier passwd
vi etc/passwd

# Exemple : remplacer root:x:0:0:... par root:!:0:0:... (désactivation du compte)
# Ou générer un nouveau hash :
openssl passwd -1 "NouveauMotDePasse"
# Puis remplacer le hash dans /etc/shadow
```

**Format `/etc/passwd` :**
```
root:x:0:0:root:/root:/bin/sh
       ^
       hash ou 'x' (si dans shadow) ou '!' (désactivé)
```

### 2. Désactiver un service non sécurisé

```bash
# Désactiver telnetd
chmod -x bin/telnetd
# Vérification :
ls -la bin/telnetd

# Désactiver d'autres services dangereux
chmod -x bin/ftpd 2>/dev/null
chmod -x usr/sbin/dropbear 2>/dev/null
```

### 3. Sécuriser un script CGI

```bash
# Identifier les scripts vulnérables
find . -name "*.cgi" -exec grep -l "system\|exec\|popen" {} \;

# Éditer le script vulnérable
vi www/cgi-bin/ping.cgi
```

**Exemple de code vulnérable :**
```sh
#!/bin/sh
IP=$1
ping -c 1 $IP   # VULNÉRABLE : injection possible avec "127.0.0.1; cat /etc/passwd"
```

**Correction :**
```sh
#!/bin/sh
IP=$1
# Valider le format IP (chiffres et points uniquement)
if ! echo "$IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
    echo "Adresse IP invalide"
    exit 1
fi
ping -c 1 "$IP"
```

### 4. Reconstruction du firmware

```bash
# Repackager le filesystem en squashfs
mksquashfs rootfs/ new_firmware.bin -comp lzma

# Vérification
binwalk new_firmware.bin

# Sauvegarder le firmware patché
cp new_firmware.bin ~/IoT/formation-Jour2/new_firmware_patched.bin
```

---

## Checklist des correctifs défensifs

| Action | Commande | Justification |
|--------|---------|---------------|
| Désactiver Telnet | `chmod -x bin/telnetd` | Protocole non chiffré |
| Changer mots de passe | Modifier `/etc/shadow` | Credentials par défaut dangereux |
| Valider les entrées CGI | Regex + whitelist | Prévenir les injections |
| Supprimer les clés privées | `rm etc/ssh/ssh_host_*` | Clés uniques par appareil |
| Désactiver FTP | `chmod -x bin/ftpd` | Protocole non chiffré |

---

## Sauvegardez vos patches

Placez vos fichiers modifiés dans le dossier `patches/` :

```bash
mkdir -p patches/etc
mkdir -p patches/www/cgi-bin
cp etc/passwd patches/etc/passwd.patched
cp www/cgi-bin/ping.cgi patches/www/cgi-bin/ping.cgi.patched
```

---

## Remplir vos observations

➡️ Complétez le fichier [`observations.md`](./observations.md)
