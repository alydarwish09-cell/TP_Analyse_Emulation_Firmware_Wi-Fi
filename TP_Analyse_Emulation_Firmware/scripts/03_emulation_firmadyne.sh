#!/bin/bash
# ============================================================
# TP3 - Émulation avec Firmadyne et QEMU
# Firmware : D-Link DIR-300 REVB v2.15.B01_WW
# IMPORTANT : Exécuter dans une VM isolée (Ubuntu 20.04 recommandé)
# ============================================================

WORKDIR="$HOME/IoT/formation-Jour2"
FIRMWARE="$WORKDIR/firmware.bin"
FIRMADYNE_DIR="$HOME/firmadyne"

echo "=============================================="
echo "  TP3 - Émulation Firmware avec Firmadyne"
echo "=============================================="
echo ""
echo "[!] PRÉREQUIS : PostgreSQL, QEMU, Python 3"
echo "[!] Ce script doit être exécuté dans une VM isolée"
echo ""

# Étape 1 : Installation des dépendances
echo "[*] Étape 1 : Installation des dépendances..."
sudo apt-get update -qq
sudo apt-get install -y -qq qemu-system-mips qemu-system-arm \
    qemu-utils busybox-static fakeroot git dmsetup \
    kpartx netcat-openbsd nmap python3-psycopg2 \
    snmp postgresql 2>&1 | tail -5

# Étape 2 : Cloner Firmadyne
echo ""
echo "[*] Étape 2 : Clonage de Firmadyne..."
if [ ! -d "$FIRMADYNE_DIR" ]; then
    git clone --depth=1 https://github.com/firmadyne/firmadyne.git "$FIRMADYNE_DIR"
    echo "[+] Firmadyne cloné"
else
    echo "[+] Firmadyne déjà présent"
fi

cd "$FIRMADYNE_DIR"

# Étape 3 : Configuration
echo ""
echo "[*] Étape 3 : Configuration de Firmadyne..."
echo "FIRMWARE_DIR=$FIRMADYNE_DIR/images/" > firmadyne.config
echo "SCRATCH_DIR=$FIRMADYNE_DIR/scratch/" >> firmadyne.config
echo "BINARY_DIR=$FIRMADYNE_DIR/binaries/" >> firmadyne.config
echo "TARBALL_DIR=$FIRMADYNE_DIR/images/" >> firmadyne.config
echo "SQL_SERVER=127.0.0.1" >> firmadyne.config
echo "IDA_PATH=/usr/bin/idat" >> firmadyne.config

# Étape 4 : Téléchargement des binaires QEMU pour MIPS
echo ""
echo "[*] Étape 4 : Téléchargement des binaires QEMU MIPS..."
mkdir -p binaries
wget -q "https://github.com/firmadyne/binaries/raw/master/vmlinux.mipsel.4" \
    -O binaries/vmlinux.mipsel.4 2>/dev/null || echo "[!] Téléchargement manuel requis"

# Étape 5 : Import du firmware
echo ""
echo "[*] Étape 5 : Import du firmware dans Firmadyne..."
echo "[!] Nécessite PostgreSQL configuré avec la base 'firmware'"
echo "[!] Commande : python3 sources/extractor/extractor.py -b D-Link -sql 127.0.0.1 -np -nk $FIRMWARE images/"
echo ""
echo "    Résultat attendu : Image ID = 1"

# Étape 6 : Identification de l'architecture
echo ""
echo "[*] Étape 6 : Identification de l'architecture..."
echo "[!] Commande : ./scripts/getArch.sh ./images/1.tar.gz"
echo ""
echo "    Résultat attendu : mipseb (MIPS Big Endian)"

# Étape 7 : Création de l'image
echo ""
echo "[*] Étape 7 : Création de l'image disque..."
echo "[!] Commande : sudo ./scripts/makeImage.sh 1"

# Étape 8 : Inférence du réseau
echo ""
echo "[*] Étape 8 : Inférence de la configuration réseau..."
echo "[!] Commande : ./scripts/inferNetwork.sh 1"
echo ""
echo "    Résultat attendu :"
echo "    Network: 192.168.0.0/24"
echo "    IP: 192.168.0.1"

# Étape 9 : Lancement de l'émulation
echo ""
echo "[*] Étape 9 : Lancement de l'émulation QEMU..."
echo "[!] Commande : sudo ./scratch/1/run.sh"
echo ""
echo "    L'émulation démarre le noyau Linux 2.6.33.2 (MIPS)"
echo "    Le routeur sera accessible sur : http://192.168.0.1"
echo ""
echo "    Pour accéder à la console :"
echo "    telnet 192.168.0.1"
echo "    Login: Alphanetworks"
echo "    Password: wrgn49_dlob_dir300b5"

echo ""
echo "[+] TP3 - Instructions d'émulation générées !"
