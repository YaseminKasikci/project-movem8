import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/rounded_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final authService = AuthService();
  String message = '';
  bool isLoading = false;

  void handleForgot() async {
    setState(() {
      message = '';
      isLoading = true;
    });

    try {
      await authService.forgotPassword(emailController.text.trim());
      setState(() {
        message = "Si cet email existe, un lien de réinitialisation vous sera envoyé.";
      });
    } on ApiException catch (e) {
      setState(() => message = e.message);
    } catch (_) {
      setState(() => message = "Erreur inattendue");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Votre email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : RoundedButton(
                    text: 'Envoyer le lien',
                    onPressed: handleForgot,
                  ),
            const SizedBox(height: 16),
            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith("Erreur") ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
