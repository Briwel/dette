import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';
import 'add_purchase_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int? id;
  final String nom;
  final double dette;

  const SupplierDetailScreen({
    super.key,
    this.id,
    required this.nom,
    required this.dette,
  });

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late double _currentDette;
  List<dynamic> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDette = widget.dette;
    _fetchSupplierDetails();
  }

  Future<void> _fetchSupplierDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.id != null) {
        final purchasesData = await ApiService.getPurchases(supplierId: widget.id);
        if (mounted) {
          setState(() {
            _purchases = purchasesData;
            _currentDette = purchasesData.reduce(
              (sum, p) => sum + (p['montant_restant'] ?? 0).toDouble(),
            );
            _isLoading = false;
          });
        }
      } else {
        final suppliers = await ApiService.getSuppliers();
        final s = suppliers.firstWhere(
          (element) => element['nom'] == widget.nom,
          orElse: () => null,
        );
        if (s != null && s['id'] != null) {
          final purchasesData = await ApiService.getPurchases(supplierId: s['id']);
          if (mounted) {
            setState(() {
              _purchases = purchasesData;
              _currentDette = purchasesData.fold(
                0.0,
                (sum, p) => sum + ((p['montant_restant'] ?? 0) as num).toDouble(),
              );
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Détails Fournisseur',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSupplierDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // En-tête fournisseur
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        widget.nom.isNotEmpty ? widget.nom[0].toUpperCase() : 'F',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.nom,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text('Fournisseur', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'DETTE TOTALE',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,###').format(_currentDette.toInt()).replaceAll(',', ' ')} FCFA',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _currentDette > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Boutons actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                fournisseurNom: widget.nom,
                                supplierId: widget.id,
                              ),
                            ),
                          );
                          if (res == true) {
                            _fetchSupplierDetails();
                          }
                        },
                        icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                        label: const Text(
                          'Rembourser',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C5D6B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _fetchSupplierDetails();
                              },
                              icon: const Icon(Icons.receipt_long, color: Color(0xFF334155)),
                              label: const Text('Achats', style: TextStyle(color: Color(0xFF334155))),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPurchaseScreen(
                                      initialFournisseur: widget.nom,
                                    ),
                                  ),
                                );
                                if (res == true) {
                                  _fetchSupplierDetails();
                                }
                              },
                              icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF334155)),
                              label: const Text('Ajouter', style: TextStyle(color: Color(0xFF334155))),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Historique
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Historique des achats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _purchases.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: const Text('Aucun achat enregistré', style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _purchases.length,
                            itemBuilder: (context, index) {
                              final p = _purchases[index];
                              final total = ((p['montant_total'] ?? 0) as num).toDouble();
                              final paye = ((p['montant_initialement_paye'] ?? 0) as num).toDouble();
                              final reste = ((p['montant_restant'] ?? 0) as num).toDouble();
                              final dateRaw = p['date_achat'];
                              String dateFormatted = 'N/A';
                              if (dateRaw != null) {
                                try {
                                  dateFormatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(dateRaw));
                                } catch (_) {}
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Achat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(
                                            '${NumberFormat('#,###').format(total.toInt()).replaceAll(',', ' ')} FCFA',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(dateFormatted, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Payé: ${NumberFormat('#,###').format(paye.toInt()).replaceAll(',', ' ')} FCFA'),
                                          Text(
                                            'Reste: ${NumberFormat('#,###').format(reste.toInt()).replaceAll(',', ' ')} FCFA',
                                            style: TextStyle(
                                              color: reste > 0 ? Colors.orange[800] : Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: total == 0 ? 1 : ((total - reste) / total).clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[200],
                                        color: reste == 0 ? Colors.green : Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
