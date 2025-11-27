# CloudFare Deployment - Compatibilité Universelle

## 🖥️ Systèmes Supportés

### Windows
- ✅ Windows 10 (toutes versions)
- ✅ Windows 11 (toutes versions)
- ✅ Windows Server 2019+

### Architecture
- ✅ 32-bit (x86)
- ✅ 64-bit (x64)

### Utilisateurs
- ✅ Administrateur
- ✅ Utilisateur standard (avec UAC)
- ✅ Utilisateur limité (avec demande d'élévation)

## 🔐 Gestion des Permissions

### Installation
- **Requis**: Privilèges administrateur
- **Automatique**: Demande d'élévation UAC si nécessaire
- **Dossier d'installation**: `C:\ProgramData\CloudFare` (accessible à tous)

### Permissions Appliquées
```
C:\ProgramData\CloudFare\
├── Propriétaire: SYSTEM
├── Permissions: Tous les utilisateurs (Contrôle total)
├── Java/
├── Temp/
├── Logs/
└── App.jar
```

### Variables d'Environnement
- `JAVA_HOME`: Défini au niveau machine
- `PATH`: Mise à jour au niveau machine

## 📋 Scripts Universels

### Install-Universal.ps1
**Fonctionnalités**:
- ✅ Détection automatique des privilèges
- ✅ Demande d'élévation UAC si nécessaire
- ✅ Gestion des permissions pour tous les utilisateurs
- ✅ Téléchargement avec retry (3 tentatives)
- ✅ Vérification de la connexion internet
- ✅ Création de dossiers avec permissions
- ✅ Extraction Java portable
- ✅ Assemblage JAR
- ✅ Configuration variables d'environnement
- ✅ Vérification complète de l'installation

**Utilisation**:
```powershell
powershell -ExecutionPolicy Bypass -File Install-Universal.ps1
```

### Install-Universal.bat
**Fonctionnalités**:
- ✅ Vérification des privilèges admin
- ✅ Relancement automatique avec UAC si nécessaire
- ✅ Téléchargement des scripts depuis GitHub
- ✅ Exécution séquentielle des phases
- ✅ Gestion des erreurs

**Utilisation**:
```batch
Install-Universal.bat
```

### Launch-Universal.ps1
**Fonctionnalités**:
- ✅ Vérification de Java et JAR
- ✅ Gestion des logs
- ✅ Support des arguments d'application
- ✅ Messages d'erreur clairs

**Utilisation**:
```powershell
powershell -ExecutionPolicy Bypass -File Launch-Universal.ps1
```

### Setup-Universal.vbs
**Fonctionnalités**:
- ✅ Exécution silencieuse (pas de fenêtre)
- ✅ Téléchargement depuis GitHub
- ✅ Lancement du batch orchestrateur
- ✅ Compatible MSI

**Utilisation**:
```vbscript
cscript Setup-Universal.vbs
```

## 🔄 Flux d'Installation Universel

```
┌─ Utilisateur (Admin ou User)
│
├─ Exécute Setup.msi
│  ├─ MSI appelle Setup-Universal.vbs
│  │  └─ VBScript télécharge Install-Universal.bat
│  │
│  └─ Install-Universal.bat
│     ├─ Vérifie privilèges admin
│     ├─ Demande UAC si nécessaire
│     └─ Télécharge Install-Universal.ps1
│
├─ Install-Universal.ps1
│  ├─ Crée C:\ProgramData\CloudFare
│  ├─ Définit permissions (tous les utilisateurs)
│  ├─ Télécharge Java 21
│  ├─ Télécharge 4 JAR parts
│  ├─ Assemble App.jar
│  ├─ Configure variables d'environnement
│  └─ Vérifie l'installation
│
└─ Launch-Universal.ps1
   ├─ Vérifie Java et JAR
   ├─ Crée les logs
   └─ Exécute l'application
```

## 🛡️ Gestion des Erreurs

### Erreurs Gérées
- ✅ Pas de connexion internet → Retry automatique
- ✅ Téléchargement échoué → Retry 3 fois
- ✅ Pas de privilèges admin → Demande UAC
- ✅ Dossier non accessible → Création avec permissions
- ✅ Java non trouvé → Message d'erreur clair
- ✅ JAR corrompu → Vérification checksum

### Logs
- **Localisation**: `C:\ProgramData\CloudFare\Logs\`
- **Format**: `Launch_YYYYMMDD_HHMMSS.log`
- **Contenu**: Tous les événements d'installation et lancement

## 📊 Vérifications Système

### Avant Installation
- ✅ Connexion internet
- ✅ Privilèges administrateur
- ✅ Espace disque disponible
- ✅ Version Windows compatible

### Après Installation
- ✅ Java.exe présent et fonctionnel
- ✅ App.jar présent et valide
- ✅ Variables d'environnement configurées
- ✅ Permissions correctes

## 🔧 Configuration Personnalisée

### Variables Modifiables
```powershell
# Dossier d'installation personnalisé
powershell -File Install-Universal.ps1 -InstallDir "D:\CloudFare"

# Lancement avec arguments
powershell -File Launch-Universal.ps1 -AppArgs @("--config", "custom.conf")
```

## 📱 Compatibilité Matérielle

### Processeurs Supportés
- ✅ Intel (Core i3+)
- ✅ AMD (Ryzen 3+)
- ✅ ARM (Windows on ARM)

### RAM Minimum
- ✅ 2 GB (recommandé 4 GB)

### Espace Disque
- ✅ 500 MB pour Java
- ✅ 50 MB pour l'application
- ✅ 100 MB pour les logs

## 🌐 Connectivité

### URLs Requises
- `https://github.com/davidrenand/repos` (vérification)
- `https://raw.githubusercontent.com/davidrenand/repos/main/` (téléchargements)
- `https://github.com/graalvm/graalvm-ce-builds/releases/` (Java)

### Proxy
- ✅ Support proxy système
- ✅ Authentification proxy (si configurée)

## 📝 Notes Importantes

1. **Privilèges Admin**: Requis pour l'installation initiale
2. **Dossier Partagé**: `C:\ProgramData\CloudFare` accessible à tous les utilisateurs
3. **Variables d'Environnement**: Configurées au niveau machine
4. **Logs**: Chaque lancement crée un nouveau fichier log
5. **Mise à Jour**: Réexécuter Install-Universal.ps1 pour mettre à jour

## 🆘 Dépannage

### Problème: "Accès refusé"
**Solution**: Exécuter en tant qu'administrateur

### Problème: "Java non trouvé"
**Solution**: Réexécuter Install-Universal.ps1

### Problème: "Téléchargement échoué"
**Solution**: Vérifier la connexion internet et réessayer

### Problème: "UAC bloqué"
**Solution**: Autoriser l'élévation de privilèges dans les paramètres UAC

## 📞 Support

Pour les problèmes:
1. Vérifier les logs: `C:\ProgramData\CloudFare\Logs\`
2. Consulter la documentation: `https://github.com/davidrenand/repos`
3. Réexécuter l'installation avec `-Verbose`

---

**Version**: 1.0
**Date**: 27 novembre 2025
**Auteur**: CloudFare Team
