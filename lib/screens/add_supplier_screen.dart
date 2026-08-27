import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  int _selectedColorIndex = 1; // Default to second color (blue circle with checkmark)
  bool _isLoading = false;

  final List<Color> _colors = const [
    Color(0xFFDCFCE7), // Light green
    Color(0xFFDBEAFE), // Light blue
    Color(0xFFFEF3C7), // Light yellow
    Color(0xFFFCE7F3), // Light pink
  ];

  final List<String> _colorHexes = const [
    '#DCFCE7',
    '#DBEAFE',
    '#FEF3C7',
    '#FCE7F3',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nom = _nomController.text.trim();
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom ou surnom')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.addSupplier({
        'nom': nom,
        'telephone': _phoneController.text.trim(),
        'couleur': _colorHexes[_selectedColorIndex],
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9FD),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajouter un fournisseur',
          style: TextStyle(
            color: Color(0xFF374151),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Circular photo upload placeholder
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélection de photo à venir')),
                );
              },
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9EBFB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF90C2F1),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: Color(0xFF374151),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ajouter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Photo (facultative)',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nom ou Surnom ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD0D9E2)),
              ),
              child: TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4B5563)),
                  hintText: 'Ex: Maman Gâteau',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
              ),
            ),

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Numéro de téléphone (facultatif)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD0D9E2)),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF4B5563)),
                  hintText: 'Ex: 97 00 00 00',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),

            // Color Selection
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Couleur d\'identification',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(_colors.length, (index) {
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4C5D6B) : const Color(0xFFCBD5E1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF374151),
                            size: 24,
                          )
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Aide à repérer rapidement ce fournisseur dans la liste.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, color: Colors.white),
              label: const Text(
                'Enregistrer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C5D6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
