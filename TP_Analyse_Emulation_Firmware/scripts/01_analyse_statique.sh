#!/bin/bash
# ============================================================
# TP1 - Analyse Statique avec Binwalk
# Firmware : D-Link DIR-300 REVB v2.15.B01_WW
# ============================================================

WORKDIR="$HOME/IoT/formation-Jour2"
FIRMWARE="$WORKDIR/firmware.bin"

echo "=============================================="
echo "  TP1 - Analyse Statique du Firmware IoT"
echo "  Firmware : D-Link DIR-300 REVB v2.15.B01_WW"
echo "=============================================="
echo ""

# Vérification des outils
echo "[*] Vérification des outils..."
which binwalk > /dev/null 2>&1 || { echo "[!] binwalk non trouvé. Installez-le avec: sudo apt install binwalk"; exit 1; }
echo "[+] binwalk disponible"

# Téléchargement du firmware si absent
if [ ! -f "$FIRMWARE" ]; then
    echo "[*] Téléchargement du firmware D-Link DIR-300 REVB..."
    mkdir -p "$WORKDIR"
    wget -q "https://support.dlink.com/resource/products/DIR-300/REVB/DIR-300_REVB5_FIRMWARE_2.15.B01_WW.BIN" -O "$FIRMWARE"
    echo "[+] Firmware téléchargé : $(ls -lh $FIRMWARE | awk '{print $5}')"
else
    echo "[+] Firmware déjà présent : $(ls -lh $FIRMWARE | awk '{print $5}')"
fi

echo ""
echo "[*] Calcul du hash MD5..."
md5sum "$FIRMWARE"

echo ""
echo "[*] Analyse Binwalk du firmware..."
binwalk "$FIRMWARE"

echo ""
echo "[*] Extraction récursive du firmware..."
cd "$WORKDIR"
rm -rf _firmware.bin.extracted
binwalk -Me "$FIRMWARE" 2>&1 | grep -v "WARNING"

echo ""
echo "[*] Exploration du système de fichiers extrait..."
if [ -d "$WORKDIR/squashfs-root" ]; then
    echo "[+] Répertoire squashfs-root trouvé"
    ls -la "$WORKDIR/squashfs-root/"
    echo ""
    echo "[*] Fichiers ELF trouvés :"
    find "$WORKDIR/squashfs-root/" -type f -exec file {} \; 2>/dev/null | grep ELF | awk -F: '{print $1}' | head -20
else
    echo "[!] Extraction SquashFS nécessite sasquatch ou firmware-mod-kit"
    echo "[!] Utiliser: bash /tmp/fmk/extract-firmware.sh $FIRMWARE /tmp/fmk-extracted/"
fi

echo ""
echo "[*] Analyse des fichiers critiques..."
ROOTFS="$WORKDIR/squashfs-root"
if [ -d "$ROOTFS" ]; then
    echo "--- /etc/config/buildver ---"
    cat "$ROOTFS/etc/config/buildver" 2>/dev/null || echo "Non disponible"
    echo "--- /etc/config/image_sign ---"
    cat "$ROOTFS/etc/config/image_sign" 2>/dev/null || echo "Non disponible"
    echo "--- Scripts init.d ---"
    ls "$ROOTFS/etc/init.d/" 2>/dev/null
    echo "--- Scripts init0.d ---"
    ls "$ROOTFS/etc/init0.d/" 2>/dev/null
fi

echo ""
echo "[+] TP1 terminé !"
