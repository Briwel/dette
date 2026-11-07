import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../screens/supplier_detail_screen.dart';
import '../theme/app_theme.dart';

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
    if (hex == null || hex.isEmpty) return AppColors.primary.withValues(alpha: 0.1);
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(couleurHex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
              backgroundImage: (photoUrl != null && photoUrl!.startsWith('data:image'))
                  ? MemoryImage(base64Decode(photoUrl!.split(',').last))
                  : null,
              child: (photoUrl == null || !photoUrl!.startsWith('data:image'))
                  ? Text(
                      nom.isNotEmpty ? nom[0].toUpperCase() : 'F',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : null,
            ),
            if (dette > 50000)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
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
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          dette == 0 ? 'À jour' : '$nbAchats achat${nbAchats > 1 ? 's' : ''}',
          style: const TextStyle(
            color: AppColors.textSecondary,
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
                color: dette > 0 ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Dette totale',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
