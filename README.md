# e-ticket — Application de Billetterie (frontend only)

Application Flutter de billetterie **e-ticket**, tournée en démo 100 % front-end (données mock en mémoire, aucun Firebase requis).

## Architecture rapide
```
lib/
├─ models/       # user, event, ticket
├─ views/        # écrans UI (login, home, détails, billets, scanner)
├─ controllers/  # Providers (auth, événements, tickets)
├─ services/     # auth / store en mémoire + API iTunes
└─ main.dart
```

## Stack
- Flutter 3.x
- Provider pour l'état
- Données mock locales (aucun backend)
- QR : qr_flutter + mobile_scanner

## Démarrage
```bash
flutter pub get
flutter run
```

## Fonctionnalités
- Connexion / inscription factice (email + bouton Google de démo)
- Liste d'événements pré-remplis, recherche, détails
- Achat de billet (en mémoire) + liste de mes billets
- QR code généré et scanner pour marquer un billet utilisé
- Suggestions iTunes des titres de l'artiste

## Commandes utiles
```bash
flutter build apk --debug   # build local sans backend
flutter test                # s'il y a des tests unitaires
```

## Remarques
- Pas de config Firebase ni de fichiers google-services/Info.plist.
- Les données sont volatiles (se réinitialisent à chaque relance).
