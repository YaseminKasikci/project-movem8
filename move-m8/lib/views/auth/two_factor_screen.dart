// lib/views/auth/two_factor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:move_m8/models/auth_model.dart';
import 'package:move_m8/routes/app_routes.dart';
import 'package:move_m8/services/auth_service.dart';
import 'package:move_m8/services/community_service.dart';
import 'package:move_m8/widgets/rounded_button.dart';

class TwoFactorScreen extends StatefulWidget {
  final String email;

  const TwoFactorScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _codeCtrl = TextEditingController();

  bool _loading = false;
  String _error = '';

  bool get _canSubmit =>
      _codeCtrl.text.trim().length == 6 &&
      int.tryParse(_codeCtrl.text.trim()) != null &&
      !_loading;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = '';
    });

    final code = _codeCtrl.text.trim();

    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() {
        _loading = false;
        _error = 'Veuillez saisir les 6 chiffres du code reçu par email.';
      });
      return;
    }

    try {
  final AuthModel auth = await _authService.verifyLogin(widget.email, code);
  if (!mounted) return;
if (auth.communityId != null) {
  // ➜ va d’abord vers l’écran de sélection,
  // puis de là, l’utilisateur (ou ton code) poussera le Home.
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.communitySelection,
    arguments: auth,
  );
} else {
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.communitySelection,
    arguments: auth,
  );
}

} on ApiException catch (e) {
  setState(() => _error = e.message);
} catch (e) {
  setState(() => _error = "Erreur inattendue lors de la vérification.");
}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Vérification du code'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/logo/logo_only.png', height: 150),
              const SizedBox(height: 36),

              Text(
                'Un code à 6 chiffres a été envoyé à :',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Code de vérification',
                  hintText: '______',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.5)),
                  ),
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                onChanged: (_) => setState(() {}),
                // Important: closure synchrone (pas de return) ✅
                onSubmitted: (_) {
                  if (_canSubmit) _handleVerify();
                },
              ),
              const SizedBox(height: 8),

              Text(
                "Le code expire dans 5 minutes.",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              _loading
                  ? const CircularProgressIndicator()
                  : RoundedButton(
                      text: 'Vérifier',
                      // Important: onPressed attend VoidCallback -> on wrappe ✅
                      onPressed: _canSubmit ? () { _handleVerify(); } : null,
                    ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  "Mauvais email ? Revenir à la connexion",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
