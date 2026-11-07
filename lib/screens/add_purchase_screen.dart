import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddPurchaseScreen extends StatefulWidget {
  final String? initialFournisseur;

  const AddPurchaseScreen({super.key, this.initialFournisseur});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  String? _selectedFournisseur;
  int? _selectedSupplierId;
  List<dynamic> _suppliers = [];
  bool _isLoadingSuppliers = true;
  bool _isSubmitting = false;

  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _items = [
    {'name': '', 'quantity': '', 'price': ''},
  ];
  final TextEditingController _dejaPayeController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _selectedFournisseur = widget.initialFournisseur;
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final list = await ApiService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = list;
          _isLoadingSuppliers = false;
          if (_selectedFournisseur != null) {
            final found = _suppliers.firstWhere(
              (s) => s['nom'] == _selectedFournisseur,
              orElse: () => null,
            );
            if (found != null) {
              _selectedSupplierId = found['id'];
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSuppliers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dejaPayeController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _items) {
      total += double.tryParse(item['price'] ?? '0') ?? 0;
    }
    return total;
  }

  double get _resteAPayer {
    double dejaPaye = double.tryParse(_dejaPayeController.text) ?? 0;
    return mathMax(0, _totalAmount - dejaPaye);
  }

  double mathMax(double a, double b) => a > b ? a : b;

  void _addItem() {
    setState(() {
      _items.add({'name': '', 'quantity': '', 'price': ''});
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (_items.length > 1) {
        _items.removeAt(index);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _confirmPurchase() async {
    if (_selectedFournisseur == null && _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un fournisseur')),
      );
      return;
    }

    if (_items.isEmpty || _totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un produit avec un prix valide')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.addPurchase({
        'supplierId': _selectedSupplierId,
        'supplierNom': _selectedFournisseur,
        'date_achat': _selectedDate.toIso8601String(),
        'items': _items,
        'montant_total': _totalAmount,
        'deja_paye': double.tryParse(_dejaPayeController.text) ?? 0,
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
      backgroundColor: const Color(0xFFEAF4FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajouter un achat',
          style: TextStyle(
            color: Color(0xFF374151),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('CHOISIR LE FOURNISSEUR'),
            const SizedBox(height: 8),
            widget.initialFournisseur != null
                ? Container(
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB8C2CC)),
                    ),
                    child: Text(
                      widget.initialFournisseur!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                  )
                : _buildDropdown(),
            const SizedBox(height: 20),
            _buildLabel('DATE'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 28),
            const Text(
              'Produits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132A3A),
              ),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),
            ..._items.asMap().entries.map(
              (entry) => _buildProductCard(entry.key, entry.value),
            ),
            const SizedBox(height: 12),
            _buildAddProductButton(),
            const SizedBox(height: 28),
            _buildSummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFFEAF4FC),
            border: Border(top: BorderSide(color: Color(0xFFD9E4EE))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _confirmPurchase,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle, size: 24, color: Colors.white),
              label: const Text(
                'Confirmer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C5D6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4B5563),
      ),
    );
  }

  Widget _buildDropdown() {
    if (_isLoadingSuppliers) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final supplierNames = _suppliers.map((s) => s['nom'].toString()).toSet().toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8C2CC)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFournisseur,
          hint: const Text(
            'Sélectionner un fournisseur...',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
          items: supplierNames.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedFournisseur = newValue;
              final found = _suppliers.firstWhere(
                (s) => s['nom'] == newValue,
                orElse: () => null,
              );
              if (found != null) {
                _selectedSupplierId = found['id'];
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB8C2CC)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
            ),
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produit',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              if (_items.length > 1)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _removeItem(index),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _buildField(
            initialValue: item['name'],
            onChanged: (val) => item['name'] = val,
            backgroundColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantité',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _buildField(
                      initialValue: item['quantity'],
                      onChanged: (val) => item['quantity'] = val,
                      backgroundColor: const Color(0xFFEFF6FF),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prix',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _buildField(
                      initialValue: item['price'],
                      onChanged: (val) {
                        setState(() {
                          item['price'] = val;
                        });
                      },
                      backgroundColor: const Color(0xFFEFF6FF),
                      suffix: ' FCFA',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    String? initialValue,
    required Function(String) onChanged,
    required Color backgroundColor,
    String? suffix,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return InkWell(
      onTap: _addItem,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB0BECB), width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF4B5563), size: 20),
            SizedBox(width: 8),
            Text(
              'Ajouter un autre produit',
              style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount).replaceAll(',', ' ')} FCFA',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Déjà payé',
                  style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: TextField(
                    controller: _dejaPayeController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                      suffixText: 'FCFA',
                      suffixStyle: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RESTE À PAYER', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold)),
                Text(
                  '${NumberFormat('#,###').format(_resteAPayer).replaceAll(',', ' ')} FCFA',
                  style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
