# TP Complet — Analyse et Émulation de Firmware Wi-Fi

> **Jour 2 — Cybersécurité IoT**
> Modules : TP1 Analyse Statique | TP2 Reverse Engineering | TP3 Émulation | TP4 Analyse Dynamique | TP5 Patching Défensif

---

> ⚠️ **Cadre légal et éthique**
> Travailler uniquement sur des firmwares publics ou dans un cadre autorisé.
> VM isolée obligatoire. Ce TP est à finalité pédagogique et défensive uniquement.

---

## Structure du dépôt

```
tp-firmware-cybersec/
├── README.md                        ← Ce fichier
├── tp1-analyse-statique/
│   ├── README.md                    ← Énoncé + guide TP1
│   └── observations.md             ← Fiche de réponses TP1
├── tp2-reverse-engineering/
│   ├── README.md                    ← Énoncé + guide TP2
│   └── observations.md             ← Fiche de réponses TP2
├── tp3-emulation/
│   ├── README.md                    ← Énoncé + guide TP3
│   └── observations.md             ← Fiche de réponses TP3
├── tp4-analyse-dynamique/
│   ├── README.md                    ← Énoncé + guide TP4
│   └── observations.md             ← Fiche de réponses TP4
├── tp5-patching-defensif/
│   ├── README.md                    ← Énoncé + guide TP5
│   ├── observations.md             ← Fiche de réponses TP5
│   └── patches/                    ← Dossier pour vos correctifs
├── rapport/
│   └── rapport_template.md         ← Template du rapport final
└── scripts/
    ├── setup_env.sh                 ← Script d'installation de l'environnement
    ├── extract_firmware.sh          ← Helper d'extraction firmware
    └── recon.sh                     ← Script de reconnaissance automatisée
```

## Prérequis

- **OS :** Ubuntu 22.04 LTS (VM isolée recommandée)
- **Outils requis :** `binwalk`, `radare2`, `qemu`, `nmap`, `strings`, `file`, `readelf`
- **Optionnel :** `firmadyne`, `Ghidra`

## Démarrage rapide

```bash
# 1. Cloner ce dépôt
git clone <url-du-repo>
cd tp-firmware-cybersec

# 2. Installer les dépendances
chmod +x scripts/setup_env.sh
./scripts/setup_env.sh

# 3. Commencer par TP1
cd tp1-analyse-statique/
cat README.md
```

## Rendu attendu

À la fin du TP, chaque étudiant devra :
1. Remplir les fichiers `observations.md` de chaque TP
2. Compléter le `rapport/rapport_template.md`
3. Committer et pousser ses réponses sur sa branche Git : `git checkout -b etudiant/VOTRE_NOM`

---

*Formation Cybersécurité IoT — Jour 2*
