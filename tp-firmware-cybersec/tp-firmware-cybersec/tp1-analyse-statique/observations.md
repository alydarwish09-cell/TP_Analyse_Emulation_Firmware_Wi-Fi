# TP1 — Observations et Réponses

> **Nom / Prénom :** ___________________________
> **Date :** ___________________________

---

## 1. Résultat de `binwalk firmware.bin`

*Collez ici la sortie de la commande binwalk :*

```
[VOTRE SORTIE ICI]
```

**Observations :**

- Quel(s) type(s) de système de fichiers avez-vous détecté ?

> _____________________________________________

- Quelle architecture CPU est mentionnée (si visible) ?

> _____________________________________________

---

## 2. Contenu de `/etc/passwd`

*Collez ici le contenu du fichier (ou un extrait) :*

```
[VOTRE SORTIE ICI]
```

**Observations :**

- Y a-t-il des comptes avec UID 0 autres que root ?

> _____________________________________________

- Des comptes sans mot de passe ?

> _____________________________________________

---

## 3. Scripts de démarrage (`/etc/init.d/`)

*Listez les services lancés au démarrage :*

```
[VOTRE SORTIE ICI]
```

**Services identifiés :**

| Service | Rôle probable | Risque |
|---------|--------------|--------|
|         |              |        |
|         |              |        |
|         |              |        |

---

## 4. Interface web (`/www/`)

*Listez les fichiers CGI trouvés :*

```
[VOTRE SORTIE ICI]
```

**Observations :**

- Avez-vous trouvé des credentials en clair dans les scripts ?

> _____________________________________________

---

## 5. Binaires ELF identifiés

*Listez les binaires ELF trouvés (`find . -type f | xargs file | grep ELF`) :*

```
[VOTRE SORTIE ICI]
```

---

## 6. Synthèse TP1

**Vulnérabilités / informations sensibles identifiées :**

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

**Ce que vous feriez en situation réelle :**

> _____________________________________________
