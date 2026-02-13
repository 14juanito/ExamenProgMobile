import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'widgets/aurora_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    if (!_formKey.currentState!.validate()) return;

    final success = _isSignUp
        ? await auth.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          )
        : await auth.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentification reussie.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Echec de l authentification.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AIGLE AU STADE',
                          style: TextStyle(
                            fontFamily: 'Impact',
                            fontSize: 28,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Billetterie live pour vos concerts premium.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              label: const Text('Connexion'),
                              selected: !_isSignUp,
                              onSelected: (_) => setState(() => _isSignUp = false),
                            ),
                            ChoiceChip(
                              label: const Text('Inscription'),
                              selected: _isSignUp,
                              onSelected: (_) => setState(() => _isSignUp = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Nom complet'),
                            validator: (value) {
                              if (!_isSignUp) return null;
                              if (value == null || value.trim().length < 3) {
                                return 'Entrez un nom valide.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Entrez un email valide.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(labelText: 'Mot de passe'),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return '6 caracteres minimum.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Consumer<AuthController>(
                          builder: (context, auth, _) {
                            if (auth.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _submit(auth),
                                  child: Text(
                                    _isSignUp ? 'Creer mon compte' : 'Me connecter',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final success = await auth.signInWithGoogle();
                                    if (!mounted) return;
                                    if (!success) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            auth.errorMessage ??
                                                'Connexion Google indisponible.',
                                          ),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  icon: const Icon(Icons.login),
                                  label: const Text('Continuer avec Google'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
