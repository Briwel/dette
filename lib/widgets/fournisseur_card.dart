import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/supplier_detail_screen.dart';

class FournisseurCard extends StatelessWidget {
  final int? id;
  final String nom;
  final int nbAchats;
  final double dette;
  final String? photoUrl;
  final String? couleurHex;
  final VoidCallback? onRefresh;

  const FournisseurCard({
    super.key,
    this.id,
    required this.nom,
    required this.nbAchats,
    required this.dette,
    this.photoUrl,
    this.couleurHex,
    this.onRefresh,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFDBEAFE);
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFDBEAFE);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(couleurHex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupplierDetailScreen(
                id: id,
                nom: nom,
                dette: dette,
              ),
            ),
          );
          if (res == true && onRefresh != null) {
            onRefresh!();
          }
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: bgColor,
              child: Text(
                nom.isNotEmpty ? nom[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (dette > 50000)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          dette == 0 ? 'À jour' : '$nbAchats achat${nbAchats > 1 ? 's' : ''}',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${NumberFormat('#,###').format(dette.toInt()).replaceAll(',', ' ')} FCFA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: dette > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Dette totale',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
