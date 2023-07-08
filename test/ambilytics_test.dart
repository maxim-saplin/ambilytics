import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ambilytics/ambilytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Ambylitics with empty params doesn\'t get initilized', () async {
    expect(() async => await initAnalytics(), throwsAssertionError);
    expect(ambilytics, null);
    expect(firebaseAnalytics, null);
    expect(isAmbyliticsInitialized, false);
  });

  test('Ambylitics with GA4 MP params gets initilized', () async {
    // Seems like Flutter test SDK slways sets platform to Android
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await initAnalytics(measurementId: 'someId', apiSecret: 'someSecret');
    expect(ambilytics, isNotNull);
    expect(ambilytics!.userId.isEmpty, false);
    expect(ambilytics!.measutementId.isEmpty, false);
    expect(ambilytics!.apiSecret.isEmpty, false);
    expect(firebaseAnalytics, null);
    expect(isAmbyliticsInitialized, true);
    debugDefaultTargetPlatformOverride = null;
  });

  test('Ambylitics falls back to GA4 MP params when initilized', () async {
    // Seems like Flutter test SDK slways sets platform to Android
    await initAnalytics(
        measurementId: 'someId', apiSecret: 'someSecret', fallbackToMP: true);
    expect(ambilytics, isNotNull);
    expect(firebaseAnalytics, null);
    expect(isAmbyliticsInitialized, true);
  });

  test('Ambylitics sends app_launch event with correct platfrom', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    var mock = MockAmbilyticsSession();
    setMockAmbilytics(mock);
    // Hiding MP paramas to use mocked instance instead
    await initAnalytics(
        //measurementId: 'someId', apiSecret: 'someSecret',
        fallbackToMP: true);
    expect(isAmbyliticsInitialized, true);
    final captured =
        verify(() => mock.sendEvent(captureAny(), captureAny())).captured;
    expect(captured[0], 'app_launch');
    expect((captured[1] as Map)['platform'], 'linux');
    debugDefaultTargetPlatformOverride = null;
  });
}

class MockAmbyliticsObserver extends Mock implements AmbyliticsObserver {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockAmbilyticsSession extends Mock implements AmbilyticsSession {}
