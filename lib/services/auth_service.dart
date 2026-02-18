import 'dart:async';
import '../models/user.dart';

/// Frontend-only auth stub to decouple the UI from Firebase/Google Sign-In.
/// Accepts any credentials and keeps the "session" in memory.
class AuthService {
  final Map<String, String> _passwords = {}; // email -> password
  final Map<String, User> _users = {};
  final StreamController<User?> _authStream =
      StreamController<User?>.broadcast();

  Stream<User?> get authStateChanges => _authStream.stream;

  Future<User?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final storedPassword = _passwords[email];

    if (storedPassword != null && storedPassword != password) {
      throw Exception('Mot de passe incorrect.');
    }

    final user = _users[email] ??
        User(
          id: 'local-${email.hashCode}',
          email: email,
          name: email.split('@').first,
        );

    _users[email] = user;
    _passwords[email] = password;
    _authStream.add(user);
    return user;
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final user = User(
      id: 'local-${email.hashCode}',
      email: email,
      name: name,
    );
    _users[email] = user;
    _passwords[email] = password;
    _authStream.add(user);
    return user;
  }

  Future<User?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 260));
    final user = User(
      id: 'google-demo',
      email: 'demo@aigleaustade.app',
      name: 'Fan Demo',
      photoUrl: null,
    );
    _users[user.email] = user;
    _authStream.add(user);
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 120));
    _authStream.add(null);
  }
}
