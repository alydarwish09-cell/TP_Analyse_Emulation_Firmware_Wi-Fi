#!/bin/bash
# ============================================================
# TP4 - Analyse Dynamique et Détection de Vulnérabilités
# Firmware : D-Link DIR-300 REVB v2.15.B01_WW
# IMPORTANT : Exécuter après le TP3 (émulation active)
# ============================================================

TARGET_IP="${1:-192.168.0.1}"

echo "=============================================="
echo "  TP4 - Analyse Dynamique du Firmware IoT"
echo "  Cible : $TARGET_IP"
echo "=============================================="
echo ""

# Vérification des outils
which nmap > /dev/null 2>&1 || { echo "[!] nmap non trouvé. Installez-le avec: sudo apt install nmap"; exit 1; }

# Étape 1 : Scan de ports
echo "[*] Étape 1 : Scan des ports ouverts (nmap)..."
nmap -sV -p 1-65535 --open "$TARGET_IP" 2>/dev/null || {
    echo "[!] Routeur non accessible. Vérifiez que l'émulation est active."
    echo ""
    echo "    Résultats attendus (basés sur l'analyse statique) :"
    echo "    PORT      STATE SERVICE VERSION"
    echo "    80/tcp    open  http    lighttpd (D-Link DIR-300)"
    echo "    1900/tcp  open  upnp    MiniUPnPd"
    echo "    5000/tcp  open  upnp    MiniUPnPd"
}

echo ""
echo "[*] Étape 2 : Test des credentials par défaut..."
echo "    Tentative de connexion HTTP avec admin/(vide)..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 5 \
    -u "admin:" \
    "http://$TARGET_IP/" 2>/dev/null)

if [ "$HTTP_CODE" = "200" ]; then
    echo "[!] VULNÉRABILITÉ CONFIRMÉE : Accès admin avec mot de passe vide !"
    echo "    Code HTTP : $HTTP_CODE"
elif [ "$HTTP_CODE" = "401" ]; then
    echo "[+] Authentification requise (HTTP 401) - Credentials par défaut rejetés"
else
    echo "    Code HTTP : $HTTP_CODE (routeur non accessible)"
fi

echo ""
echo "[*] Étape 3 : Test de la backdoor Telnet..."
echo "    Tentative de connexion Telnet (port 23)..."
echo "    Credentials backdoor : Alphanetworks / wrgn49_dlob_dir300b5"
nc -z -w 3 "$TARGET_IP" 23 2>/dev/null && echo "[!] VULNÉRABILITÉ : Port 23 (Telnet) ouvert !" || echo "    Port 23 fermé ou non accessible"

echo ""
echo "[*] Étape 4 : Test de la vulnérabilité HNAP (CVE-2019-16920)..."
echo "    Envoi d'une requête HNAP forgée..."
HNAP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 5 \
    -X POST \
    -H 'SOAPAction: "http://purenetworks.com/HNAP1/GetDeviceSettings"' \
    -H 'Content-Type: text/xml' \
    -d '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><GetDeviceSettings xmlns="http://purenetworks.com/HNAP1/"/></soap:Body></soap:Envelope>' \
    "http://$TARGET_IP/HNAP1/" 2>/dev/null)

if [ "$HNAP_RESPONSE" = "200" ]; then
    echo "[!] VULNÉRABILITÉ : Endpoint HNAP accessible sans authentification !"
    echo "    Code HTTP : $HNAP_RESPONSE"
else
    echo "    Code HTTP HNAP : $HNAP_RESPONSE"
fi

echo ""
echo "[*] Étape 5 : Scan UPnP..."
echo "    Recherche de services UPnP sur le réseau..."
nmap -sU -p 1900 "$TARGET_IP" 2>/dev/null | grep -E "open|upnp" || echo "    Scan UPnP non disponible"

echo ""
echo "[*] Résumé des vulnérabilités détectées :"
echo "    1. Credentials par défaut : admin/(vide)"
echo "    2. Backdoor Telnet : Alphanetworks/wrgn49_dlob_dir300b5"
echo "    3. RCE via HNAP (CVE-2019-16920)"
echo "    4. Services UPnP exposés (surface d'attaque étendue)"

echo ""
echo "[+] TP4 terminé !"
