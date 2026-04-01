# TP 2 — Reverse Engineering

## Objectifs

- Identifier les fonctions clés du firmware
- Comprendre les mécanismes d'authentification et les services
- Repérer d'éventuelles backdoors

---

## Étapes

### 1. Navigation dans le binaire extrait

```bash
cd ~/IoT/formation-Jour2/_firmware.bin.extracted/_1322AC.extracted/_bin.tar.bz2.extracted/_0.extracted
ls
```

> ℹ️ Le chemin exact dépend du firmware utilisé. Adaptez-le à votre extraction.

### 2. Analyse des chaînes de caractères (strings)

```bash
strings ingssvcd | less
strings ingssvcd | grep -i password
strings ingssvcd | grep -i admin
strings ingssvcd | grep -i login
```

### 3. Vérification du type et architecture

```bash
file ingssvcd
readelf -h ingssvcd
```

**Informations attendues :**
- Architecture (MIPS, ARM, x86…)
- Endianness (little/big endian)
- Type de binaire (ELF executable, shared library…)

### 4. Analyse avec Radare2

```bash
# Analyse basique
r2 bin/httpd

# Dans r2 :
[0x00000000]> aaa          # Analyse complète
[0x00000000]> afl          # Lister les fonctions
[0x00000000]> pdf @sym.main  # Désassembler main
[0x00000000]> iz            # Lister les strings
[0x00000000]> q             # Quitter
```

> 💡 **Astuce Radare2 :** utilisez `afl~auth` pour filtrer les fonctions liées à l'authentification.

---

## Zones critiques à investiguer

### A. Chargement de librairies dynamiques

```bash
strings ingssvcd | grep -i dlopen
strings ingssvcd | grep -i dlsym
```

### B. Exécution de commandes système

```bash
strings ingssvcd | grep '/bin/sh'
strings ingssvcd | grep -E 'system|execve|popen'
```

### C. Fichiers sensibles système

```bash
strings ingssvcd | grep '/etc/'
strings ingssvcd | grep '/tmp/'
```

### D. Gestion des paramètres utilisateur

Identifier les fonctions dangereuses :

```bash
strings ingssvcd | grep -E 'strcmp|strcpy|sprintf|gets|scanf'
objdump -d ingssvcd | grep -A5 'strcpy\|gets'
```

> ⚠️ `strcpy`, `gets`, `sprintf` sans limite de taille = risque de buffer overflow

### E. Network / Traffic Control

```bash
strings ingssvcd | grep -iE 'ipsec|qos|firewall|iptables'
strings ingssvcd | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
```

---

## Points à analyser

| Zone | Commande | Ce qu'on cherche |
|------|----------|-----------------|
| Endpoints web | `strings \| grep -i "/cgi"` | Routes CGI exposées |
| Commandes système | `strings \| grep '/bin/sh'` | Injections possibles |
| Auth | `strings \| grep -i password` | Credentials hardcodés |
| Backdoors | `strings \| grep -i backdoor\|debug\|secret` | Accès cachés |
| Buffer overflow | `strings \| grep strcpy` | Fonctions dangereuses |

---

## Remplir vos observations

➡️ Complétez le fichier [`observations.md`](./observations.md)
