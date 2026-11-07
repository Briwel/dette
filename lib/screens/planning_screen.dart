import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _plannings = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPlannings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlannings() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getPlannedRepayments();
      if (mounted) {
        setState(() {
          _plannings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _upcoming {
    final now = DateTime.now();
    return _plannings.where((p) {
      final dateStr = p['date_prevue'] as String?;
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr);
        return !date.isBefore(DateTime(now.year, now.month, now.day)) &&
            p['statut'] != 'effectue';
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => (a['date_prevue'] as String)
          .compareTo(b['date_prevue'] as String));
  }

  List<dynamic> get _done {
    return _plannings.where((p) => p['statut'] == 'effectue').toList()
      ..sort((a, b) => (b['date_prevue'] as String? ?? '')
          .compareTo(a['date_prevue'] as String? ?? ''));
  }

  Future<void> _openAddPlanning() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPlanningScreen()),
    );
    if (res == true) _fetchPlannings();
  }

  Future<void> _markAsDone(dynamic planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marquer comme effectué ?'),
        content: Text(
          'Confirmer le remboursement de ${NumberFormat('#,###').format(planning['montant_prevu']).replaceAll(',', ' ')} FCFA à ${planning['fournisseurNom'] ?? 'ce fournisseur'} ?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.markPlanningAsDone(planning['id']);
      _fetchPlannings();
    }
  }

  Future<void> _deletePlanning(dynamic planning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce planning ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deletePlanning(planning['id']);
      _fetchPlannings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _upcoming;
    final done = _done;

    // Somme totale planifiée à venir
    double totalPrevu = upcoming.fold(
        0.0, (sum, p) => sum + (p['montant_prevu'] as num? ?? 0).toDouble());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'À venir (${upcoming.length})'),
            Tab(text: 'Effectués (${done.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner total prévu
                if (upcoming.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _TotalBanner(totalPrevu: totalPrevu),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab À venir
                      RefreshIndicator(
                        onRefresh: _fetchPlannings,
                        child: upcoming.isEmpty
                            ? _EmptyState(
                                icon: Icons.calendar_month_outlined,
                                title: 'Aucun remboursement planifié',
                                subtitle:
                                    'Appuyez sur + pour programmer un remboursement',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: upcoming.length,
                                itemBuilder: (ctx, i) => _PlanningCard(
                                  planning: upcoming[i],
                                  onDone: () => _markAsDone(upcoming[i]),
                                  onDelete: () => _deletePlanning(upcoming[i]),
                                ),
                              ),
                      ),
                      // Tab Effectués
                      RefreshIndicator(
                        onRefresh: _fetchPlannings,
                        child: done.isEmpty
                            ? _EmptyState(
                                icon: Icons.check_circle_outline,
                                title: 'Aucun remboursement effectué',
                                subtitle:
                                    'Les remboursements confirmés apparaîtront ici',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: done.length,
                                itemBuilder: (ctx, i) => _PlanningCard(
                                  planning: done[i],
                                  onDone: null,
                                  onDelete: () => _deletePlanning(done[i]),
                                  isDone: true,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPlanning,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Planifier',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

// ─── Banner total ───────────────────────────────────────────────────────────

class _TotalBanner extends StatelessWidget {
  final double totalPrevu;
  const _TotalBanner({required this.totalPrevu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.schedule, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PLANIFIÉ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${NumberFormat('#,###').format(totalPrevu).replaceAll(',', ' ')} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Planning Card ───────────────────────────────────────────────────────────

class _PlanningCard extends StatelessWidget {
  final Map<String, dynamic> planning;
  final VoidCallback? onDone;
  final VoidCallback onDelete;
  final bool isDone;

  const _PlanningCard({
    required this.planning,
    required this.onDone,
    required this.onDelete,
    this.isDone = false,
  });

  Color _urgencyColor(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 0) return AppColors.error;
    if (diff <= 2) return AppColors.warning;
    return AppColors.success;
  }

  String _urgencyLabel(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 0) return 'En retard';
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff <= 7) return 'Dans $diff jours';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final montant = (planning['montant_prevu'] as num? ?? 0).toDouble();
    final nom = planning['fournisseurNom'] as String? ?? 'Fournisseur';
    final note = planning['note'] as String? ?? '';
    DateTime? date;
    try {
      date = DateTime.parse(planning['date_prevue'] as String? ?? '');
    } catch (_) {}

    final urgencyColor = isDone
        ? AppColors.textSecondary
        : (date != null ? _urgencyColor(date) : AppColors.textSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.border : urgencyColor.withValues(alpha: 0.3),
          width: isDone ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header fournisseur + montant
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.border
                        : urgencyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.check_circle
                        : Icons.account_balance_wallet_outlined,
                    color: isDone ? AppColors.textSecondary : urgencyColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDone
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (note.isNotEmpty)
                        Text(
                          note,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Montant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,###').format(montant).replaceAll(',', ' ')} FCFA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDone ? AppColors.textSecondary : AppColors.primary,
                      ),
                    ),
                    if (isDone)
                      const Text(
                        'Effectué',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          // Footer — date + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 15,
                  color: isDone ? AppColors.textSecondary : urgencyColor,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? (isDone
                          ? DateFormat('dd/MM/yyyy').format(date)
                          : _urgencyLabel(date))
                      : '—',
                  style: TextStyle(
                    color: isDone ? AppColors.textSecondary : urgencyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (!isDone && date != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '· ${DateFormat('dd/MM/yyyy').format(date)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                const Spacer(),
                // Actions
                if (!isDone && onDone != null)
                  TextButton.icon(
                    onPressed: onDone,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Fait'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Supprimer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  AddPlanningScreen
// ═══════════════════════════════════════════════════════════════════════════

class AddPlanningScreen extends StatefulWidget {
  const AddPlanningScreen({super.key});

  @override
  State<AddPlanningScreen> createState() => _AddPlanningScreenState();
}

class _AddPlanningScreenState extends State<AddPlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _noteController = TextEditingController();

  List<dynamic> _suppliers = [];
  dynamic _selectedSupplier;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool _isFetchingSuppliers = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final data = await ApiService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = data;
          _isFetchingSuppliers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingSuppliers = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('fr', 'FR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un fournisseur')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.addPlannedRepayment({
        'supplier_id': _selectedSupplier['id'],
        'fournisseurNom': _selectedSupplier['nom'],
        'montant_prevu': double.parse(_montantController.text.replaceAll(' ', '')),
        'date_prevue': _selectedDate.toIso8601String(),
        'note': _noteController.text.trim(),
        'statut': 'planifie',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifier un remboursement',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isFetchingSuppliers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Fournisseur ───────────────────────────────
                    _SectionLabel(
                        icon: Icons.storefront_outlined,
                        label: 'Fournisseur'),
                    const SizedBox(height: 8),
                    _suppliers.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.warning, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Aucun fournisseur. Ajoutez-en un depuis l\'onglet Fournisseurs.',
                                    style: TextStyle(
                                        color: AppColors.warning, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<dynamic>(
                            value: _selectedSupplier,
                            hint: const Text('Choisir un fournisseur'),
                            decoration: _inputDecoration(),
                            items: _suppliers.map<DropdownMenuItem<dynamic>>(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _hexColor(
                                            s['couleur'] as String?),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        s['nom'] as String? ?? '',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if ((s['dette'] as num? ?? 0) > 0)
                                      Text(
                                        '${NumberFormat('#,###').format(s['dette']).replaceAll(',', ' ')} F',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                            ).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSupplier = v),
                            validator: (v) => v == null
                                ? 'Sélectionnez un fournisseur'
                                : null,
                          ),

                    const SizedBox(height: 20),

                    // ─── Montant ───────────────────────────────────
                    _SectionLabel(
                        icon: Icons.payments_outlined, label: 'Montant prévu'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: _inputDecoration(suffix: 'FCFA'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Entrez un montant';
                        final val = double.tryParse(v) ?? 0;
                        if (val <= 0) return 'Le montant doit être > 0';
                        return null;
                      },
                    ),

                    // Suggestion si fournisseur sélectionné
                    if (_selectedSupplier != null &&
                        (_selectedSupplier['dette'] as num? ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            _montantController.text =
                                (_selectedSupplier['dette'] as num)
                                    .toInt()
                                    .toString();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_fix_high,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Rembourser la dette totale : ${NumberFormat('#,###').format(_selectedSupplier['dette']).replaceAll(',', ' ')} FCFA',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ─── Date ──────────────────────────────────────
                    _SectionLabel(
                        icon: Icons.event_outlined,
                        label: 'Date de remboursement prévue'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today,
                                  color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _daysLabel(_selectedDate),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Note facultative ──────────────────────────
                    _SectionLabel(
                        icon: Icons.notes_outlined,
                        label: 'Note (facultatif)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                          hint: 'Ex: Règlement fin de mois, facture n°42…'),
                    ),

                    const SizedBox(height: 36),

                    // ─── Bouton sauvegarder ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )
                            : const Text(
                                'Enregistrer le planning',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  String _daysLabel(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    return 'Dans $diff jours';
  }

  Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  InputDecoration _inputDecoration({String? suffix, String? hint}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixStyle: const TextStyle(
          color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
