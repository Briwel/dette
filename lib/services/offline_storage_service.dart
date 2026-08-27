import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorageService {
  static const String _keySuppliers = 'dette_suppliers_local';
  static const String _keyPurchases = 'dette_purchases_local';
  static const String _keyRepayments = 'dette_repayments_local';
  static const String _keyDailyRevenues = 'dette_daily_revenues_local';

  // --- SUPPLIERS ---
  static Future<List<Map<String, dynamic>>> getSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keySuppliers);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> list = json.decode(jsonString);
      return list.map((e) => Map<String, dynamic>.from(e)).where((s) => s['actif'] != false).toList();
    } catch (e) {
      debugPrint('Error reading local suppliers: $e');
      return [];
    }
  }

  static Future<void> saveSuppliers(List<dynamic> suppliers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySuppliers, json.encode(suppliers));
    } catch (e) {
      debugPrint('Error saving local suppliers: $e');
    }
  }

  static Future<Map<String, dynamic>> addSupplier(Map<String, dynamic> data) async {
    final list = await getSuppliers();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final item = {
      'id': data['id'] ?? newId,
      'nom': data['nom'] ?? 'Fournisseur',
      'telephone': data['telephone'] ?? '',
      'couleur': data['couleur'] ?? '#86EFAC',
      'dette': (data['dette'] ?? 0).toDouble(),
      'nbAchats': (data['nbAchats'] ?? 0).toInt(),
      'sync_status': data['sync_status'] ?? 'pending',
      'date_creation': DateTime.now().toIso8601String(),
    };
    list.insert(0, item);
    await saveSuppliers(list);
    return item;
  }



  static Future<Map<String, dynamic>> updateSupplier(dynamic id, Map<String, dynamic> data) async {
    final list = await getSuppliers();
    final index = list.indexWhere((s) => s['id']?.toString() == id.toString());
    if (index != -1) {
      list[index] = {
        ...list[index],
        ...data,
        'sync_status': 'pending',
      };
      await saveSuppliers(list);
      return list[index];
    }
    throw Exception('Supplier not found in local storage');
  }

  static Future<Map<String, dynamic>> deleteSupplier(dynamic id) async {
    final list = await getSuppliers();
    final index = list.indexWhere((s) => s['id']?.toString() == id.toString());
    if (index != -1) {
      list[index]['actif'] = false;
      list[index]['sync_status'] = 'pending';
      await saveSuppliers(list);
      return {'success': true};
    }
    throw Exception('Supplier not found in local storage');
  }

  // --- PURCHASES ---
  static Future<List<Map<String, dynamic>>> getPurchases({int? supplierId, String? supplierNom}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyPurchases);
      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('DEBUG: No purchases found in storage.');
        return [];
      }
      final List<dynamic> list = json.decode(jsonString);
      final maps = list.map((e) => Map<String, dynamic>.from(e)).toList();

      if (supplierId != null || supplierNom != null) {
        final filtered = maps.where((p) {
          final pSupplierId = p['supplier_id']?.toString() ?? p['supplierId']?.toString();
          final pSupplierNom = p['supplierNom']?.toString() ?? p['fournisseurNom']?.toString();

          bool matchId = supplierId != null && pSupplierId == supplierId.toString();
          bool matchNom = supplierNom != null && 
              pSupplierNom?.trim().toLowerCase() == supplierNom.trim().toLowerCase();
          
          return matchId || matchNom;
        }).toList();
        
        debugPrint('DEBUG: Looking for ID: $supplierId, Name: $supplierNom. Found: ${filtered.length} purchases.');
        return filtered;
      }
      return maps;
    } catch (e) {
      debugPrint('Error reading local purchases: $e');
      return [];
    }
  }

  static Future<void> savePurchases(List<dynamic> purchases) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPurchases, json.encode(purchases));
    } catch (e) {
      debugPrint('Error saving local purchases: $e');
    }
  }

  static Future<Map<String, dynamic>> addPurchase(Map<String, dynamic> data) async {
    final list = await getPurchases();
    final newId = DateTime.now().millisecondsSinceEpoch;
    
    final items = data['items'] ?? [];
    double calculatedTotal = 0;
    List<String> descriptionParts = [];
    for (var it in items) {
      calculatedTotal += double.tryParse(it['price']?.toString() ?? '0') ?? 0;
      if (it['name'] != null && it['name'].toString().trim().isNotEmpty) {
        String part = it['name'];
        if (it['quantity'] != null && it['quantity'].toString().trim().isNotEmpty) {
          part += ' x ${it['quantity']}';
        }
        descriptionParts.add(part);
      }
    }
    final description = data['description'] ?? descriptionParts.join(', ');

    final totalAmount = (data['montant_total'] ?? calculatedTotal).toDouble();
    final initialPayment = (data['deja_paye'] ?? data['initialPayment'] ?? 0).toDouble();
    final remainingAmount = (totalAmount - initialPayment).clamp(0.0, double.infinity);
    final status = remainingAmount == 0 ? 'paid' : (initialPayment > 0 ? 'partially_paid' : 'unpaid');

    int finalSupplierId = (data['supplierId'] ?? data['supplier_id'] ?? 0).toInt();
    final supplierNom = data['supplierNom'] ?? 'Fournisseur';

    // Fallback: If ID is 0 but we have a name, try to find the correct supplier ID locally
    if (finalSupplierId == 0 && supplierNom != 'Fournisseur') {
      final suppliers = await getSuppliers();
      final found = suppliers.firstWhere((s) => s['nom'] == supplierNom, orElse: () => <String, dynamic>{});
      if (found.isNotEmpty && found['id'] != null) {
        finalSupplierId = found['id'];
      }
    }

    final item = {
      'id': data['id'] ?? newId,
      'supplier_id': finalSupplierId,
      'supplierNom': supplierNom,
      'date_achat': data['date_achat'] ?? DateTime.now().toIso8601String(),
      'montant_total': totalAmount,
      'montant_initialement_paye': initialPayment,
      'montant_restant': remainingAmount,
      'statut': status,
      'description': description,
      'items': items,
      'sync_status': data['sync_status'] ?? 'pending',
    };

    list.insert(0, item);
    await savePurchases(list);

    // Update supplier debt locally
    await _recalculateSupplierDebtLocally(finalSupplierId, supplierNom);

    return item;
  }

  static Future<Map<String, dynamic>> getPurchasesSummary() async {
    final purchases = await getPurchases();
    double totalDebt = 0;
    int activeCount = 0;
    int urgentCount = 0;

    for (var p in purchases) {
      final restant = (p['montant_restant'] ?? 0).toDouble();
      if (restant > 0) {
        totalDebt += restant;
        activeCount++;
        if (restant > 20000) {
          urgentCount++;
        }
      }
    }

    return {
      'totalDebt': totalDebt,
      'activePurchasesCount': activeCount,
      'urgentPaymentsCount': urgentCount,
    };
  }

  // --- REPAYMENTS ---
  static Future<List<Map<String, dynamic>>> getRepayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyRepayments);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> list = json.decode(jsonString);
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveRepayments(List<dynamic> repayments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRepayments, json.encode(repayments));
    } catch (e) {
      debugPrint('Error saving local repayments: $e');
    }
  }

  static Future<Map<String, dynamic>> addRepayment(Map<String, dynamic> data) async {
    final list = await getRepayments();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final amount = (data['amount'] ?? data['montant_total'] ?? 0).toDouble();
    final supplierId = data['supplierId'] ?? data['supplier_id'];
    final supplierNom = data['fournisseurNom'] ?? data['supplierNom'] ?? '';

    final item = {
      'id': data['id'] ?? newId,
      'supplier_id': supplierId,
      'fournisseurNom': supplierNom,
      'montant_total': amount,
      'mode_paiement': data['paymentMethod'] ?? data['mode_paiement'] ?? 'Espèces',
      'date_remboursement': data['date'] ?? DateTime.now().toIso8601String(),
      'note': data['note'] ?? '',
      'sync_status': data['sync_status'] ?? 'pending',
    };

    list.insert(0, item);
    await saveRepayments(list);

    // Apply repayment to local purchases
    if (amount > 0) {
      final purchases = await getPurchases();
      double remainingPayment = amount;

      for (var p in purchases) {
        final matchesSupplier = (supplierId != null && p['supplier_id'] == supplierId) ||
            (supplierNom.isNotEmpty && (p['supplierNom'] == supplierNom || (p['supplier'] != null && p['supplier']['nom'] == supplierNom)));
        
        final restant = (p['montant_restant'] ?? 0).toDouble();
        if (matchesSupplier && restant > 0 && remainingPayment > 0) {
          final deduction = remainingPayment > restant ? restant : remainingPayment;
          p['montant_restant'] = restant - deduction;
          remainingPayment -= deduction;
          p['statut'] = p['montant_restant'] == 0 ? 'paid' : 'partially_paid';
        }
      }
      await savePurchases(purchases);

      // Recalculate supplier debt
      await _recalculateSupplierDebtLocally(supplierId, supplierNom);
    }

    return item;
  }

  // --- DAILY REVENUES ---
  static Future<List<Map<String, dynamic>>> getDailyRevenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyDailyRevenues);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> list = json.decode(jsonString);
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveDailyRevenues(List<dynamic> revenues) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDailyRevenues, json.encode(revenues));
    } catch (e) {
      debugPrint('Error saving local daily revenues: $e');
    }
  }

  static Future<Map<String, dynamic>> addDailyRevenue(Map<String, dynamic> data) async {
    final list = await getDailyRevenues();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final item = {
      'id': data['id'] ?? newId,
      'date_recette': data['date_recette'] ?? DateTime.now().toIso8601String(),
      'montant': (data['montant'] ?? 0).toDouble(),
      'sync_status': data['sync_status'] ?? 'pending',
    };
    list.insert(0, item);
    await saveDailyRevenues(list);
    return item;
  }

  static Future<Map<String, dynamic>> getDailyRevenuesSummary() async {
    final revenues = await getDailyRevenues();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    double todayTotal = 0;
    double totalAll = 0;

    for (var r in revenues) {
      final montant = (r['montant'] ?? 0).toDouble();
      totalAll += montant;
      final dateStr = (r['date_recette'] ?? '').toString().split('T')[0];
      if (dateStr == todayStr) {
        todayTotal += montant;
      }
    }

    double avg = revenues.isNotEmpty ? (totalAll / revenues.length).roundToDouble() : 0;

    return {
      'todayTotal': todayTotal,
      'averageRevenue': avg,
    };
  }

  // --- REPAYMENT ADVICE (Section 13 of Cahier des charges) ---
  static Future<Map<String, dynamic>> getRepaymentAdvice() async {
    final revenues = await getDailyRevenues();
    final purchases = await getPurchases();

    final bool hasRevenues = revenues.isNotEmpty;
    double totalRevenue = 0;
    for (var r in revenues) {
      totalRevenue += (r['montant'] ?? 0).toDouble();
    }
    final double avgRevenue = hasRevenues ? (totalRevenue / revenues.length).roundToDouble() : 0;

    final openPurchases = purchases.where((p) => (p['montant_restant'] ?? 0).toDouble() > 0).toList();
    double totalDebt = 0;
    final List<Map<String, dynamic>> urgentPurchases = [];
    final List<Map<String, dynamic>> smallDebts = [];

    for (var p in openPurchases) {
      final restant = (p['montant_restant'] ?? 0).toDouble();
      totalDebt += restant;
      if (restant > 20000) {
        urgentPurchases.add(p);
      }
      if (restant <= (avgRevenue > 0 ? avgRevenue * 0.2 : 15000)) {
        smallDebts.add(p);
      }
    }

    final double suggestedDailyPayment = hasRevenues ? (totalDebt < avgRevenue * 0.2 ? totalDebt : (avgRevenue * 0.2).roundToDouble()) : 0;

    final List<Map<String, dynamic>> cards = [];

    // Priority 1: Overdue debt
    if (urgentPurchases.isNotEmpty) {
      final topUrgent = urgentPurchases.first;
      final supplierNom = topUrgent['supplierNom'] ?? (topUrgent['supplier'] != null ? topUrgent['supplier']['nom'] : 'Fournisseur');
      cards.add({
        'priority': 1,
        'type': 'overdue',
        'title': 'Priorité : Dette en retard',
        'subtitle': '$supplierNom - Dette urgente',
        'buttonText': 'Rembourser',
        'supplierNom': supplierNom,
        'suggestedAmount': (topUrgent['montant_restant'] ?? 0).toDouble(),
        'colorHex': '#DC2626',
      });
    }

    // Priority 2: Small balance quick settlement ("Petit à petit : Solde rapide")
    if (smallDebts.isNotEmpty) {
      final topSmall = smallDebts.first;
      final supplierNom = topSmall['supplierNom'] ?? (topSmall['supplier'] != null ? topSmall['supplier']['nom'] : 'Fournisseur');
      final restant = (topSmall['montant_restant'] ?? 0).toDouble();
      cards.add({
        'priority': 2,
        'type': 'quick_settle',
        'title': 'Petit à petit : Solde rapide',
        'subtitle': '$supplierNom - ${restant.toInt()} FCFA',
        'buttonText': 'Rembourser',
        'supplierNom': supplierNom,
        'suggestedAmount': restant,
        'colorHex': '#16A34A',
      });
    }

    // Priority 3: Save for tomorrow
    cards.add({
      'priority': 3,
      'type': 'prepare_tomorrow',
      'title': 'Conseil : Prépare demain',
      'subtitle': 'Garde un peu de ta recette pour l\'achat de demain.',
      'colorHex': '#0284C7',
    });

    // Priority 4: Upcoming date
    cards.add({
      'priority': 4,
      'type': 'upcoming_date',
      'title': 'Astuce : Date proche',
      'subtitle': 'Un paiement important est à anticiper prochainement.',
      'colorHex': '#475569',
    });

    return {
      'hasRevenues': hasRevenues,
      'noticeMessage': hasRevenues ? null : '« Enregistre tes recettes pour recevoir un conseil plus précis. »',
      'avgRevenue': avgRevenue,
      'totalDebt': totalDebt,
      'suggestedDailyPayment': suggestedDailyPayment,
      'cards': cards,
    };
  }

  // --- HELPER: Debugging ---
  static Future<void> logAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchases = prefs.getString(_keyPurchases);
      final suppliers = prefs.getString(_keySuppliers);
      debugPrint('--- DEBUG OFFLINE DATA ---');
      debugPrint('Suppliers: $suppliers');
      debugPrint('Purchases: $purchases');
      debugPrint('--------------------------');
    } catch (e) {
      debugPrint('Error logging data: $e');
    }
  }

  // --- HELPER: Recalculate Supplier Debt Locally ---
  static Future<void> _recalculateSupplierDebtLocally(dynamic supplierId, String? supplierNom) async {
    final suppliers = await getSuppliers();
    final purchases = await getPurchases();

    for (var s in suppliers) {
      final isTarget = (supplierId != null && s['id'] == supplierId) ||
          (supplierNom != null && supplierNom.isNotEmpty && s['nom'] == supplierNom);
      if (isTarget) {
        final supplierPurchases = purchases.where((p) =>
            (supplierId != null && p['supplier_id'] == supplierId) ||
            (supplierNom != null && supplierNom.isNotEmpty && p['supplierNom'] == supplierNom)).toList();
        
        double totalDebt = 0;
        int activeCount = 0;
        for (var p in supplierPurchases) {
          final restant = (p['montant_restant'] ?? 0).toDouble();
          if (restant > 0) {
            totalDebt += restant;
            activeCount++;
          }
        }

        s['dette'] = totalDebt;
        s['nbAchats'] = activeCount;
      }
    }

    await saveSuppliers(suppliers);
  }
}
