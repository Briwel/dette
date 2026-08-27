import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String fournisseurNom;
  final int? supplierId;

  const PaymentScreen({
    super.key,
    required this.fournisseurNom,
    this.supplierId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String _fournisseurNom;
  int? _supplierId;
  String _selectedMode = 'Espèces';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController(text: '0');
  final TextEditingController _noteController = TextEditingController();
  List<dynamic> _suppliers = [];
  bool _isLoadingSuppliers = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fournisseurNom = widget.fournisseurNom;
    _supplierId = widget.supplierId;
    if (_fournisseurNom.isEmpty) {
      _loadSuppliers();
    }
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoadingSuppliers = true;
    });
    try {
      final list = await ApiService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = list;
          _isLoadingSuppliers = false;
          if (_suppliers.isNotEmpty) {
            _fournisseurNom = _suppliers.first['nom'];
            _supplierId = _suppliers.first['id'];
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
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  Future<void> _confirmPayment() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide supérieur à 0')),
      );
      return;
    }

    if (_fournisseurNom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un fournisseur')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.addRepayment({
        'supplierId': _supplierId,
        'fournisseurNom': _fournisseurNom,
        'amount': amount,
        'paymentMethod': _selectedMode,
        'date': _selectedDate.toIso8601String(),
        'note': _noteController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré avec succès!')),
        );
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enregistrer un paiement',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bloc Fournisseur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, size: 36, color: Color(0xFF2563EB)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: widget.fournisseurNom.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FOURNISSEUR',
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _fournisseurNom,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : _isLoadingSuppliers
                            ? const CircularProgressIndicator()
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _fournisseurNom.isNotEmpty ? _fournisseurNom : null,
                                  hint: const Text('Choisir un fournisseur...'),
                                  isExpanded: true,
                                  items: _suppliers.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s['nom'].toString(),
                                      child: Text(s['nom'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _fournisseurNom = val;
                                        final found = _suppliers.firstWhere((element) => element['nom'] == val, orElse: () => null);
                                        if (found != null) _supplierId = found['id'];
                                      });
                                    }
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bloc Montant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Montant à payer (FCFA)',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Formulaire
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date du paiement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Mode de paiement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildModeButton('Espèces', Icons.account_balance_wallet_outlined)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModeButton('Mobile Money', Icons.phone_android)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Note (Optionnel)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un détail',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bouton Confirmer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _confirmPayment,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, size: 24, color: Colors.white),
                label: const Text(
                  'Confirmer le paiement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C5D6B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, IconData icon) {
    bool isSelected = _selectedMode == label;
    return OutlinedButton.icon(
      onPressed: () => setState(() => _selectedMode = label),
      icon: Icon(icon, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569)),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
