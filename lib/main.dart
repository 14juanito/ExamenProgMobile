import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/event_controller.dart';
import 'controllers/ticket_controller.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _firebaseInitFuture;

  @override
  void initState() {
    super.initState();
    _firebaseInitFuture = _initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _firebaseInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Erreur d\'initialisation Firebase:\n\n${snapshot.error}\n\n'
                    'Pour Web, renseigne la configuration Firebase.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return const MyApp();
      },
    );
  }
}

Future<void> _initializeFirebase() async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    return;
  }

  const webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyB2xSNCYXlHunyVTOMxYyqSZ_lEK0plZrE',
  );
  const webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:623466393159:web:e9b9d8a222453a3aa68b62',
  );
  const webMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    defaultValue: '623466393159',
  );
  const webProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
    defaultValue: 'billets-fbda2',
  );
  const webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
    defaultValue: 'billets-fbda2.firebaseapp.com',
  );
  const webStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
    defaultValue: 'billets-fbda2.firebasestorage.app',
  );
  const webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
    defaultValue: 'G-FB0HLQ1783',
  );

  if (webApiKey.isEmpty ||
      webAppId.isEmpty ||
      webMessagingSenderId.isEmpty ||
      webProjectId.isEmpty) {
    throw StateError(
      'Config Firebase Web manquante: '
      'FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID, '
      'FIREBASE_WEB_MESSAGING_SENDER_ID, FIREBASE_WEB_PROJECT_ID',
    );
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: webApiKey,
      appId: webAppId,
      messagingSenderId: webMessagingSenderId,
      projectId: webProjectId,
      authDomain: _emptyToNull(webAuthDomain),
      storageBucket: _emptyToNull(webStorageBucket),
      measurementId: _emptyToNull(webMeasurementId),
    ),
  );
}

String? _emptyToNull(String value) => value.isEmpty ? null : value;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => EventController()),
        ChangeNotifierProvider(create: (_) => TicketController()),
      ],
      child: MaterialApp(
        title: 'Aigle au Stade',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<AuthController>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
