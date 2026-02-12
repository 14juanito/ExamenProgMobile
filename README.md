# Application de Billetterie

Application mobile Flutter pour la vente de billets du concert de Fally Ipupa.

## Architecture MVC

```
lib/
├── models/          # Classes de données
│   ├── user.dart
│   ├── event.dart
│   └── ticket.dart
├── views/           # Interface utilisateur
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── event_detail_screen.dart
│   ├── my_tickets_screen.dart
│   ├── ticket_detail_screen.dart
│   └── qr_scanner_screen.dart
├── controllers/     # Logique métier (Provider)
│   ├── auth_controller.dart
│   ├── event_controller.dart
│   └── ticket_controller.dart
├── services/        # Services externes
│   ├── auth_service.dart
│   └── firestore_service.dart
└── main.dart
```

## Stack Technique

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Backend**: Firebase (Auth + Firestore)
- **Authentification**: Email/Password + Google Sign-In
- **QR Code**: qr_flutter + mobile_scanner

## Installation

### 1. Installer les dépendances
```bash
flutter pub get
```

### 2. Configuration Firebase

#### Android (`android/app/google-services.json`)
1. Créer un projet Firebase: https://console.firebase.google.com
2. Ajouter une application Android
3. Télécharger `google-services.json`
4. Placer dans `android/app/`

#### iOS (`ios/Runner/GoogleService-Info.plist`)
1. Ajouter une application iOS dans Firebase
2. Télécharger `GoogleService-Info.plist`
3. Placer dans `ios/Runner/`

### 3. Activer les services Firebase

Dans la console Firebase:
- **Authentication**: Activer Email/Password et Google
- **Firestore Database**: Créer une base de données

### 4. Règles Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /events/{eventId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /tickets/{ticketId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

### 5. Données initiales (Firestore)

Créer une collection `events` avec ce document:

```json
{
  "title": "Concert Fally Ipupa",
  "artist": "Fally Ipupa",
  "description": "Concert exceptionnel de Fally Ipupa au Stade des Martyrs",
  "date": "2024-12-31T20:00:00Z",
  "location": "Stade des Martyrs, Kinshasa",
  "price": 50.00,
  "imageUrl": "https://example.com/fally.jpg",
  "availableTickets": 1000
}
```

## Fonctionnalités

###  Équipe Roy & Ben (Backend/Services)
- [x] AuthService (Email + Google)
- [x] FirestoreService (CRUD événements/tickets)
- [x] AuthController avec Provider
- [x] Gestion d'état authentification

###  Équipe Dim & Gloria (Frontend/UI)
- [x] LoginScreen (Email + Google Sign-In)
- [x] HomeScreen (Liste événements)
- [x] EventDetailScreen (Détails + Achat)
- [x] MyTicketsScreen (Billets utilisateur)
- [x] Design Premium avec gradient

###  QR Code & Finalisation
- [x] Génération QR Code sur ticket
- [x] Scanner QR Code pour validation
- [x] Vérification statut ticket (scanné/valide)

##  Design

- **Couleurs**: Gradient bleu foncé (#1a1a2e, #16213e)
- **Accents**: Bleu (#0f3460), Vert (prix), Orange (statut)
- **Style**: Premium, moderne, épuré

##  Commandes

```bash
# Lancer l'app
flutter run

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Tests
flutter test
```

##  Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Scanner les QR codes des billets</string>
```

##  Équipes

- **Roy & Ben**: Services Firebase, Auth, Backend
- **Dim & Gloria**: UI/UX, Écrans, Design
- **Tous**: QR Code, Tests, Finalisation

##  Licence

Projet académique - Examen Programmation Mobile
