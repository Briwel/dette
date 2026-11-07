import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import 'payment_screen.dart';
import 'add_purchase_screen.dart';
import 'add_supplier_screen.dart';

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
  Map<String, dynamic>? _supplierData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDette = widget.dette;
    OfflineStorageService.logAllData();
    _fetchSupplierDetails();
  }

  Future<void> _fetchSupplierDetails() async {
    setState(() => _isLoading = true);
    try {
      // Trouver le fournisseur (par ID puis par nom)
      final suppliersData = await ApiService.getSuppliers();
      Map<String, dynamic>? foundSupplier;

      if (widget.id != null) {
        try {
          foundSupplier = suppliersData.firstWhere(
            (e) => e['id']?.toString() == widget.id.toString(),
          );
        } catch (_) {}
      }
      foundSupplier ??= (() {
        try {
          return suppliersData.firstWhere(
            (e) => e['nom']?.toString().trim().toLowerCase() ==
                widget.nom.trim().toLowerCase(),
          );
        } catch (_) {
          return null;
        }
      }());

      final resolvedId = foundSupplier?['id'] ?? widget.id;
      debugPrint('DEBUG supplier: id=$resolvedId nom=${widget.nom}');

      // Récupérer les achats
      List<dynamic> purchasesData = await ApiService.getPurchases(
        supplierId: resolvedId is int
            ? resolvedId
            : int.tryParse(resolvedId?.toString() ?? ''),
        supplierNom: widget.nom,
      );

      debugPrint('DEBUG purchases found: ${purchasesData.length}');

      // MIGRATION : si aucun achat mais dette > 0, créer un achat local
      // pour représenter la dette existante (données venant de l'ancien backend)
      if (purchasesData.isEmpty && widget.dette > 0) {
        debugPrint('MIGRATION: Création achat local pour dette existante = ${widget.dette}');
        await ApiService.addPurchase({
          'supplierId': resolvedId,
          'supplierNom': widget.nom,
          'date_achat': DateTime.now().toIso8601String(),
          'description': 'Dette initiale',
          'montant_total': widget.dette,
          'deja_paye': 0,
          'items': [
            {'name': 'Dette initiale', 'quantity': '1', 'price': widget.dette.toString()}
          ],
        });
        // Re-fetch après migration
        purchasesData = await ApiService.getPurchases(
          supplierId: resolvedId is int
              ? resolvedId
              : int.tryParse(resolvedId?.toString() ?? ''),
          supplierNom: widget.nom,
        );
        debugPrint('DEBUG purchases après migration: ${purchasesData.length}');
      }

      if (mounted) {
        setState(() {
          _supplierData = foundSupplier;
          _purchases = purchasesData;
          if (purchasesData.isNotEmpty) {
            _currentDette = purchasesData.fold(
              0.0,
              (sum, p) =>
                  sum +
                  (double.tryParse(p['montant_restant']?.toString() ?? '0') ??
                      0.0),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ERROR in _fetchSupplierDetails: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }


  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final months = [
        '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${date.day} ${months[date.month]}';
    } catch (_) {
      return dateStr.toString();
    }
  }

  Widget _buildPurchaseCard(Map<String, dynamic> p) {
    final montantTotal =
        double.tryParse((p['montant_total'] ?? p['montant'])?.toString() ?? '0') ?? 0.0;
    final montantRestant =
        double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0.0;
    final montantPaye = montantTotal - montantRestant;
    final isPaid = montantRestant <= 0;
    final progress =
        montantTotal > 0 ? (montantPaye / montantTotal).clamp(0.0, 1.0) : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_basket_outlined,
                      color: Color(0xFF64748B), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['description'] ?? 'Achat',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _formatDate(p['date_achat'] ?? p['created_at'] ?? p['date']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  NumberFormat('#,###')
                      .format(montantTotal.toInt())
                      .replaceAll(',', ' '),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Payé: ${NumberFormat('#,###').format(montantPaye.toInt()).replaceAll(',', ' ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                if (!isPaid)
                  Text(
                    'Reste: ${NumberFormat('#,###').format(montantRestant.toInt()).replaceAll(',', ' ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA580C),
                    ),
                  )
                else
                  const Text(
                    'Réglé ✓',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPaid ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _purchases.where((p) => (double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0) > 0).toList();
    final paid =
        _purchases.where((p) => (double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0) <= 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Détails Fournisseur',
          style: TextStyle(
              color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                if (_supplierData != null || widget.id != null) {
                  final supplierToEdit = _supplierData ??
                      {
                        'id': widget.id,
                        'nom': widget.nom,
                        'dette': widget.dette
                      };
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSupplierScreen(supplier: supplierToEdit),
                    ),
                  );
                  if (res == true) _fetchSupplierDetails();
                }
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer le fournisseur'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir supprimer ce fournisseur ? Cette action est irréversible.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true &&
                    (widget.id != null || _supplierData?['id'] != null)) {
                  setState(() => _isLoading = true);
                  await ApiService.deleteSupplier(
                      widget.id ?? _supplierData!['id']);
                  if (mounted) Navigator.pop(context, true);
                }
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Modifier')
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer',
                        style: TextStyle(color: Colors.red))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSupplierDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Carte fournisseur ───────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFFDBEAFE),
                            backgroundImage: (_supplierData != null &&
                                    _supplierData!['photo'] != null &&
                                    _supplierData!['photo']
                                        .toString()
                                        .startsWith('data:image'))
                                ? MemoryImage(base64Decode(
                                    _supplierData!['photo']
                                        .toString()
                                        .split(',')
                                        .last))
                                : null,
                            child: (_supplierData == null ||
                                    _supplierData!['photo'] == null ||
                                    !_supplierData!['photo']
                                        .toString()
                                        .startsWith('data:image'))
                                ? Text(
                                    widget.nom.isNotEmpty
                                        ? widget.nom[0].toUpperCase()
                                        : 'F',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.nom,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B)),
                          ),
                          const Text('Fournisseur',
                              style: TextStyle(color: Color(0xFF94A3B8))),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'DETTE TOTALE',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${NumberFormat('#,###').format(_currentDette.toInt()).replaceAll(',', ' ')} ',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _currentDette > 0
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                                TextSpan(
                                  text: 'FCFA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _currentDette > 0
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Boutons actions ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
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
                                if (res == true) _fetchSupplierDetails();
                              },
                              icon: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white),
                              label: const Text(
                                'Rembourser',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C5D6B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddPurchaseScreen(
                                            initialFournisseur: widget.nom,
                                          ),
                                        ),
                                      );
                                      if (res == true) _fetchSupplierDetails();
                                    },
                                    icon: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Color(0xFF334155)),
                                    label: const Text('Achats',
                                        style: TextStyle(
                                            color: Color(0xFF334155))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddPurchaseScreen(
                                            initialFournisseur: widget.nom,
                                          ),
                                        ),
                                      );
                                      if (res == true) _fetchSupplierDetails();
                                    },
                                    icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Color(0xFF334155)),
                                    label: const Text('Ajouter',
                                        style: TextStyle(
                                            color: Color(0xFF334155))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ─── Historique des achats ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: const Text(
                        'Historique des achats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    if (_purchases.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 56, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 12),
                              Text(
                                'Aucun achat enregistré',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Achats en cours
                      if (pending.isNotEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            'En cours (${pending.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: pending
                                .map((p) => _buildPurchaseCard(
                                    Map<String, dynamic>.from(p)))
                                .toList(),
                          ),
                        ),
                      ],

                      // Achats réglés
                      if (paid.isNotEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Réglés (${paid.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: paid
                                .map((p) => _buildPurchaseCard(
                                    Map<String, dynamic>.from(p)))
                                .toList(),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
