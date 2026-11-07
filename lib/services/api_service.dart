import 'package:flutter/foundation.dart';
import 'offline_storage_service.dart';

/// Service API 100% hors-ligne.
/// Toutes les données sont stockées localement via SharedPreferences.
/// Aucune connexion réseau n'est nécessaire.
class ApiService {
  // --- SUPPLIERS ---

  static Future<List<dynamic>> getSuppliers() async {
    return await OfflineStorageService.getSuppliers();
  }

  static Future<dynamic> getSupplierDetail(int id) async {
    final suppliers = await OfflineStorageService.getSuppliers();
    final s = suppliers.firstWhere(
      (e) => e['id']?.toString() == id.toString(),
      orElse: () => <String, dynamic>{},
    );
    final purchases = await OfflineStorageService.getPurchases(supplierId: id);
    return {...s, 'purchases': purchases};
  }

  static Future<dynamic> addSupplier(Map<String, dynamic> data) async {
    return await OfflineStorageService.addSupplier(data);
  }

  static Future<dynamic> updateSupplier(
      dynamic id, Map<String, dynamic> data) async {
    return await OfflineStorageService.updateSupplier(id, data);
  }

  static Future<dynamic> deleteSupplier(dynamic id) async {
    return await OfflineStorageService.deleteSupplier(id);
  }

  // --- PURCHASES ---

  static Future<dynamic> getPurchasesSummary() async {
    return await OfflineStorageService.getPurchasesSummary();
  }

  static Future<List<dynamic>> getPurchases(
      {int? supplierId, String? supplierNom}) async {
    final result = await OfflineStorageService.getPurchases(
      supplierId: supplierId,
      supplierNom: supplierNom,
    );
    debugPrint(
        'ApiService.getPurchases(id=$supplierId, nom=$supplierNom) → ${result.length} résultats');
    return result;
  }

  static Future<dynamic> addPurchase(Map<String, dynamic> data) async {
    return await OfflineStorageService.addPurchase(data);
  }

  // --- REPAYMENTS ---

  static Future<dynamic> addRepayment(Map<String, dynamic> data) async {
    return await OfflineStorageService.addRepayment(data);
  }

  // --- PLANNED REPAYMENTS ---

  static Future<List<dynamic>> getPlannedRepayments() async {
    return await OfflineStorageService.getPlannedRepayments();
  }

  static Future<dynamic> addPlannedRepayment(Map<String, dynamic> data) async {
    return await OfflineStorageService.addPlannedRepayment(data);
  }

  static Future<void> markPlanningAsDone(dynamic id) async {
    return await OfflineStorageService.markPlanningAsDone(id);
  }

  static Future<void> deletePlanning(dynamic id) async {
    return await OfflineStorageService.deletePlanning(id);
  }

  // --- DAILY REVENUES ---

  static Future<List<dynamic>> getDailyRevenues() async {
    return await OfflineStorageService.getDailyRevenues();
  }

  static Future<dynamic> getDailyRevenuesSummary() async {
    return await OfflineStorageService.getDailyRevenuesSummary();
  }

  static Future<dynamic> addDailyRevenue(Map<String, dynamic> data) async {
    return await OfflineStorageService.addDailyRevenue(data);
  }

  // --- REPAYMENT ADVICE ---

  static Future<dynamic> getRepaymentAdvice() async {
    return await OfflineStorageService.getRepaymentAdvice();
  }

  // --- SYNC (no-op en mode hors-ligne) ---
  static Future<void> syncPendingData() async {
    debugPrint('Mode hors-ligne : synchronisation ignorée.');
  }
}
