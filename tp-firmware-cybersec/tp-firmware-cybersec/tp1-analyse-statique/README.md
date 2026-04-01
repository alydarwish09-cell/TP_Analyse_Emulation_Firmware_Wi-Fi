# TP 1 — Analyse Statique avec Binwalk

## Objectifs

- Extraire le firmware d'un routeur Wi-Fi
- Identifier le système de fichiers et les composants
- Rechercher des informations sensibles et des vulnérabilités

---

## Étapes

### 1. Installation des outils

```bash
sudo apt update && sudo apt install binwalk
```

### 2. Téléchargement d'une image firmware

Télécharger une image firmware publique (ex : routeur Ubiquiti, D-Link, TP-Link).

```bash
# Exemple avec un firmware TP-Link public
wget https://www.tp-link.com/[...]/firmware.bin
# ou utiliser un firmware fourni par le formateur
```

### 3. Analyse du firmware

```bash
binwalk firmware.bin
```

**Que chercher dans la sortie ?**
- Type de compression (gzip, lzma, squashfs…)
- Système de fichiers embarqué
- Signatures de fichiers connus
- Offsets des différentes sections

### 4. Extraction récursive du firmware

```bash
cd ~/IoT/formation-Jour2
rm -rf _firmware.bin.extracted
binwalk -Me firmware.bin
```

> **Options utilisées :**
> - `-M` : mode récursif (analyse tout ce qui est compressé dans le firmware)
> - `-e` : extraction automatique

### 5. Exploration du filesystem extrait

```bash
cd _firmware.bin.extracted/
ls
find . -type f -exec file {} \; | grep ELF
```

**Résultats attendus :**
- Liste des binaires ELF (exécutables Linux/MIPS/ARM)
- Structure du système de fichiers (bin/, etc/, www/, lib/…)

### 6. Analyse des fichiers critiques

```bash
# Comptes utilisateurs
cat etc/passwd
cat etc/shadow 2>/dev/null || echo "Shadow non accessible"

# Scripts de démarrage
ls etc/init.d/
cat etc/init.d/rcS 2>/dev/null

# Interface web
ls www/ 2>/dev/null
find . -name "*.cgi" 2>/dev/null

# Recherche de credentials en clair
grep -r "password" etc/ --include="*.conf" 2>/dev/null
grep -r "passwd" etc/ --include="*.conf" 2>/dev/null
```

---

## Points d'attention

| Fichier / Dossier | Ce qu'on cherche |
|---|---|
| `/etc/passwd` | Comptes, UID 0 non-root |
| `/etc/shadow` | Hashes de mots de passe |
| `/etc/init.d/` | Services lancés au boot |
| `/www/` | Scripts CGI, pages admin |
| Binaires ELF | Architecture, services réseau |

---

## Remplir vos observations

➡️ Complétez le fichier [`observations.md`](./observations.md)
