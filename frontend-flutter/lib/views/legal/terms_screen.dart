import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions Générales d’Utilisation"),
        backgroundColor: const Color(0xFF5CC7B4),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Conditions Générales d’Utilisation MoveM8",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "Les présentes Conditions Générales d’Utilisation (CGU) définissent les règles applicables "
              "à l’utilisation de l’application MoveM8.\n\n"
              "1. Objet : MoveM8 est une application permettant de rejoindre des communautés sportives, "
              "créer et participer à des activités.\n\n"
              "2. Inscription : L’utilisateur doit fournir des informations exactes et à jour lors de son inscription.\n\n"
              "3. Utilisation : L’utilisateur s’engage à respecter les autres membres et à ne pas publier de contenus illicites.\n\n"
              "4. Responsabilité : MoveM8 ne peut être tenu responsable des dommages résultant d’une mauvaise utilisation "
              "de l’application ou de litiges entre utilisateurs.\n\n"
              "5. Suppression de compte : L’utilisateur peut supprimer son compte à tout moment. "
              "MoveM8 se réserve le droit de suspendre un compte en cas de non-respect des présentes conditions.\n\n"
              "En utilisant MoveM8, vous acceptez les présentes conditions.",
            ),
          ],
        ),
      ),
    );
  }
}
