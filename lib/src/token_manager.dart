import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

export 'token_manager.dart';

const String _visitorTokenKey = 'ahoy_visitor_token';
const String _visitTokenKey = 'ahoy_visit_token';

abstract class AhoyTokenManager {
  String get visitorToken;
  String get visitToken;
}

class SharedPreferencesTokenManager implements AhoyTokenManager {
  static const Duration visitDuration = Duration(minutes: 30);

  static const JsonEncoder jsonEncoder = JsonEncoder();
  static const JsonDecoder jsonDecoder = JsonDecoder();

  late String _visitToken;
  late String _visitorToken;
  late SharedPreferences _storage;
  SharedPreferencesTokenManager() {
    _visitToken = _getVisitToken();
    _visitorToken = _getVisitorToken();
    SharedPreferences.getInstance().then((prefs) {
      _storage = prefs;
    });
  }

  @override
  String get visitToken => _visitToken;

  @override
  String get visitorToken => _visitorToken;

  String _getVisitToken() {
    if (_storage.containsKey(_visitTokenKey) &&
        _storage.getString(_visitTokenKey) != null) {
      final token = _storage.getString(_visitTokenKey);

      return token!;
    } else {
      final visitTokenFromUuid = const Uuid().v4();
      _storage.setString(_visitTokenKey, visitTokenFromUuid);
      return visitTokenFromUuid;
    }
  }

  String _getVisitorToken() {
    if (_storage.containsKey(_visitorTokenKey) &&
        _storage.getString(_visitorTokenKey) != null) {
      final token = _storage.getString(_visitorTokenKey);

      return token!;
    } else {
      final visitorTokenFromUuid = const Uuid().v4();
      _storage.setString(_visitorTokenKey, visitorTokenFromUuid);
      return visitorTokenFromUuid;
    }
  }
}
