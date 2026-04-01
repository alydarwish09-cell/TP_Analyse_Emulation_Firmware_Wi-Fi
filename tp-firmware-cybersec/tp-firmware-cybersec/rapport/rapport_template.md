# Rapport Final — Analyse et Émulation de Firmware Wi-Fi

> **Auteur :** ___________________________
> **Date :** ___________________________
> **Formation :** Cybersécurité IoT — Jour 2

---

## 1. Firmware analysé

| Champ | Valeur |
|-------|--------|
| Nom du firmware | |
| Fabricant / Modèle | |
| Version | |
| Source (URL) | |
| Architecture CPU | |
| Système de fichiers | |
| Taille | |

---

## 2. Services identifiés et ports ouverts

*Issue du TP4 — Analyse Dynamique*

| Service | Port | Protocole | État | Risque |
|---------|------|-----------|------|--------|
| HTTP | 80 | TCP | | |
| Telnet | 23 | TCP | | |
| SSH | 22 | TCP | | |
| | | | | |

---

## 3. Vulnérabilités détectées

### 3.1 Vulnérabilités critiques

| # | Vulnérabilité | TP | Preuve | CVSS (estimé) |
|---|--------------|----|----|--------------|
| 1 | | | | |
| 2 | | | | |

### 3.2 Vulnérabilités moyennes

| # | Vulnérabilité | TP | Preuve |
|---|--------------|----|----|
| 1 | | | |
| 2 | | | |

### 3.3 Vulnérabilités faibles / informationnelles

| # | Observation | TP |
|---|------------|-----|
| 1 | | |

---

## 4. Démonstration de l'émulation

*Describe or attach screenshots here.*

**Statut de l'émulation :**

- [ ] Émulation réussie — IP : _______________
- [ ] Émulation partielle
- [ ] Émulation échouée — raison : _______________

**Capture d'écran / description :**

> [Insérez ici vos captures d'écran ou descriptions de l'émulation]

---

## 5. Correctifs appliqués

| # | Vulnérabilité corrigée | Action | Justification |
|---|----------------------|--------|--------------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

## 6. Recommandations de sécurité

*Si ce firmware était déployé en production, voici les recommandations prioritaires :*

### Priorité 1 — Immédiate

1. _______________________________________________
2. _______________________________________________

### Priorité 2 — Court terme

1. _______________________________________________
2. _______________________________________________

### Priorité 3 — Long terme

1. _______________________________________________

---

## 7. Conclusion

> _____________________________________________
> _____________________________________________
> _____________________________________________

---

## Annexes

### A. Commandes utilisées (résumé)

```bash
# TP1 - Extraction
binwalk -Me firmware.bin

# TP2 - Reverse
strings [binaire] | grep -i password
r2 [binaire]

# TP3 - Émulation
./scripts/run.sh [id]

# TP4 - Scan
nmap -sV [IP]

# TP5 - Patch
chmod -x bin/telnetd
mksquashfs rootfs/ new_firmware.bin
```

### B. Références

- [Firmadyne](https://github.com/firmadyne/firmadyne)
- [Binwalk](https://github.com/ReFirmLabs/binwalk)
- [Radare2](https://rada.re)
- [OWASP IoT Attack Surface](https://owasp.org/www-project-internet-of-things/)
