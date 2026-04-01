#!/bin/bash
# =============================================================================
# extract_firmware.sh — Helper d'extraction et d'exploration de firmware
# Usage : ./scripts/extract_firmware.sh <firmware.bin> [output_dir]
# =============================================================================

set -e

FIRMWARE="${1:?Usage: $0 <firmware.bin> [output_dir]}"
OUTPUT_DIR="${2:-_$(basename "$FIRMWARE").extracted}"
WORKDIR=~/IoT/formation-Jour2

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
section(){ echo -e "\n${CYAN}=== $1 ===${NC}"; }

# Vérification firmware
[ -f "$FIRMWARE" ] || { echo -e "${RED}[ERROR]${NC} Firmware non trouvé : $FIRMWARE"; exit 1; }

section "Analyse initiale du firmware"
info "Fichier : $FIRMWARE"
info "Taille  : $(du -sh "$FIRMWARE" | cut -f1)"
file "$FIRMWARE"
echo ""

section "Scan Binwalk"
binwalk "$FIRMWARE"
echo ""

section "Extraction récursive"
info "Nettoyage du répertoire précédent..."
rm -rf "$WORKDIR/$OUTPUT_DIR" 2>/dev/null || true

info "Extraction dans : $WORKDIR/$OUTPUT_DIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
binwalk -Me "$OLDPWD/$FIRMWARE" -C "$OUTPUT_DIR" 2>/dev/null || binwalk -Me "$OLDPWD/$FIRMWARE"

section "Exploration du filesystem"
cd "$WORKDIR"
EXTRACTED=$(find "$OUTPUT_DIR" -maxdepth 4 -name "etc" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)

if [ -z "$EXTRACTED" ]; then
    warn "Impossible de localiser automatiquement le filesystem. Naviguez manuellement dans $OUTPUT_DIR"
else
    info "Filesystem trouvé : $EXTRACTED"
    cd "$EXTRACTED"
    echo ""

    section "Binaires ELF détectés"
    find . -type f -exec file {} \; 2>/dev/null | grep ELF | head -20

    section "Fichiers critiques"
    echo "--- /etc/passwd ---"
    cat etc/passwd 2>/dev/null || warn "/etc/passwd non trouvé"
    echo ""
    echo "--- Scripts init ---"
    ls etc/init.d/ 2>/dev/null || warn "/etc/init.d/ non trouvé"
    echo ""
    echo "--- Interface web ---"
    ls www/ 2>/dev/null || ls www/cgi-bin/ 2>/dev/null || warn "/www/ non trouvé"
    echo ""

    section "Recherche de credentials en clair"
    grep -r "password\s*=" etc/ --include="*.conf" --include="*.cfg" 2>/dev/null | head -10 || info "Aucun credential en clair trouvé dans /etc/"
fi

section "Extraction terminée"
info "Répertoire d'extraction : $WORKDIR/$OUTPUT_DIR"
info "Utilisez 'cd $WORKDIR/$OUTPUT_DIR' pour explorer"
