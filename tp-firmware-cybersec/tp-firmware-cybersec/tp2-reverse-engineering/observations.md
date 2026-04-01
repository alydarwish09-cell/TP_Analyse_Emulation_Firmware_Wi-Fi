# TP2 — Observations et Réponses

> **Nom / Prénom :** ___________________________
> **Date :** ___________________________

---

## 1. Informations sur le binaire (`file` + `readelf`)

```
[VOTRE SORTIE ICI]
```

| Champ | Valeur |
|-------|--------|
| Architecture | |
| Endianness | |
| Type ELF | |
| Linked dynamiquement ? | |

---

## 2. Strings liés à l'authentification

*Collez ici les résultats des commandes `strings | grep -i password/admin/login` :*

```
[VOTRE SORTIE ICI]
```

**Credentials hardcodés trouvés :**

- [ ] Oui → précisez : ___________________________
- [ ] Non

---

## 3. Appels système dangereux

*Résultat de `strings | grep '/bin/sh'` et commandes dangereuses :*

```
[VOTRE SORTIE ICI]
```

**Évaluation du risque :**

> _____________________________________________

---

## 4. Fonctions dangereuses détectées

| Fonction | Présente ? | Risque associé |
|----------|-----------|----------------|
| `strcpy` | Oui / Non | Buffer overflow |
| `gets` | Oui / Non | Buffer overflow |
| `sprintf` (sans limite) | Oui / Non | Buffer overflow |
| `system()` | Oui / Non | Command injection |
| `popen()` | Oui / Non | Command injection |

---

## 5. Analyse Radare2 (si effectuée)

*Fonctions identifiées avec `afl` :*

```
[VOTRE SORTIE ICI]
```

**Fonction d'authentification repérée ?**

> _____________________________________________

---

## 6. Backdoors ou accès cachés

*Avez-vous trouvé des chaînes suspectes (debug, secret, backdoor, hardcoded IP...) ?*

```
[VOTRE SORTIE ICI]
```

---

## 7. Synthèse TP2

**Top 3 des vulnérabilités identifiées :**

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________
