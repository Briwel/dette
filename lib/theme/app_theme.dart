import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Colors.blue;
  static const Color debtRed = Colors.red;
  static const Color partialPaymentOrange = Colors.orange;
  static const Color paidGreen = Colors.green;
  static const Color revenuePurple = Colors.deepPurple;
  
  static const Color backgroundColor = Color(0xFFF5F9FC); // Fond très clair
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        background: AppColors.backgroundColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
