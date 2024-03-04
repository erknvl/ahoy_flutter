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
import 'package:ahoy_flutter/src/user_id_decorated.dart';
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
  Future<Visit> trackVisit({Map<String, dynamic>? additionalParams}) async {
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

    final response = await _dataTaskPublisher(
      path: configuration.visitsPath,
      body: requestInput,
      visit: visit,
    );

    if (response.statusCode == 200) {
      final visitResponse = Visit.fromJson(jsonDecode(response.body));
      if (visit.visitorToken == visitResponse.visitorToken &&
          visit.visitToken == visitResponse.visitToken) {
        currentVisit = visit;
        return visit;
      } else {
        throw MismatchingVisitError();
      }
    } else {
      throw UnacceptableResponseError(
        code: response.statusCode,
        data: response.body,
      );
    }
  }

  /// Track a list of events to the server. The events will be associated
  /// with the current visit. If no visit is tracked, a [NoVisitError] will be thrown.
  /// Optionally, you can pass additional parameters to be sent to the server.
  Future<void> track(List<Event> events) async {
    if (currentVisit == null) {
      throw NoVisitError();
    }

    final requestInput = EventRequestInput(
      visitorToken: currentVisit!.visitorToken,
      visitToken: currentVisit!.visitToken,
      events: events.map(
        (event) {
          return UserIdDecorated(userId: currentVisit!.userId, wrapped: event);
        },
      ).toList(),
    );

    final response = await _dataTaskPublisher(
      path: configuration.eventsPath,
      body: requestInput,
      visit: currentVisit!,
    );

    if (response.statusCode != 200) {
      throw UnacceptableResponseError(
        code: response.statusCode,
        data: response.body,
      );
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
    required Body body,
    required Visit visit,
  }) async {
    final request = Request(
      'POST',
      Uri.parse('${configuration.baseUrl}/${configuration.ahoyPath}/$path'),
    );
    request.body = jsonEncode(body);
    request.headers['Content-Type'] = 'application/json; charset=utf-8';
    request.headers['Ahoy-Visitor'] = visit.visitorToken;
    request.headers['Ahoy-Visit'] = visit.visitToken;
    request.headers.addAll(headers);
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
