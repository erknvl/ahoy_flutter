library ahoy_flutter;

export 'src/ahoy_error.dart';
export 'src/configuration.dart';
export 'src/event.dart';
export 'src/request_interceptor.dart';
export 'src/token_manager.dart';
export 'src/visit.dart';

import 'dart:async';
import 'dart:convert';

import 'package:ahoy_flutter/src/ahoy_error.dart';
import 'package:ahoy_flutter/src/configuration.dart';
import 'package:ahoy_flutter/src/event.dart';
import 'package:ahoy_flutter/src/event_request_input.dart';
import 'package:ahoy_flutter/src/publisher_ahoy.dart';
import 'package:ahoy_flutter/src/request_interceptor.dart';
import 'package:ahoy_flutter/src/token_manager.dart';

import 'package:ahoy_flutter/src/visit.dart';
import 'package:ahoy_flutter/src/visit_request_input.dart';
import 'package:http/http.dart';

/// The main class of the Ahoy library. It is used to track visits and events
/// to a server.
class Ahoy {
  Visit? currentVisit;
  final Map<String, String> headers;
  final List<RequestInterceptor> requestInterceptors;

  /// The configuration object for the Ahoy instance. It contains the base URL
  /// of the server, the paths for the visits and events endpoints, and the
  /// environment information.
  Configuration configuration;

  /// The token manager used to store and retrieve the visitor and visit tokens
  /// from the device's storage. By default, it uses the [TokenManager] class.
  /// You can provide your own implementation by extending the [AhoyTokenManager]
  AhoyTokenManager storage;

  /// A set of subscriptions to cancel when the Ahoy instance is disposed.
  Set<StreamSubscription> cancellables = {};

  Ahoy({
    required this.configuration,
    this.headers = const {},
    this.requestInterceptors = const [],
    AhoyTokenManager tokenStorage = const TokenManager(),
  }) : storage = tokenStorage;

  /// Track a visit to the server and return a [Visit] object
  /// with the visitor and visit tokens.
  /// Optionally, you can pass additional parameters to be sent to the server.
  Future<Visit> trackVisit({
    Object? landingPage,
    Object? referrer,
    Map<String, dynamic>? additionalParams,
  }) async {
    final visit = Visit(
      visitorToken: await storage.visitorToken,
      visitToken: await storage.visitToken,
      additionalParams: additionalParams,
    );

    final requestInput = VisitRequestInput(
      visitorToken: visit.visitorToken,
      visitToken: visit.visitToken,
      platform: configuration.environment.platform,
      appVersion: configuration.environment.appVersion,
      osVersion: configuration.environment.osVersion,
      additionalParams: additionalParams,
    );

    final queryParameters = {
      'visit_token': visit.visitToken,
      'visitor_token': visit.visitorToken,
      'user_id': visit.userId,
      'os_version': configuration.environment.osVersion,
      'device_type': 'mobile',
      'started_at': '${DateTime.now().toUtc().toString().split('.')[0]} +0000',
    };

    final response = await _dataTaskPublisher(
      path: configuration.visitsPath,
      host: configuration.baseUrl,
      port: 3001,
      body: jsonEncode(requestInput.toJson()),
      visit: visit,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      currentVisit = visit;
      return visit;
    } else {
      throw MismatchingVisitError();
    }
  }

  /// Track a list of events to the server. The events will be associated
  /// with the current visit. If no visit is tracked, a [NoVisitError] will be thrown.
  /// Optionally, you can pass additional parameters to be sent to the server.
  Future<void> track(List<Event> events) async {
    if (currentVisit == null) {
      throw NoVisitError();
    }

    final now = DateTime.now().toUtc();
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    for (final event in events) {
      final queryParameters = {
        'visit_token': currentVisit!.visitToken,
        'visitor_token': currentVisit!.visitorToken,
        'user_id': currentVisit!.userId,
        'os': configuration.environment.platform,
        'device_type': 'mobile',
        'time': '${DateTime.now().toUtc().toString().split('.')[0]} +0000',
        'day': formattedDate,
        'name': event.name,
        'properties': jsonEncode(event.properties),
      };
      final response = await _dataTaskPublisher<EventRequestInput>(
        path: configuration.eventsPath,
        port: 3001,
        host: configuration.baseUrl,
        body: jsonEncode(event.properties),
        visit: currentVisit!,
        queryParameters: queryParameters,
      );

      if (response.statusCode != 200) {
        throw UnacceptableResponseError(
          code: response.statusCode,
          data: response.body,
        );
      }
    }
  }

  /// Track a single event to the server. The event will be associated
  /// with the current visit. If no visit is tracked, a [NoVisitError] will be thrown.
  /// Optionally, you can pass additional parameters to be sent to the server.
  void trackSingle(String eventName, {Map<String, dynamic>? properties}) {
    track([Event(name: eventName, properties: properties ?? {})]);
  }

  /// Authenticate the current visit with a user ID.
  void authenticate(String userId) {
    currentVisit = currentVisit?.copyWith(userId: userId);
  }

  Future<Response> _dataTaskPublisher<Body>({
    required String path,
    required String body,
    required Visit visit,
    required String host,
    required int port,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: host,
      port: port,
      path: '${configuration.ahoyPath}/$path',
      queryParameters: queryParameters,
    );

    final request = Request('POST', uri);

    request.body = body;
    request.headers['Content-Type'] = 'application/json; charset=utf-8';

    if (headers != null) {
      request.headers.addAll(headers);
    }
    for (final interceptor in requestInterceptors) {
      interceptor.interceptRequest(request);
    }
    final handledRequest = await configuration.urlRequestHandler(request);

    return Response.fromStream(handledRequest)
      ..then(
        (response) => validateResponse(response),
      );
  }
}
