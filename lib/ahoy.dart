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

class Ahoy {
  Visit? currentVisit;
  List<String> headers = [];
  List<RequestInterceptor> requestInterceptors = [];
  Configuration configuration;
  AhoyTokenManager storage;
  Set<StreamSubscription> cancellables = {};

  Ahoy({
    required this.configuration,
    this.requestInterceptors = const [],
    AhoyTokenManager tokenStorage = const TokenManager(),
  }) : storage = tokenStorage;

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

    final response = await dataTaskPublisher(
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

    final response = await dataTaskPublisher(
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

  void trackSingle(String eventName, {Map<String, dynamic>? properties}) {
    track([Event(name: eventName, properties: properties ?? {})]);
  }

  void authenticate(String userId) {
    currentVisit = currentVisit?.copyWith(userId: userId);
  }

  Future<Response> dataTaskPublisher<Body>({
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

    for (final interceptor in requestInterceptors) {
      interceptor.interceptRequest(request);
    }

    return Response.fromStream(await request.send())
      ..then((response) => validateResponse(response));
  }
}
