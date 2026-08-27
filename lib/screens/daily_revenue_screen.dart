import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class DailyRevenueScreen extends StatefulWidget {
  const DailyRevenueScreen({super.key});

  @override
  State<DailyRevenueScreen> createState() => _DailyRevenueScreenState();
}

class _DailyRevenueScreenState extends State<DailyRevenueScreen> {
  String _amount = '0';
  double _todayTotal = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchTodaySummary();
  }

  Future<void> _fetchTodaySummary() async {
    try {
      final summary = await ApiService.getDailyRevenuesSummary();
      if (mounted) {
        setState(() {
          _todayTotal = (summary['todayTotal'] ?? 0).toDouble();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _todayTotal = 0;
        });
      }
    }
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'back') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else {
        if (_amount == '0') {
          _amount = key;
        } else {
          _amount += key;
        }
      }
    });
  }

  Future<void> _submitRevenue() async {
    double amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.addDailyRevenue({
        'date_recette': DateTime.now().toIso8601String(),
        'montant': amount,
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Recette du jour', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Total déjà enregistré aujourd\'hui', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(_todayTotal).replaceAll(',', ' ')} FCFA',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                    ),
                  ]),
                  const Icon(Icons.show_chart, color: Color(0xFF991B1B)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_today, size: 16), SizedBox(width: 8), Text('Aujourd\'hui'), Icon(Icons.arrow_drop_down)]),
          ),
          const Spacer(),
          Text('$_amount FCFA', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const Spacer(),
          _buildKeypad(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRevenue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF596775),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Confirmer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          _buildRow(['00', '0', 'back']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) => Expanded(child: Padding(padding: const EdgeInsets.all(4), child: _buildKey(key)))).toList(),
    );
  }

  Widget _buildKey(String key) {
    return InkWell(
      onTap: () => _onKeyTap(key),
      child: Container(
        height: 60,
        decoration: BoxDecoration(color: const Color(0xFFD6E6F5), borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: key == 'back'
              ? const Icon(Icons.backspace_outlined)
              : Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        ),
      ),
    );
  }
}
