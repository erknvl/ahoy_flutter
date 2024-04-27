import 'dart:convert';

import 'package:ahoy_flutter/src/expiring_persisted.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

sealed class AhoyTokenManager {
  Future<String> get visitToken;
  Future<String> get visitorToken;
  Future<void> resetVisitToken();
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
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('ahoy_visitor_token');
    if (data == null) {
      final visitorToken = const Uuid().v4();
      prefs.setString('ahoy_visitor_token', visitorToken);
      return visitorToken;
    }

    return data;
  }

  @override
  Future<void> resetVisitToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ahoy_visit_token');
  }
}
