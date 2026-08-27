class Vente {
  final DateTime date;
  final double montant;

  Vente({required this.date, required this.montant});
}

// Temporary in-memory storage. 
// In a real app, this would be handled by a state management solution (Provider, Riverpod, etc.) or a database.
class SalesData {
  static final List<Vente> _ventes = [
    Vente(date: DateTime.now().subtract(const Duration(minutes: 10)), montant: 25000),
    Vente(date: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), montant: 12000),
    Vente(date: DateTime.now().subtract(const Duration(hours: 4, minutes: 15)), montant: 8000),
  ];

  static List<Vente> get ventes => _ventes;

  static void addVente(double montant) {
    _ventes.insert(0, Vente(date: DateTime.now(), montant: montant));
  }
}
