// 📁 lib/views/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:move_m8/services/auth_service.dart';
import 'package:move_m8/widgets/rounded_button.dart';
import 'package:move_m8/views/auth/two_factor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService                 = AuthService();

  String  error       = '';
  bool    _loading    = false;
  bool    _obscurePwd = true;

  Future<void> handleLogin() async {
    setState(() {
      error    = '';
      _loading = true;
    });

    try {
      // 1️⃣ Demande d'envoi du code 2FA
      await _authService.initiateLogin(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;
      // 2️⃣ On bascule vers l'écran TwoFactorScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFactorScreen(
            email: emailController.text.trim(),
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'Erreur inattendue: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Connexion'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo
            Image.asset('assets/images/logo/logo_only.png', height: 150),
            const SizedBox(height: 50),

            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.5)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Mot de passe
            TextField(
              controller: passwordController,
              obscureText: _obscurePwd,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.5)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePwd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePwd = !_obscurePwd);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lien mot de passe oublié
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                child: const Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton ou loader
            _loading
                ? const CircularProgressIndicator()
                : RoundedButton(
                    text: 'Se connecter',
                    onPressed: handleLogin,
                  ),

            // Message d’erreur
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Lien vers l’inscription
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text(
                "Pas encore inscrit ? Créer un compte",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
