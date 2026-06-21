import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

class SubscriptionActionResult {
  final bool success;
  final bool cancelled;
  final bool premiumActive;
  final String? message;

  const SubscriptionActionResult({
    required this.success,
    this.cancelled = false,
    this.premiumActive = false,
    this.message,
  });
}

class SubscriptionService {
  SubscriptionService();

  static const String _premiumEntitlementId =
      AppConfig.revenueCatPremiumEntitlement;

  bool get hasBillingEnabled => AppConfig.isRevenueCatConfigured;

  bool get hasRevenueCatConfig => AppConfig.isRevenueCatConfigured;

  Future<void> initializeRevenueCat(String userId) async {
    if (!hasRevenueCatConfig) return;

    final apiKey = _platformApiKey;
    if (apiKey == null) return;

    if (!await Purchases.isConfigured) {
      final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
      await Purchases.configure(configuration);
    } else {
      await Purchases.logIn(userId);
    }
  }

  Future<SubscriptionActionResult> purchaseMonthlySubscription() async {
    if (!hasBillingEnabled) {
      return const SubscriptionActionResult(
        success: false,
        premiumActive: false,
        message: 'Premium checkout is not configured yet for this build.',
      );
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return const SubscriptionActionResult(
          success: false,
          premiumActive: false,
          message:
              'Premium checkout is temporarily unavailable. Please try again shortly.',
        );
      }

      final targetPackage = _pickPreferredPackage(current.availablePackages);
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(targetPackage),
      );
      final premiumActive = _hasPremiumEntitlement(purchaseResult.customerInfo);
      return SubscriptionActionResult(
        success: premiumActive,
        premiumActive: premiumActive,
        message: premiumActive
            ? 'Premium unlocked successfully.'
            : 'Purchase completed, but premium access was not detected yet.',
      );
    } on PlatformException catch (error) {
      final cancelled =
          PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError;
      return SubscriptionActionResult(
        success: false,
        cancelled: cancelled,
        premiumActive: false,
        message: cancelled
            ? null
            : error.message ?? 'Premium checkout could not be completed.',
      );
    } catch (_) {
      return const SubscriptionActionResult(
        success: false,
        premiumActive: false,
        message: 'Premium checkout could not be completed.',
      );
    }
  }

  Future<SubscriptionActionResult> restorePurchases() async {
    if (!hasBillingEnabled) {
      return const SubscriptionActionResult(
        success: false,
        premiumActive: false,
        message: 'Purchase restore is not configured yet for this build.',
      );
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      final premiumActive = _hasPremiumEntitlement(customerInfo);
      return SubscriptionActionResult(
        success: premiumActive,
        premiumActive: premiumActive,
        message: premiumActive
            ? 'Premium purchases restored successfully.'
            : 'No active premium purchases were found to restore.',
      );
    } on PlatformException catch (error) {
      return SubscriptionActionResult(
        success: false,
        premiumActive: false,
        message: error.message ?? 'Purchase restore could not be completed.',
      );
    } catch (_) {
      return const SubscriptionActionResult(
        success: false,
        premiumActive: false,
        message: 'Purchase restore could not be completed.',
      );
    }
  }

  Future<bool> checkPremiumEntitlement() async {
    if (!hasBillingEnabled || !await Purchases.isConfigured) {
      return false;
    }
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _hasPremiumEntitlement(customerInfo);
    } catch (_) {
      return false;
    }
  }

  Future<String> currentPriceLabel() async {
    if (!hasBillingEnabled) return '';
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return '';
      }
      final targetPackage = _pickPreferredPackage(current.availablePackages);
      return targetPackage.storeProduct.priceString;
    } catch (_) {
      return '';
    }
  }

  Future<void> openManageSubscriptions() async {
    return;
  }

  Future<void> logout() async {
    if (!hasBillingEnabled || !await Purchases.isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (_) {
      return;
    }
  }

  String? get _platformApiKey {
    if (Platform.isIOS) return AppConfig.revenueCatIosApiKey;
    if (Platform.isAndroid) return AppConfig.revenueCatAndroidApiKey;
    return null;
  }

  bool _hasPremiumEntitlement(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.containsKey(_premiumEntitlementId)) {
      return true;
    }
    return customerInfo.entitlements.active.isNotEmpty;
  }

  Package _pickPreferredPackage(List<Package> packages) {
    for (final package in packages) {
      final identifier = package.identifier.toLowerCase();
      final productId = package.storeProduct.identifier.toLowerCase();
      if (identifier.contains('month') ||
          identifier.contains('monthly') ||
          productId.contains('month') ||
          productId.contains('monthly')) {
        return package;
      }
    }
    return packages.first;
  }
}
