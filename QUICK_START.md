# CloudFare - Guide de Démarrage Rapide

## ⚡ Installation en 3 Étapes

### Étape 1: Télécharger Setup.msi
```
https://github.com/davidrenand/repos/releases/tag/v1.0
↓
Cliquer sur "Setup.msi"
```

### Étape 2: Exécuter l'Installeur
```
Double-cliquer sur Setup.msi
↓
Cliquer sur "Installer"
↓
Accepter les privilèges administrateur (UAC)
```

### Étape 3: Attendre la Fin
```
L'installation se fait automatiquement
↓
L'application se lance automatiquement
↓
Terminé !
```

## 🖥️ Installation Manuelle (Avancé)

### Option 1: PowerShell
```powershell
# Télécharger et exécuter
powershell -ExecutionPolicy Bypass -Command @"
(New-Object Net.WebClient).DownloadFile(
    'https://raw.githubusercontent.com/davidrenand/repos/main/scripts/Install-Universal.ps1',
    'C:\Temp\Install-Universal.ps1'
)
& 'C:\Temp\Install-Universal.ps1'
"@
```

### Option 2: Batch
```batch
# Télécharger et exécuter
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "(New-Object Net.WebClient).DownloadFile( ^
    'https://raw.githubusercontent.com/davidrenand/repos/main/scripts/Install-Universal.bat', ^
    'C:\Temp\Install-Universal.bat' ^
  ); & 'C:\Temp\Install-Universal.bat'"
```

### Option 3: Git
```bash
# Cloner le repo
git clone https://github.com/davidrenand/repos.git
cd repos/scripts

# Exécuter l'installation
powershell -ExecutionPolicy Bypass -File Install-Universal.ps1
```

## 📋 Vérification de l'Installation

### Vérifier Java
```powershell
java -version
```

### Vérifier l'Application
```powershell
Test-Path "C:\ProgramData\CloudFare\App.jar"
```

### Vérifier les Logs
```powershell
Get-ChildItem "C:\ProgramData\CloudFare\Logs\"
```

## 🚀 Lancement de l'Application

### Automatique
L'application se lance automatiquement après l'installation.

### Manuel
```powershell
# Lancer avec le script
powershell -ExecutionPolicy Bypass -File "C:\ProgramData\CloudFare\Launch-Universal.ps1"

# Ou directement avec Java
java -jar "C:\ProgramData\CloudFare\App.jar"
```

## 🔧 Configuration

### Dossier d'Installation Personnalisé
```powershell
powershell -ExecutionPolicy Bypass -File Install-Universal.ps1 -InstallDir "D:\CloudFare"
```

### Arguments d'Application
```powershell
powershell -ExecutionPolicy Bypass -File Launch-Universal.ps1 -AppArgs @("--config", "custom.conf")
```

## 🛠️ Dépannage Rapide

### Problème: "Accès refusé"
```powershell
# Exécuter en tant qu'administrateur
Start-Process powershell -Verb RunAs
```

### Problème: "Java non trouvé"
```powershell
# Réinstaller
powershell -ExecutionPolicy Bypass -File "C:\ProgramData\CloudFare\Install-Universal.ps1"
```

### Problème: "Téléchargement échoué"
```powershell
# Vérifier la connexion
Test-NetConnection github.com -Port 443
```

### Problème: "Application ne démarre pas"
```powershell
# Vérifier les logs
Get-Content "C:\ProgramData\CloudFare\Logs\*" -Tail 20
```

## 📊 Informations Système

### Afficher la Configuration
```powershell
# Version Windows
[System.Environment]::OSVersion

# Architecture
[Environment]::Is64BitOperatingSystem

# Java
java -version

# Espace disque
Get-Volume
```

## 🔐 Sécurité

### Vérifier les Permissions
```powershell
Get-Acl "C:\ProgramData\CloudFare"
```

### Réinitialiser les Permissions
```powershell
# Exécuter en tant qu'administrateur
icacls "C:\ProgramData\CloudFare" /grant:r "Users:(OI)(CI)F"
```

## 📱 Compatibilité

- ✅ Windows 10/11
- ✅ 32-bit et 64-bit
- ✅ Admin et utilisateur standard
- ✅ Avec et sans UAC

## 🌐 URLs Utiles

- **Repository**: https://github.com/davidrenand/repos
- **Releases**: https://github.com/davidrenand/repos/releases
- **Raw Content**: https://raw.githubusercontent.com/davidrenand/repos/main/
- **Documentation**: https://github.com/davidrenand/repos/blob/main/README.md

## 📞 Support

### Logs
```
C:\ProgramData\CloudFare\Logs\
```

### Fichiers Temporaires
```
C:\ProgramData\CloudFare\Temp\
```

### Configuration
```
C:\ProgramData\CloudFare\
```

## ✅ Checklist Post-Installation

- [ ] Java installé et fonctionnel
- [ ] App.jar présent (40 MB)
- [ ] Variables d'environnement configurées
- [ ] Application lancée avec succès
- [ ] Logs créés
- [ ] Permissions correctes

## 🎯 Prochaines Étapes

1. **Configurer** l'application selon vos besoins
2. **Tester** les fonctionnalités
3. **Consulter** la documentation complète
4. **Signaler** les problèmes sur GitHub

---

**Version**: 1.0
**Date**: 27 novembre 2025
**Support**: https://github.com/davidrenand/repos/issues
