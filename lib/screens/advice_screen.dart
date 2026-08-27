import 'package:flutter/material.dart';
import 'payment_screen.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Conseils',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte Recette Moyenne
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('Recette moyenne', style: TextStyle(fontSize: 14, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('60 000 FCFA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 12),
                  Text(
                    'Voici comment gérer tes dettes aujourd\'hui',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Liste des Conseils
            _buildAdviceCard(
              context: context,
              icon: Icons.warning_amber_rounded,
              title: 'Priorité : Dette en retard',
              subtitle: 'Awa - Depuis le 15 août',
              buttonText: 'Rembourser',
              supplierNom: 'Awa',
              color: Colors.red,
            ),
            _buildAdviceCard(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Petit à petit : Solde rapide',
              subtitle: 'Koffi - 15 000 FCFA',
              buttonText: 'Soldé',
              supplierNom: 'Koffi',
              color: Colors.green,
            ),
            _buildAdviceCard(
              context: context,
              icon: Icons.lightbulb_outline,
              title: 'Conseil : Prépare demain',
              subtitle: 'Garde un peu de ta recette pour l\'achat de demain.',
            ),
            _buildAdviceCard(
              context: context,
              icon: Icons.access_time,
              title: 'Astuce : Date proche',
              subtitle: 'Un paiement important est à anticiper prochainement.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    String? supplierNom,
    Color color = Colors.blueGrey,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
            if (buttonText != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          fournisseurNom: supplierNom ?? '',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
