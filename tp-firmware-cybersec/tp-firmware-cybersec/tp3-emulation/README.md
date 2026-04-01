# TP 3 — Émulation avec Firmadyne et QEMU

## Objectifs

- Lancer le firmware en environnement isolé
- Observer le comportement des services réseau

---

## Concept

L'émulation consiste à reproduire le fonctionnement d'un appareil matériel sur son ordinateur, comme si cet appareil était virtuellement présent. On simule ainsi un routeur réel sans avoir le matériel physique.

```
[Firmware binaire] → [Firmadyne] → [QEMU VM] → [Services réseau accessibles]
```

---

## Étapes

### 1. Cloner et configurer Firmadyne

```bash
git clone https://github.com/firmadyne/firmadyne.git
cd firmadyne
./setup.sh
```

> ℹ️ Firmadyne nécessite des dépendances : `qemu`, `PostgreSQL`, `python3`. Le `setup.sh` les installe automatiquement.

### 2. Importer le firmware

```bash
./scripts/extract.sh firmware.bin
```

Cette étape :
- Extrait le filesystem du firmware
- Identifie le système de fichiers (squashfs, cramfs…)
- Stocke les données en base PostgreSQL

### 3. Identifier l'architecture

```bash
./scripts/getArch.sh
```

**Architectures supportées par Firmadyne :**
- MIPS (big/little endian)
- ARM

### 4. Créer l'image QEMU

```bash
./scripts/makeImage.sh <firmware_id>
```

### 5. Lancer l'émulation

```bash
./scripts/run.sh <firmware_id>
```

### 6. Accéder à la VM émulée

```bash
# Depuis la VM émulée ou depuis l'hôte :
ifconfig

# Accéder à l'interface web
http://IP_EMULEE

# SSH si disponible
ssh root@IP_EMULEE
```

---

## Alternative : QEMU manuel (pour firmware simple)

```bash
# MIPS big-endian
qemu-system-mips -M malta -kernel vmlinux-malta -hda disk.img \
  -append "root=/dev/sda1" -nographic

# ARM
qemu-system-arm -M vexpress-a9 -kernel zImage \
  -dtb vexpress-v2p-ca9.dtb -sd disk.img -nographic
```

---

## Vérification de l'émulation

```bash
# Dans la VM émulée :
ps aux              # Processus actifs
netstat -tulnp      # Ports en écoute
cat /proc/version   # Version du noyau émulé
```

---

## Remplir vos observations

➡️ Complétez le fichier [`observations.md`](./observations.md)
