import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Profil'),
          _buildCard([
            _buildMenuItem(Icons.person_outline, 'Modifier mon profil', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil: Vendeuse Dantokpa')),
              );
            }),
            _buildMenuItem(Icons.camera_alt_outlined, 'Ma photo', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changement de photo')),
              );
            }),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Préférences'),
          _buildCard([
            _buildSwitchItem(Icons.notifications_none, 'Notifications', _notifications, (val) {
              setState(() {
                _notifications = val;
              });
            }),
            _buildMenuItem(Icons.language, 'Langue', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Langue: Français (Bénin)')),
              );
            }, trailing: const Text('Français', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Sécurité'),
          _buildCard([
            _buildMenuItem(Icons.lock_outline, 'Code PIN', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code PIN activé (4 chiffres)')),
              );
            }),
            _buildMenuItem(Icons.cloud_upload_outlined, 'Sauvegarde des données', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données synchronisées avec la base backend NestJS')),
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF4B5563)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF4B5563),
    );
  }
}
