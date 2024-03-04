import 'dart:convert';

import 'package:ahoy_flutter/src/expiring_persisted.dart';

sealed class AhoyTokenManager {
  Future<String> get visitToken;
  Future<String> get visitorToken;

  const AhoyTokenManager();
}

class TokenManager extends AhoyTokenManager {
  final Duration expiryPeriod;
  const TokenManager({this.expiryPeriod = const Duration(minutes: 30)});
  static const JsonEncoder jsonEncoder = JsonEncoder();
  static const JsonDecoder jsonDecoder = JsonDecoder();

  @override
  Future<String> get visitToken async {
    return await ExpiringPersisted<String>(
      key: 'ahoy_visit_token',
      expiryPeriod: expiryPeriod,
    ).value;
  }

  @override
  Future<String> get visitorToken async {
    return await ExpiringPersisted<String>(
      key: 'ahoy_visitor_token',
      expiryPeriod: expiryPeriod,
    ).value;
  }
}
