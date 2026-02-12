import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserFromFirebase(credential.user);
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      final user = User(
        id: credential.user!.uid,
        email: email,
        name: name,
      );
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    if (userCredential.user != null) {
      final user = User(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'User',
        photoUrl: userCredential.user!.photoURL,
      );
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    }
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? _getUserFromFirebase(auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? 'User',
      photoUrl: firebaseUser.photoURL,
    );
  }

  auth.User? get currentUser => _firebaseAuth.currentUser;
}
