import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'offline_storage_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:3000';
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$endpoint'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API GET offline fallback ($endpoint): $e');
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API POST offline fallback ($endpoint): $e');
      rethrow;
    }
  }

  // --- SUPPLIERS ---
  static Future<List<dynamic>> getSuppliers() async {
    try {
      final serverData = await get('suppliers');
      final list = (serverData as List).cast<dynamic>();
      await OfflineStorageService.saveSuppliers(list);
      return list;
    } catch (_) {
      final local = await OfflineStorageService.getSuppliers();
      return local;
    }
  }

  static Future<dynamic> getSupplierDetail(int id) async {
    try {
      return await get('suppliers/$id');
    } catch (_) {
      final suppliers = await OfflineStorageService.getSuppliers();
      final s = suppliers.firstWhere((element) => element['id'] == id, orElse: () => {});
      final purchases = await OfflineStorageService.getPurchases(supplierId: id);
      return {
        ...s,
        'purchases': purchases,
      };
    }
  }

  static Future<dynamic> addSupplier(Map<String, dynamic> data) async {
    final localItem = await OfflineStorageService.addSupplier(data);

    try {
      final res = await post('suppliers', data);
      localItem['sync_status'] = 'synchronized';
      if (res is Map && res.containsKey('id')) {
        localItem['id'] = res['id'];
      }
      final suppliers = await OfflineStorageService.getSuppliers();
      for (var s in suppliers) {
        if (s['nom'] == localItem['nom']) {
          s['sync_status'] = 'synchronized';
        }
      }
      await OfflineStorageService.saveSuppliers(suppliers);
      return res;
    } catch (e) {
      debugPrint('Supplier saved locally (offline pending): $e');
      return localItem;
    }
  }

  // --- PURCHASES ---
  static Future<dynamic> getPurchasesSummary() async {
    try {
      return await get('purchases/summary');
    } catch (_) {
      return await OfflineStorageService.getPurchasesSummary();
    }
  }

  static Future<List<dynamic>> getPurchases({int? supplierId}) async {
    try {
      String endpoint = 'purchases';
      if (supplierId != null) {
        endpoint += '?supplierId=$supplierId';
      }
      final res = await get(endpoint);
      final list = (res as List).cast<dynamic>();
      await OfflineStorageService.savePurchases(list);
      return list;
    } catch (_) {
      return await OfflineStorageService.getPurchases(supplierId: supplierId);
    }
  }

  static Future<dynamic> addPurchase(Map<String, dynamic> data) async {
    final localItem = await OfflineStorageService.addPurchase(data);

    try {
      final res = await post('purchases', data);
      localItem['sync_status'] = 'synchronized';
      return res;
    } catch (e) {
      debugPrint('Purchase saved locally (offline pending): $e');
      return localItem;
    }
  }

  // --- REPAYMENTS ---
  static Future<dynamic> addRepayment(Map<String, dynamic> data) async {
    final localItem = await OfflineStorageService.addRepayment(data);

    try {
      final res = await post('repayments', data);
      localItem['sync_status'] = 'synchronized';
      return res;
    } catch (e) {
      debugPrint('Repayment saved locally (offline pending): $e');
      return localItem;
    }
  }

  // --- DAILY REVENUES ---
  static Future<List<dynamic>> getDailyRevenues() async {
    try {
      final res = await get('daily-revenues');
      final list = (res as List).cast<dynamic>();
      await OfflineStorageService.saveDailyRevenues(list);
      return list;
    } catch (_) {
      return await OfflineStorageService.getDailyRevenues();
    }
  }

  static Future<dynamic> getDailyRevenuesSummary() async {
    try {
      return await get('daily-revenues/summary');
    } catch (_) {
      return await OfflineStorageService.getDailyRevenuesSummary();
    }
  }

  static Future<dynamic> addDailyRevenue(Map<String, dynamic> data) async {
    final localItem = await OfflineStorageService.addDailyRevenue(data);

    try {
      final res = await post('daily-revenues', data);
      localItem['sync_status'] = 'synchronized';
      return res;
    } catch (e) {
      debugPrint('Daily revenue saved locally (offline pending): $e');
      return localItem;
    }
  }

  // --- CONSEILS DE REMBOURSEMENT (Section 13) ---
  static Future<dynamic> getRepaymentAdvice() async {
    try {
      return await get('repayment-advice');
    } catch (_) {
      return await OfflineStorageService.getRepaymentAdvice();
    }
  }

  // --- SYNC PENDING DATA WHEN BACK ONLINE ---
  static Future<void> syncPendingData() async {
    try {
      await get('purchases/summary');

      final suppliers = await OfflineStorageService.getSuppliers();
      for (var s in suppliers) {
        if (s['sync_status'] == 'pending') {
          try {
            await post('suppliers', s);
            s['sync_status'] = 'synchronized';
          } catch (_) {}
        }
      }
      await OfflineStorageService.saveSuppliers(suppliers);

      final purchases = await OfflineStorageService.getPurchases();
      for (var p in purchases) {
        if (p['sync_status'] == 'pending') {
          try {
            await post('purchases', p);
            p['sync_status'] = 'synchronized';
          } catch (_) {}
        }
      }
      await OfflineStorageService.savePurchases(purchases);

      final repayments = await OfflineStorageService.getRepayments();
      for (var r in repayments) {
        if (r['sync_status'] == 'pending') {
          try {
            await post('repayments', r);
            r['sync_status'] = 'synchronized';
          } catch (_) {}
        }
      }
      await OfflineStorageService.saveRepayments(repayments);

      final revenues = await OfflineStorageService.getDailyRevenues();
      for (var rev in revenues) {
        if (rev['sync_status'] == 'pending') {
          try {
            await post('daily-revenues', rev);
            rev['sync_status'] = 'synchronized';
          } catch (_) {}
        }
      }
      await OfflineStorageService.saveDailyRevenues(revenues);

      debugPrint('Offline sync completed successfully!');
    } catch (e) {
      debugPrint('Sync pending skipped (still offline): $e');
    }
  }
}
