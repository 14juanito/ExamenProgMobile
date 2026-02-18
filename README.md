# Application de Billetterie (frontend only)

Application Flutter de billetterie pour les concerts de Fally Ipupa, tourn\u00e9e en d\u00e9mo 100\u00a0% front-end (donn\u00e9es mock en m\u00e9moire, aucun Firebase requis).

## Architecture rapide
```
lib/
├─ models/       # user, event, ticket
├─ views/        # \u00e9crans UI (login, home, d\u00e9tails, billets, scanner)
├─ controllers/  # Providers (auth, \u00e9v\u00e9nements, tickets)
├─ services/     # auth / store en m\u00e9moire + API iTunes
└─ main.dart
```

## Stack
- Flutter 3.x
- Provider pour l'\u00e9tat
- Donn\u00e9es mock locales (aucun backend)
- QR: qr_flutter + mobile_scanner

## D\u00e9marrage
```bash
flutter pub get
flutter run
```

## Fonctionnalit\u00e9s
- Connexion / inscription factice (email + bouton Google de d\u00e9mo)
- Liste d'\u00e9v\u00e9nements pr\u00e9-remplis, recherche, d\u00e9tails
- Achat de billet (en m\u00e9moire) + liste de mes billets
- QR code g\u00e9n\u00e9r\u00e9 et scanner pour marquer un billet utilis\u00e9
- Suggestions iTunes des titres de l'artiste

## Commandes utiles
```bash
flutter build apk --debug   # build local sans backend
flutter test                # s'il y a des tests unitaires
```

## Remarques
- Pas de config Firebase ni de fichiers google-services/Info.plist.
- Les donn\u00e9es sont volatiles (se r\u00e9initialisent \u00e0 chaque relance).
