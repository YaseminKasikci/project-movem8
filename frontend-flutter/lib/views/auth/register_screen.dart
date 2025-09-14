import 'package:flutter/material.dart';
import 'package:move_m8/views/auth/two_factor_screen.dart';
import '../../services/auth_service.dart';
import '../../widgets/rounded_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController  = TextEditingController();
  final AuthService apiService                   = AuthService();

  String error = '';

  // Pour afficher/masquer les mots de passe
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  // Regex : 12+ caractères, 1 majuscule, 1 chiffre, 1 symbole (inclut + et -)
  final _pwdRegex = RegExp(
    r'^(?=.*[A-Z])'               // au moins une majuscule
    r'(?=.*\d)'                   // au moins un chiffre
    r'(?=.*[!@#\$%^&*(),.?":{}|<>+\-])' // au moins un symbole
    r'.{12,}$'                    // au moins 12 caractères
  );

Future<void> handleRegister() async {
  setState(() => error = '');
  final email = emailController.text.trim();
  final pwd   = passwordController.text;
  final conf  = confirmController.text;

  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    setState(() => error = 'Adresse email invalide');
    return;
  }

  if (pwd != conf) {
    setState(() => error = 'Les mots de passe ne correspondent pas');
    return;
  }

  if (!_pwdRegex.hasMatch(pwd)) {
    setState(() => error =
      'Le mot de passe doit faire au moins 12 caractères,\n'
      'contenir une MAJUSCULE, un chiffre et un symbole.'
    );
    return;
  }

  try {
    await apiService.register(email, pwd);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TwoFactorScreen(email: email)),
    );
  } on ApiException catch (e) {
    setState(() => error = e.message);
  } catch (_) {
    setState(() => error = 'Erreur inattendue');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Inscription'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/logo/logo_only.png',
                height: 150,
              ),
            ),
            const SizedBox(height: 50),

            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.5)),
                ),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Mot de passe
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.5)),
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(() =>
                      _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirmation du mot de passe
            TextField(
              controller: confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.5)),
             //   boxShadow: BoxShadow(color: Colors.black, spreadRadius: 15.00, blurRadius: 10.00)
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(() =>
                      _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton S’inscrire
            RoundedButton(
              text: 'S’inscrire',
              onPressed: handleRegister,
            ),

            // Affichage des erreurs
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  "Déjà inscrit ? Se connecter",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
