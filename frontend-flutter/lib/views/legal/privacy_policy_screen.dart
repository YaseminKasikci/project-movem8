import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Politique de confidentialité"),
        backgroundColor: const Color(0xFF5CC7B4),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Politique de confidentialité MoveM8",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "Chez MoveM8, nous attachons une grande importance à la protection de vos données personnelles.\n\n"
              "Les données collectées (nom, prénom, email, âge, photo de profil, activités) sont utilisées "
              "uniquement dans le cadre du bon fonctionnement de l’application (création de profil, "
              "participation à des activités, interactions avec les communautés).\n\n"
              "Vos données ne sont jamais revendues à des tiers. Elles peuvent être utilisées à des fins "
              "statistiques et d’amélioration du service.\n\n"
              "Conformément au RGPD, vous disposez d’un droit d’accès, de rectification et de suppression "
              "de vos données personnelles. Vous pouvez exercer ces droits en nous contactant à : "
              "privacy@movem8.com",
            ),
          ],
        ),
      ),
    );
  }
}
