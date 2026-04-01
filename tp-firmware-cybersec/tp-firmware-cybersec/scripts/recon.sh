#!/bin/bash
# =============================================================================
# recon.sh — Reconnaissance automatisée d'un firmware émulé (TP4)
# Usage : ./scripts/recon.sh <IP_EMULEE> [output_report.txt]
# =============================================================================

IP="${1:?Usage: $0 <IP_EMULEE> [rapport.txt]}"
REPORT="${2:-recon_$(date +%Y%m%d_%H%M%S).txt}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1" | tee -a "$REPORT"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$REPORT"; }
section() { echo -e "\n${CYAN}=== $1 ===${NC}" | tee -a "$REPORT"; }
vuln()    { echo -e "${RED}[VULN]${NC} $1" | tee -a "$REPORT"; }

echo "=============================================" | tee "$REPORT"
echo " Rapport de Reconnaissance Firmware" | tee -a "$REPORT"
echo " Cible : $IP" | tee -a "$REPORT"
echo " Date  : $(date)" | tee -a "$REPORT"
echo "=============================================" | tee -a "$REPORT"

section "1. Connectivité"
if ping -c 1 -W 2 "$IP" > /dev/null 2>&1; then
    info "Hôte $IP accessible (ping OK)"
else
    warn "Hôte $IP ne répond pas au ping (firewall ?)"
fi

section "2. Scan de ports (Nmap)"
nmap -sV -sC --open -T4 "$IP" 2>/dev/null | tee -a "$REPORT" || warn "Nmap échoué ou non installé"

section "3. Test services courants"
PORTS=(21 22 23 80 443 8080 8443)
for port in "${PORTS[@]}"; do
    if nc -z -w2 "$IP" "$port" 2>/dev/null; then
        info "Port $port ouvert"
        case $port in
            23) vuln "Telnet ouvert sur port 23 ! Protocole non chiffré." ;;
            21) vuln "FTP ouvert sur port 21 ! Protocole non chiffré." ;;
            80) info "HTTP disponible : http://$IP/" ;;
        esac
    fi
done

section "4. Test credentials par défaut HTTP"
CREDS=("admin:admin" "admin:password" "root:root" "admin:" "root:" "admin:1234" "guest:guest")
for cred in "${CREDS[@]}"; do
    user="${cred%%:*}"
    pass="${cred##*:}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$user:$pass" --max-time 5 "http://$IP/" 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        vuln "Credential par défaut fonctionnel : $user / '$pass' → HTTP $HTTP_CODE"
    fi
done

section "5. Test accès HTTP sans authentification"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$IP/" 2>/dev/null)
info "Page racine HTTP : code $HTTP_CODE"

# Test CGI communs
for path in /cgi-bin/login.cgi /cgi-bin/index.cgi /admin/ /management/; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$IP$path" 2>/dev/null)
    [ "$code" != "000" ] && info "  $path → HTTP $code"
done

section "6. Test Telnet"
if nc -z -w2 "$IP" 23 2>/dev/null; then
    vuln "Telnet accessible — testez manuellement : telnet $IP"
    info "Credentials à tester : admin/admin, root/root, root/(vide)"
fi

section "7. Résumé"
info "Rapport sauvegardé : $REPORT"
echo ""
echo "Prochaines étapes recommandées :"
echo "  1. Analyser les CGI accessibles manuellement"
echo "  2. Tester les injections de commandes sur les formulaires"
echo "  3. Remplir tp4-analyse-dynamique/observations.md"
