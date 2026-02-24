import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Modèle utilisateur pour l'application
/// Utilise les données de Firebase Auth
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  // Créer un User depuis Firebase Auth User
  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
      photoUrl: firebaseUser.photoURL,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
