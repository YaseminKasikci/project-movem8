import 'package:flutter/material.dart';

class LegalNoticesScreen extends StatelessWidget {
  const LegalNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentions légales"),
        backgroundColor: const Color(0xFF5CC7B4), // couleur MoveM8
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mentions légales MoveM8",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "L’application MoveM8 est éditée par :\n\n"
              "Nom de la société : MoveM8\n"
              "Adresse : 123 rue de l’Innovation, 75000 Paris, France\n"
              "Email : contact@movem8.com\n"
              "Directeur de la publication : Yasemin Kasikci\n\n"
              "Hébergement :\n"
              "Serveurs hébergés chez OVH, 2 rue Kellermann, 59100 Roubaix, France\n\n"
              "Propriété intellectuelle :\n"
              "Tout le contenu présent dans l’application MoveM8 (logos, textes, images, design) "
              "est protégé par le droit de la propriété intellectuelle et reste la propriété de MoveM8.",
            ),
          ],
        ),
      ),
    );
  }
}
