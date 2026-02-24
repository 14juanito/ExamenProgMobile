import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Connexion email/password
  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    return User.fromFirebaseUser(credential.user!);
  }

  // Inscription
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Mettre à jour le displayName
    await credential.user?.updateDisplayName(name);
    
    if (credential.user == null) return null;
    return User.fromFirebaseUser(credential.user!);
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    if (userCredential.user == null) return null;
    return User.fromFirebaseUser(userCredential.user!);
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtenir l'utilisateur actuel
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return User.fromFirebaseUser(firebaseUser);
  }

  // Stream pour l'état d'authentification
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User.fromFirebaseUser(firebaseUser);
    });
  }
}
