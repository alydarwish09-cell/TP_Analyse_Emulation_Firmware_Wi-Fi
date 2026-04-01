#!/bin/bash
# =============================================================================
# setup_env.sh — Installation de l'environnement TP Firmware Cybersécurité
# Usage : ./scripts/setup_env.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Vérification OS
if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "Ce script est optimisé pour Ubuntu. Continuez à vos risques."
fi

info "=== Installation des outils TP Firmware ==="

# Mise à jour
info "Mise à jour des paquets..."
sudo apt-get update -qq

# Outils de base
info "Installation des outils de base..."
sudo apt-get install -y -qq \
    binwalk \
    radare2 \
    nmap \
    netcat-openbsd \
    curl \
    wget \
    file \
    binutils \
    python3 \
    python3-pip \
    git \
    vim \
    squashfs-tools \
    mtd-utils

# QEMU
info "Installation de QEMU..."
sudo apt-get install -y -qq \
    qemu-system-mips \
    qemu-system-arm \
    qemu-utils \
    qemu-user-static

# Python deps pour binwalk
info "Installation des dépendances Python..."
pip3 install --quiet ubi_reader jefferson 2>/dev/null || warn "Certaines dépendances Python optionnelles non installées"

# Création du dossier de travail
WORKDIR=~/IoT/formation-Jour2
info "Création du répertoire de travail : $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Vérification Firmadyne (optionnel)
if [ ! -d "$WORKDIR/firmadyne" ]; then
    read -p "Installer Firmadyne ? (recommandé pour TP3) [y/N] " install_firmadyne
    if [[ "$install_firmadyne" =~ ^[Yy]$ ]]; then
        info "Clonage de Firmadyne..."
        git clone https://github.com/firmadyne/firmadyne.git "$WORKDIR/firmadyne"
        cd "$WORKDIR/firmadyne"
        info "Configuration de Firmadyne..."
        ./setup.sh || warn "Erreur lors du setup Firmadyne — configurez manuellement"
        cd "$WORKDIR"
    fi
fi

info "=== Vérification de l'installation ==="
echo ""
echo "Outil         | Version"
echo "--------------|--------"
printf "binwalk       | "; binwalk --version 2>/dev/null | head -1 || echo "Non installé"
printf "radare2       | "; r2 -version 2>/dev/null | head -1 || echo "Non installé"
printf "nmap          | "; nmap --version 2>/dev/null | head -1 || echo "Non installé"
printf "qemu-mips     | "; qemu-system-mips --version 2>/dev/null | head -1 || echo "Non installé"
printf "mksquashfs    | "; mksquashfs -version 2>/dev/null | head -1 || echo "Non installé"
echo ""

info "=== Installation terminée ==="
info "Répertoire de travail : $WORKDIR"
info "Commencez par le TP1 : cd tp1-analyse-statique && cat README.md"
