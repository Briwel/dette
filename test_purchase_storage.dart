import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/offline_storage_service.dart';

void main() async {
  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
  
  print('Testing OfflineStorageService...');
  
  final purchase = {
    'supplierNom': 'TestFournisseur',
    'montant_total': 10000.0,
    'deja_paye': 5000.0,
    'items': [{'name': 'Riz', 'price': '10000'}],
  };
  
  await OfflineStorageService.addPurchase(purchase);
  print('Purchase added');
  
  final purchases = await OfflineStorageService.getPurchases(supplierNom: 'TestFournisseur');
  print('Purchases found: ${purchases.length}');
  
  if (purchases.isNotEmpty) {
    print('Purchase details: ${purchases[0]}');
  } else {
    print('Error: No purchases found');
  }
}
