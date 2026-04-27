# 🌬️ AirQual CM 

**Application Flutter**

---

## 📋 Prérequis

| Outil | Version minimale |
|-------|-----------------|
| Flutter SDK | 3.19.0+ |
| Dart SDK | 3.3.0+ |
| Android Studio / VS Code | Dernière version |
| Android SDK | API 21+ (Android 5.0+) |
| Xcode (iOS, Mac seulement) | 15.0+ |

---

## 🚀 Lancement rapide

### 1. Installer Flutter
```bash
# Vérifier l'installation
flutter --version
flutter doctor
```

### 2. Cloner / extraire le projet
```bash
unzip airqual_cm.zip -d airqual_cm
cd airqual_cm
```

### 3. Installer les dépendances
```bash
flutter pub get
```

### 4. Lancer sur Android (émulateur ou device)
```bash
# Lister les devices disponibles
flutter devices

# Lancer
flutter run

# Lancer en release (plus rapide)
flutter run --release
```

### 5. Construire l'APK
```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release

# APK split par architecture (recommandé)
flutter build apk --split-per-abi

# Localisation de l'APK
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔧 Configuration Android Studio

1. Ouvrir **Android Studio**
2. `File → Open` → sélectionner le dossier `airqual_cm`
3. Attendre la synchronisation Gradle
4. Cliquer **Run ▶** (ou `Shift+F10`)

---

## 📱 Fonctionnalités

### Écran d'accueil
- **Splash Screen** animé au lancement
- **PM2.5 en temps réel** prédit par le modèle AlphaInfera (Random Forest) accessible via l'api déployée sur https://airqual-cm-api.onrender.com/
- **Jauge circulaire animée** avec code couleur OMS
- **KPIs météo** : Température, Vent, Humidité, Radiation
- **Facteurs aggravants** : Harmattan, faible vent, chaleur…
- **Prévisions 7 jours** en cartes horizontales
- **Graphique de tendance** PM2.5
- **Conseil santé** personnalisé selon le niveau
- **Heure GMT+1** affichée en permanence

### Carte interactive
- Carte OpenStreetMap de tout le Cameroun
- **40+ villes** avec marqueurs colorés PM2.5
- Légende des seuils OMS
- Clic sur un marqueur → détail de la ville
- Bouton "Voir détails" pour charger les données complètes

### Prévisions
- **Graphique linéaire PM2.5** avec seuil OMS (trait pointillé rouge)
- **Graphiques à barres** : Température, Vent, Précipitations
- Liste détaillée jour par jour
- Alerte si PM2.5 élevé prévu dans les prochains jours
- Sélecteur 7 / 10 / 14 jours

### Paramètres
- 🌙 **Mode sombre / clair** (sauvegardé localement)
- 🌐 **Langue FR / EN** (sauvegardée localement)
- 🔔 **Notifications** activables/désactivables (programmable)
- 📍 **Ville de notification** (par défaut = ville GPS)
- 📅 **Durée des prévisions** : 7, 10 ou 14 jours

### Notifications
- Rapport quotidien à 8h00 GMT+1
- Alerte si PM2.5 élevé prévu dans les 7 prochains jours
- Contenu : Ville, valeur PM2.5, état (Bon / Modéré / Élevé…)
- S'activent au démarrage du téléphone (BOOT_COMPLETED)

### À propos
- Description du projet
- Détail du modèle IA AlphaInfera
- Sources de données

---

## 🌐 API utilisée

**Open-Meteo** (gratuite, sans clé API)
- URL : `https://api.open-meteo.com/v1/forecast`
- Variables : température, vent, précipitations, humidité, radiation
- Timezone : `Africa/Douala` (GMT+1)
- Prévisions jusqu'à 16 jours

Le **modèle de prédiction PM2.5** est un heuristique basé sur les features importances
du Random Forest AlphaInfera entraîné sur les données historiques du Cameroun.

---

## 🗂️ Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── theme/
│   └── app_theme.dart           # Thème dark/light + couleurs AQI
├── models/
│   ├── air_quality.dart         # Modèles + 40 villes Cameroun
│   └── app_settings.dart        # Préférences utilisateur (SharedPreferences)
├── services/
│   ├── open_meteo_service.dart  # API Open-Meteo + prédiction PM2.5
│   ├── notification_service.dart # Notifications locales planifiées
│   ├── location_service.dart    # GPS + ville la plus proche
│   └── air_quality_provider.dart # Provider (state management)
├── utils/
│   └── aq_utils.dart            # Helpers couleurs, labels, conseils
├── screens/
│   ├── splash_screen.dart       # Splash animé
│   ├── main_shell.dart          # Navigation bottom bar
│   ├── home_screen.dart         # Écran principal
│   ├── map_screen.dart          # Carte interactive
│   ├── forecast_screen.dart     # Prévisions + graphiques
│   ├── settings_screen.dart     # Paramètres
│   └── about_screen.dart        # À propos AlphaInfera
└── widgets/
    ├── aqi_gauge.dart           # Jauge circulaire animée
    ├── forecast_card.dart       # Carte prévision journalière
    ├── factor_chip.dart         # Chip facteur aggravant
    ├── shimmer_loader.dart      # Skeleton loading
    └── city_search_sheet.dart   # Recherche ville (bottom sheet)
```

---

## 🐛 Résolution de problèmes fréquents

### `flutter pub get` échoue
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Erreur de build Gradle
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### Notifications ne s'affichent pas (Android 13+)
- Aller dans **Paramètres → Applications → AirQual CM → Notifications**
- Activer les notifications manuellement

### Erreur de localisation
- S'assurer que le GPS est activé sur le device


---

## 📦 Build release signé

```bash
# 1. Créer un keystore
keytool -genkey -v -keystore airqual-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias airqual

# 2. Créer android/key.properties
storePassword=<mot_de_passe>
keyPassword=<mot_de_passe>
keyAlias=airqual
storeFile=<chemin_vers>/airqual-release.jks

# 3. Build
flutter build apk --release
```

---

**Hackathon IndabaX Cameroon 2026**
Thème : *L'IA au service de la résilience climatique et sanitaire*

---

*AirQual CM — Surveillez l'air que vous respirez 🌍*
