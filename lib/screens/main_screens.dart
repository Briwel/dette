import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'advice_screen.dart';
import 'settings_screen.dart';
import 'add_purchase_screen.dart';
import 'daily_revenue_screen.dart';
import 'payment_screen.dart';
import 'add_supplier_screen.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/fournisseur_card.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HomeScreen(onSelectTab: _onItemTapped),
      const FournisseursScreen(),
      const VentesScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Fournisseurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Ventes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(int)? onSelectTab;

  const HomeScreen({super.key, this.onSelectTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _detteTotale = 0;
  int _achatsEnCours = 0;
  int _paiementsUrgents = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await ApiService.getPurchasesSummary();
      if (mounted) {
        setState(() {
          _detteTotale = (summary['totalDebt'] ?? 0).toDouble();
          _achatsEnCours = (summary['activePurchasesCount'] ?? 0).toInt();
          _paiementsUrgents = (summary['urgentPaymentsCount'] ?? 0).toInt();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detteTotale = 0;
          _achatsEnCours = 0;
          _paiementsUrgents = 0;
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
        title: const Text(
          'Dantokpa Crédit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.person_outline, color: Color(0xFF334155)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte Dette Totale
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DETTE TOTALE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '${NumberFormat('#,###').format(_detteTotale).replaceAll(',', ' ')} FCFA',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Achats en cours',
                      value: '$_achatsEnCours',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SummaryCard(
                      title: 'Paiements urgents',
                      value: '$_paiementsUrgents',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ACTIONS RAPIDES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  QuickActionButton(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Ajouter un achat',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPurchaseScreen(),
                        ),
                      );
                      if (res == true) _fetchSummary();
                    },
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  QuickActionButton(
                    icon: Icons.group_outlined,
                    label: 'Mes fournisseurs',
                    onTap: () {
                      if (widget.onSelectTab != null) {
                        widget.onSelectTab!(1);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Scaffold(body: FournisseursScreen()),
                          ),
                        );
                      }
                    },
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  QuickActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Ajouter un remboursement',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(fournisseurNom: ''),
                        ),
                      );
                      if (res == true) _fetchSummary();
                    },
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                  QuickActionButton(
                    icon: Icons.calculate_outlined,
                    label: 'Recette du jour',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyRevenueScreen(),
                        ),
                      );
                      if (res == true) _fetchSummary();
                    },
                    backgroundColor: Colors.pink.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Section Conseils
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdviceScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Conseils de remboursement',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FournisseursScreen extends StatefulWidget {
  const FournisseursScreen({super.key});

  @override
  State<FournisseursScreen> createState() => _FournisseursScreenState();
}

class _FournisseursScreenState extends State<FournisseursScreen> {
  List<dynamic> _suppliers = [];
  List<dynamic> _filteredSuppliers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = data;
          _filteredSuppliers = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suppliers = [];
          _filteredSuppliers = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuppliers = _suppliers;
      } else {
        _filteredSuppliers = _suppliers.where((s) {
          final nom = (s['nom'] ?? '').toString().toLowerCase();
          return nom.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _openAddSupplier() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
    );
    if (res == true) {
      _fetchSuppliers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes Fournisseurs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF334155)),
            tooltip: 'Ajouter un fournisseur',
            onPressed: _openAddSupplier,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un fournisseur...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchSuppliers,
                    child: _filteredSuppliers.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'Aucun fournisseur trouvé',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filteredSuppliers.length,
                            itemBuilder: (context, index) {
                              final item = _filteredSuppliers[index];
                              return FournisseurCard(
                                id: item['id'],
                                nom: item['nom'] ?? 'Fournisseur',
                                nbAchats: (item['nbAchats'] ?? 0).toInt(),
                                dette: (item['dette'] ?? 0).toDouble(),
                                couleurHex: item['couleur'],
                                onRefresh: _fetchSuppliers,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSupplier,
        backgroundColor: const Color(0xFF4C5D6B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Fournisseur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class VentesScreen extends StatefulWidget {
  const VentesScreen({super.key});

  @override
  State<VentesScreen> createState() => _VentesScreenState();
}

class _VentesScreenState extends State<VentesScreen> {
  List<dynamic> _ventes = [];
  double _totalToday = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVentes();
  }

  Future<void> _fetchVentes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getDailyRevenues();
      final summary = await ApiService.getDailyRevenuesSummary();
      if (mounted) {
        setState(() {
          _ventes = data;
          _totalToday = (summary['todayTotal'] ?? 0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ventes = [];
          _totalToday = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des ventes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner total ventes du jour
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Ventes du jour',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${NumberFormat('#,###').format(_totalToday).replaceAll(',', ' ')} FCFA',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Historique récent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchVentes,
                    child: _ventes.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 60),
                              Center(
                                child: Text('Aucune vente enregistrée', style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _ventes.length,
                            itemBuilder: (context, index) {
                              final vente = _ventes[index];
                              final rawDate = vente['date_recette'] ?? vente['created_at'];
                              String dateFormatted = 'Aujourd\'hui';
                              if (rawDate != null) {
                                try {
                                  final dt = DateTime.parse(rawDate);
                                  dateFormatted = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                                } catch (_) {}
                              }
                              final montant = (vente['montant'] ?? 0).toDouble();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF475569)),
                                  ),
                                  title: Text(
                                    '${NumberFormat('#,###').format(montant).replaceAll(',', ' ')} FCFA',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Text(dateFormatted),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyRevenueScreen()),
              );
              if (res == true) {
                _fetchVentes();
              }
            },
            backgroundColor: const Color(0xFF4C5D6B),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Ajouter une vente',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SettingsScreen());
  }
}
