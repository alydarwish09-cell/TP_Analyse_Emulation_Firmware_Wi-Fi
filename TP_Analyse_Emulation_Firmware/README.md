# TP Firmware IoT — Jour 2 : Analyse et Sécurisation d'un Firmware Embarqué

## Présentation du TP

Ce dépôt contient la réalisation complète du TP Firmware Jour 2, portant sur l'analyse de sécurité d'un firmware de routeur Wi-Fi grand public réel. Le firmware étudié est celui du **routeur D-Link DIR-300 REVB**, version `2.15.B01_WW`, un appareil qui a fait l'objet de nombreuses vulnérabilités documentées.

L'objectif pédagogique est de parcourir l'ensemble du cycle d'analyse d'un firmware IoT : de l'extraction statique jusqu'au patching défensif, en passant par le reverse engineering et l'émulation.

---

## Firmware analysé

| Propriété | Valeur |
|-----------|--------|
| **Constructeur** | D-Link |
| **Modèle** | DIR-300 REVB |
| **Version** | 2.15.B01_WW |
| **Build** | 2.15 (2013-07-12) |
| **Architecture** | MIPS 32 bits (Little Endian) |
| **Noyau Linux** | 2.6.33.2 |
| **Bibliothèque C** | uClibc 0.9.30.1 |
| **Système de fichiers** | SquashFS 4.0 (compression LZMA) |
| **Image Sign** | `wrgn49_dlob_dir300b5` |

---

## Structure du dépôt

```
TP_Complet/
├── README.md                          # Ce fichier
├── Rapport_Final.md                   # Rapport de synthèse complet
│
├── TP1_Analyse_Statique.md            # TP1 : Analyse avec Binwalk
├── TP2_Reverse_Engineering.md         # TP2 : Reverse Engineering (strings, readelf)
├── TP3_Emulation.md                   # TP3 : Émulation avec Firmadyne/QEMU
├── TP4_Analyse_Dynamique.md           # TP4 : Analyse dynamique et vulnérabilités
├── TP5_Patching_Defensif.md           # TP5 : Patching défensif et reconstruction
│
├── scripts/
│   ├── 01_analyse_statique.sh         # Script automatisé TP1
│   ├── 02_reverse_engineering.sh      # Script automatisé TP2
│   ├── 03_emulation_firmadyne.sh      # Script automatisé TP3
│   ├── 04_analyse_dynamique.sh        # Script automatisé TP4
│   └── 05_patching_defensif.sh        # Script automatisé TP5
│
├── data/
│   ├── tp1_binwalk_output.txt         # Sortie réelle de binwalk
│   ├── tp2_reverse_engineering_output.txt  # Sortie réelle de strings/readelf
│   ├── vulnerabilites_cve.txt         # CVE documentées (CVE-2019-16920, etc.)
│   ├── filesystem_tree.txt            # Arborescence complète du firmware (1169 fichiers)
│   ├── S80telnetd_original.sh         # Script backdoor original extrait du firmware
│   ├── image_sign.txt                 # Signature de l'image (mot de passe backdoor)
│   └── buildver.txt                   # Version de build du firmware
│
├── patches/
│   ├── fix_admin_password.patch       # Patch : correction mot de passe admin vide
│   └── fix_telnet_backdoor.patch      # Patch : désactivation backdoor Telnet
│
├── captures/                          # Captures d'écran (à compléter en TP)
└── firmware_patched/                  # Firmware reconstruit (à générer en TP)
```

---

## Prérequis

Les outils suivants sont nécessaires pour reproduire ce TP :

```bash
sudo apt-get install -y binwalk squashfs-tools git build-essential \
    liblzma-dev liblzo2-dev zlib1g-dev nmap curl radare2 \
    qemu-system-mips qemu-utils
```

Pour l'extraction du SquashFS LZMA non-standard de D-Link :
```bash
git clone https://github.com/rampageX/firmware-mod-kit /tmp/fmk
cd /tmp/fmk && bash extract-firmware.sh firmware.bin /tmp/fmk-extracted/
```

---

## Résumé des vulnérabilités découvertes

| # | Vulnérabilité | Sévérité | CVE | Correctif |
|---|---------------|----------|-----|-----------|
| 1 | Mot de passe admin vide par défaut | **Critique** | — | `fix_admin_password.patch` |
| 2 | Backdoor Telnet (Alphanetworks) | **Critique** | — | `fix_telnet_backdoor.patch` |
| 3 | RCE via HNAP non authentifié | **Critique** | CVE-2019-16920 | Suppression de `/htdocs/HNAP1/` |
| 4 | Stockage mots de passe en clair | Moyen | CVE-2011-4723 | Chiffrement requis |
| 5 | XSS dans l'interface web | Moyen | CVE-2013-7389 | Validation des entrées |

---

## Utilisation des scripts

Chaque script peut être exécuté indépendamment. Ils sont conçus pour être lancés dans l'ordre.

```bash
# TP1 - Analyse statique
bash scripts/01_analyse_statique.sh

# TP2 - Reverse Engineering
bash scripts/02_reverse_engineering.sh

# TP3 - Émulation (nécessite une VM isolée avec QEMU)
bash scripts/03_emulation_firmadyne.sh

# TP4 - Analyse dynamique (nécessite l'émulation active)
bash scripts/04_analyse_dynamique.sh 192.168.0.1

# TP5 - Patching défensif
bash scripts/05_patching_defensif.sh
```

---

## Avertissement légal

Ce TP est réalisé dans un cadre strictement pédagogique. L'analyse porte sur un firmware public téléchargé depuis les serveurs officiels de D-Link. Toute utilisation des techniques présentées sur des équipements sans autorisation explicite est illégale.

---

**Auteur :** Manus AI
