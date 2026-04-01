#!/bin/bash
# ============================================================
# TP2 - Reverse Engineering du Firmware
# Firmware : D-Link DIR-300 REVB v2.15.B01_WW
# ============================================================

WORKDIR="$HOME/IoT/formation-Jour2"
ROOTFS="$WORKDIR/squashfs-root"
CGIBIN="$ROOTFS/htdocs/cgibin"
HTTPD="$ROOTFS/sbin/httpd"

echo "=============================================="
echo "  TP2 - Reverse Engineering du Firmware IoT"
echo "=============================================="
echo ""

if [ ! -d "$ROOTFS" ]; then
    echo "[!] Répertoire rootfs non trouvé. Exécutez d'abord le TP1."
    exit 1
fi

echo "[*] Analyse du binaire principal : cgibin"
echo "--- TYPE ET ARCHITECTURE ---"
file "$CGIBIN" 2>/dev/null || echo "cgibin non trouvé (lien symbolique cassé)"

echo ""
echo "--- ENTÊTE ELF (readelf) ---"
readelf -h "$CGIBIN" 2>/dev/null | head -20

echo ""
echo "--- STRINGS : Mots de passe et authentification ---"
strings "$CGIBIN" 2>/dev/null | grep -i "password\|admin\|login\|auth" | head -20

echo ""
echo "--- STRINGS : Exécution de commandes système ---"
strings "$CGIBIN" 2>/dev/null | grep -E "system|popen|execve|/bin/sh" | head -10

echo ""
echo "--- STRINGS : Fichiers sensibles ---"
strings "$CGIBIN" 2>/dev/null | grep "/var/\|/etc/" | head -15

echo ""
echo "--- STRINGS : Fonctions dangereuses (buffer overflow) ---"
strings "$CGIBIN" 2>/dev/null | grep -E "strcmp|strcpy|sprintf|strcat|gets" | head -10

echo ""
echo "--- STRINGS : Chargement dynamique de bibliothèques ---"
strings "$CGIBIN" 2>/dev/null | grep -i "dlopen\|dlsym" | head -5

echo ""
echo "--- STRINGS : Réseau et sécurité ---"
strings "$CGIBIN" 2>/dev/null | grep -i "ipsec\|qos\|firewall\|hnap\|upnp" | head -10

echo ""
echo "[*] Analyse du démon HTTP : httpd"
echo "--- TYPE ET ARCHITECTURE ---"
file "$HTTPD" 2>/dev/null

echo ""
echo "--- STRINGS : Authentification ---"
strings "$HTTPD" 2>/dev/null | grep -i "password\|admin\|login\|auth\|401\|unauthorized" | head -15

echo ""
echo "[*] Analyse de la backdoor Telnet : S80telnetd.sh"
echo "--- CONTENU DU SCRIPT ---"
cat "$ROOTFS/etc/init0.d/S80telnetd.sh" 2>/dev/null

echo ""
echo "[*] Analyse du kernel Linux extrait"
KERNEL="$WORKDIR/_firmware.bin.extracted/6C"
if [ -f "$KERNEL" ]; then
    echo "--- VERSION LINUX ---"
    strings "$KERNEL" | grep -i "linux version" | head -3
fi

echo ""
echo "[+] TP2 terminé !"
