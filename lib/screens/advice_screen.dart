import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';
import 'daily_revenue_screen.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  bool _isLoading = true;
  bool _hasRevenues = false;
  String? _noticeMessage;
  double _avgRevenue = 0;
  double _suggestedDailyPayment = 0;
  List<dynamic> _cards = [];

  @override
  void initState() {
    super.initState();
    _fetchAdvice();
  }

  Future<void> _fetchAdvice() async {
    setState(() => _isLoading = true);
    try {
      final advice = await ApiService.getRepaymentAdvice();
      if (mounted) {
        setState(() {
          _hasRevenues = advice['hasRevenues'] ?? false;
          _noticeMessage = advice['noticeMessage'];
          _avgRevenue = (advice['avgRevenue'] ?? 0).toDouble();
          _suggestedDailyPayment = (advice['suggestedDailyPayment'] ?? 0).toDouble();
          _cards = advice['cards'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    child: Column(
                      children: [
                        const Text('Recette moyenne récente', style: TextStyle(fontSize: 14, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###').format(_avgRevenue).replaceAll(',', ' ')} FCFA',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        if (_hasRevenues && _suggestedDailyPayment > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Suggestion : Payer environ ${NumberFormat('#,###').format(_suggestedDailyPayment).replaceAll(',', ' ')} FCFA aujourd\'hui',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Message si pas de recettes (Section 13.1)
                  if (!_hasRevenues && _noticeMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEF3C7)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFFD97706)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _noticeMessage!,
                                  style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyRevenueScreen()));
                              if (result == true) {
                                _fetchAdvice();
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                            child: const Text('Enregistrer une recette', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),

                  // Liste des Conseils dynamiques
                  if (_cards.isNotEmpty)
                    ..._cards.map((card) {
                      IconData icon = Icons.lightbulb_outline;
                      Color color = const Color(0xFF0284C7);
                      String type = card['type'] ?? '';
                      
                      if (type == 'overdue') {
                        icon = Icons.warning_amber_rounded;
                        color = const Color(0xFFDC2626); // Rouge
                      } else if (type == 'quick_settle') {
                        icon = Icons.check_circle_outline;
                        color = const Color(0xFF16A34A); // Vert
                      } else if (type == 'upcoming_date') {
                        icon = Icons.access_time;
                        color = const Color(0xFF475569); // Gris
                      }
                      
                      if (card['colorHex'] != null) {
                        try {
                          color = Color(int.parse((card['colorHex'] as String).replaceAll('#', '0xFF')));
                        } catch (_) {}
                      }

                      return _buildAdviceCard(
                        context: context,
                        icon: icon,
                        title: card['title'] ?? '',
                        subtitle: card['subtitle'] ?? '',
                        buttonText: card['buttonText'],
                        supplierNom: card['supplierNom'],
                        suggestedAmount: (card['suggestedAmount'] ?? 0).toDouble(),
                        color: color,
                      );
                    }),
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
    double? suggestedAmount,
    Color color = Colors.blueGrey,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
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
                  onPressed: () async {
                    if (supplierNom != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            fournisseurNom: supplierNom,
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchAdvice();
                      }
                    }
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
