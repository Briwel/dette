import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class PurchasesListScreen extends StatefulWidget {
  final bool onlyUrgent;
  final int? supplierId;
  final String? supplierNom;

  const PurchasesListScreen({
    super.key, 
    this.onlyUrgent = false,
    this.supplierId,
    this.supplierNom,
  });

  @override
  State<PurchasesListScreen> createState() => _PurchasesListScreenState();
}

class _PurchasesListScreenState extends State<PurchasesListScreen> {
  List<dynamic> _allPurchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    setState(() => _isLoading = true);
    try {
      final all = await ApiService.getPurchases(
        supplierId: widget.supplierId, 
        supplierNom: widget.supplierNom
      );
      if (mounted) {
        setState(() {
          _allPurchases = all;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getFilteredPurchases(bool showPaid) {
    if (showPaid) {
      return _allPurchases.where((p) => (double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0) <= 0).toList();
    } else {
      return _allPurchases.where((p) => (double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0) > 0).toList();
    }
  }

  Widget _buildList(bool showPaid) {
    final list = _getFilteredPurchases(showPaid);
    if (list.isEmpty) return const Center(child: Text('Aucun achat trouvé'));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        final reste = double.tryParse(p['montant_restant']?.toString() ?? '0') ?? 0;
        return ListTile(
          title: Text(
            p['description'] ?? 'Achat',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(p['supplierNom'] ?? 'Inconnu'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${NumberFormat('#,###').format(reste)} FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: reste > 0 ? Colors.orange[800] : Colors.green[700],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                reste > 0 ? Icons.chevron_right : Icons.check_circle,
                color: reste > 0 ? Colors.blue : Colors.green,
              ),
            ],
          ),
          onTap: reste > 0 ? () async {
             final res = await Navigator.push(context, MaterialPageRoute(
               builder: (context) => PaymentScreen(
                 fournisseurNom: p['supplierNom'],
                 supplierId: p['supplier_id'] ?? p['supplierId'],
               ),
             ));
             if (res == true) _fetchPurchases();
          } : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Historique des achats';
    if (widget.onlyUrgent) title = 'Paiements urgents';
    else if (widget.supplierNom != null) title = 'Achats: ${widget.supplierNom}';
    else if (widget.supplierId == null) title = 'Achats en cours';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En cours'),
              Tab(text: 'Payés'),
            ],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : const TabBarView(
              children: [
                _PurchasesListView(showPaid: false),
                _PurchasesListView(showPaid: true),
              ],
            ),
      ),
    );
  }
}

class _PurchasesListView extends StatelessWidget {
  final bool showPaid;
  const _PurchasesListView({required this.showPaid});

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_PurchasesListScreenState>();
    return parentState?._buildList(showPaid) ?? const SizedBox();
  }
}
