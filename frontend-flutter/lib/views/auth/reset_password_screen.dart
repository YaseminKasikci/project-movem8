// 📁 lib/views/reset_password_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPwdController     = TextEditingController();
  final _confirmPwdController = TextEditingController();
  final _auth                  = AuthService();
  bool _loading               = false;
  String _message             = '';

  // Pour toggle visibilité
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  // Regex : ≥ 12 caractères, 1 majuscule, 1 chiffre, 1 symbole
  final _pwdRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{12,}$');

  Future<void> _handleReset() async {
    setState(() {
      _message = '';
      _loading = true;
    });

    final newPwd = _newPwdController.text;
    final confPwd = _confirmPwdController.text;

   if (newPwd != confPwd) {
      setState(() {
        _message = 'Les mots de passe ne correspondent pas';
        _loading = false;
      });
      return;
    }

    // validation locale
    if (!_pwdRegex.hasMatch(newPwd)) {
      setState(() {
        _message =
            'Le mot de passe doit faire au moins 12 caractères,\n'
            'contenir une MAJUSCULE, un chiffre et un symbole.';
        _loading = false;
      });
      return;
    }
   
    try {
      await _auth.resetPassword(widget.resetToken, newPwd);
      setState(() => _message = 'Mot de passe réinitialisé avec succès.');
      // un petit délai pour laisser le temps de lire
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/login');
    } on ApiException catch (e) {
      setState(() => _message = e.message);
    } catch (_) {
      setState(() => _message = 'Erreur inattendue');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Nouveau mot de passe
            TextField(
              controller: _newPwdController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirmation
            TextField(
              controller: _confirmPwdController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Valider
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleReset,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Valider'),
              ),
            ),
            const SizedBox(height: 16),

            // Message d’erreur / succès
            if (_message.isNotEmpty)
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message.startsWith('Mot de passe réinitialisé')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }
}
