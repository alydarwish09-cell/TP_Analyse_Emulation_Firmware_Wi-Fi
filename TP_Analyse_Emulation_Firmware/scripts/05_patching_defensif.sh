#!/bin/bash
# ============================================================
# TP5 - Patching Défensif du Firmware
# Firmware : D-Link DIR-300 REVB v2.15.B01_WW
# ============================================================

WORKDIR="$HOME/IoT/formation-Jour2"
ROOTFS="$WORKDIR/squashfs-root"
PATCHED_DIR="$WORKDIR/squashfs-root-patched"
NEW_FIRMWARE="$WORKDIR/firmware_patched.bin"

echo "=============================================="
echo "  TP5 - Patching Défensif du Firmware IoT"
echo "=============================================="
echo ""

if [ ! -d "$ROOTFS" ]; then
    echo "[!] Répertoire rootfs non trouvé. Exécutez d'abord le TP1."
    exit 1
fi

# Copie du rootfs pour le patch
echo "[*] Copie du rootfs pour modification..."
cp -r "$ROOTFS" "$PATCHED_DIR"
echo "[+] Copie effectuée dans : $PATCHED_DIR"

echo ""
echo "=============================================="
echo "  CORRECTIF 1 : Mot de passe administrateur"
echo "=============================================="
DEFAULT_XML="$PATCHED_DIR/etc/defnodes/defaultvalue.xml"
if [ -f "$DEFAULT_XML" ]; then
    echo "[*] Avant modification :"
    grep -A3 "<entry>" "$DEFAULT_XML" | head -6
    
    # Ajout d'un mot de passe par défaut
    sed -i 's|<password></password>|<password>Ch@ng3M3!</password>|g' "$DEFAULT_XML"
    
    echo "[+] Après modification :"
    grep -A3 "<entry>" "$DEFAULT_XML" | head -6
    echo "[+] Mot de passe administrateur configuré : Ch@ng3M3!"
else
    echo "[!] Fichier defaultvalue.xml non trouvé"
fi

echo ""
echo "=============================================="
echo "  CORRECTIF 2 : Suppression de la backdoor Telnet"
echo "=============================================="
TELNETD_SCRIPT="$PATCHED_DIR/etc/init0.d/S80telnetd.sh"
if [ -f "$TELNETD_SCRIPT" ]; then
    echo "[*] Contenu actuel du script :"
    cat "$TELNETD_SCRIPT"
    
    # Désactivation du script
    echo "#!/bin/sh" > "$TELNETD_SCRIPT"
    echo "# PATCHED: Telnet backdoor disabled for security reasons" >> "$TELNETD_SCRIPT"
    echo "# Original: telnetd -l /usr/sbin/login -u Alphanetworks:\$image_sign -i br0 &" >> "$TELNETD_SCRIPT"
    echo "echo '[S80telnetd]: Telnet service disabled (security patch)' > /dev/console" >> "$TELNETD_SCRIPT"
    
    echo "[+] Script patché :"
    cat "$TELNETD_SCRIPT"
    echo "[+] Backdoor Telnet désactivée !"
else
    echo "[!] Script S80telnetd.sh non trouvé"
fi

# Désactivation du binaire telnetd si présent
TELNETD_BIN=$(find "$PATCHED_DIR" -name "telnetd" -type f 2>/dev/null | head -1)
if [ -n "$TELNETD_BIN" ]; then
    chmod -x "$TELNETD_BIN"
    echo "[+] Droits d'exécution retirés sur : $TELNETD_BIN"
fi

echo ""
echo "=============================================="
echo "  CORRECTIF 3 : Désactivation de HNAP"
echo "=============================================="
HNAP_DIR="$PATCHED_DIR/htdocs/HNAP1"
if [ -d "$HNAP_DIR" ]; then
    rm -rf "$HNAP_DIR"
    echo "[+] Répertoire HNAP1 supprimé"
else
    echo "[!] Répertoire HNAP1 non trouvé"
fi

# Suppression des CGI vulnérables
for cgi in hedwig.cgi pigwidgeon.cgi; do
    CGI_PATH="$PATCHED_DIR/htdocs/web/$cgi"
    if [ -L "$CGI_PATH" ] || [ -f "$CGI_PATH" ]; then
        rm -f "$CGI_PATH"
        echo "[+] Lien symbolique vulnérable supprimé : $cgi"
    fi
done

echo ""
echo "=============================================="
echo "  RECONSTRUCTION DU FIRMWARE"
echo "=============================================="
echo "[*] Reconstruction du système de fichiers SquashFS..."
which mksquashfs > /dev/null 2>&1 || { echo "[!] mksquashfs non trouvé. Installez squashfs-tools."; }

if which mksquashfs > /dev/null 2>&1; then
    mksquashfs "$PATCHED_DIR" "$WORKDIR/new_squashfs.bin" -comp lzma -b 131072 -noappend 2>&1 | tail -5
    echo "[+] Nouveau SquashFS créé : $WORKDIR/new_squashfs.bin"
    ls -lh "$WORKDIR/new_squashfs.bin"
fi

echo ""
echo "[*] Pour reconstruire le firmware complet :"
echo "    sudo /tmp/fmk/build-firmware.sh /tmp/fmk-extracted/"
echo "    Le firmware patché sera : /tmp/fmk-extracted/fmk/new-firmware.bin"

echo ""
echo "[*] Résumé des correctifs appliqués :"
echo "    1. Mot de passe admin : vide -> Ch@ng3M3!"
echo "    2. Backdoor Telnet : désactivée (S80telnetd.sh patché)"
echo "    3. HNAP : désactivé (répertoire supprimé)"
echo "    4. CGI vulnérables : hedwig.cgi, pigwidgeon.cgi supprimés"

echo ""
echo "[+] TP5 terminé !"
