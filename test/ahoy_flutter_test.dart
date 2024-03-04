import 'package:ahoy_flutter/ahoy_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:http/http.dart' as http;

class MockTokenManager extends Mock implements TokenManager {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late Ahoy ahoy;
  late MockTokenManager mockTokenManager;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockTokenManager = MockTokenManager();
    mockHttpClient = MockHttpClient();
    ahoy = Ahoy(
      configuration: Configuration(
        baseUrl: 'https://example.com',
        ahoyPath: 'ahoy',
        visitsPath: 'visits',
        eventsPath: 'events',
        environment: ApplicationEnvironment(
          platform: 'flutter',
          appVersion: '1.0.0',
          osVersion: '1.0.0',
        ),
      ),
      tokenStorage: mockTokenManager,
    );
  });

  group('Ahoy', () {
    test('trackVisit should return a Visit object', () async {
      // Mock the token manager to return a fixed token
      when(mockTokenManager.visitorToken)
          .thenAnswer((_) async => 'visitorToken');
      when(mockTokenManager.visitToken).thenAnswer((_) async => 'visitToken');

      // Mock the HTTP client to return a successful response
      when(
        mockHttpClient.post(
          any as dynamic,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"visitor_token": "visitorToken", "visit_token": "visitToken"}',
          200,
        ),
      );

      // Replace the default HTTP client with the mock

      final visit = await ahoy.trackVisit();
      expect(visit.visitorToken, 'visitorToken');
      expect(visit.visitToken, 'visitToken');
    });

    test('track should throw NoVisitError if no visit is tracked', () async {
      expect(() => ahoy.track([]), throwsA(isA<NoVisitError>()));
    });

    test('trackSingle should track a single event', () async {
      // Mock the token manager to return a fixed token
      when(mockTokenManager.visitorToken)
          .thenAnswer((_) async => 'visitorToken');
      when(mockTokenManager.visitToken).thenAnswer((_) async => 'visitToken');

      // Mock the HTTP client to return a successful response
      when(
        mockHttpClient.post(
          any as dynamic,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"visitor_token": "visitorToken", "visit_token": "visitToken"}',
          200,
        ),
      );

      // Replace the default HTTP client with the mock

      // Track a single event
      ahoy.trackSingle('eventName');
      // Add assertions here to verify the event was tracked correctly
    });

    test('authenticate should update the currentVisit with the provided userId',
        () async {
      // Mock the token manager to return a fixed token
      when(mockTokenManager.visitorToken)
          .thenAnswer((_) async => 'visitorToken');
      when(mockTokenManager.visitToken).thenAnswer((_) async => 'visitToken');

      // Authenticate a user
      ahoy.authenticate('userId');

      // Verify the currentVisit was updated
      expect(ahoy.currentVisit?.userId, 'userId');
    });
  });
}
