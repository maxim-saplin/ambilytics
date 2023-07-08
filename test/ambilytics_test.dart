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
    expect(isInitialized(), false);
  });

  test('Ambylitics with GA4 MP params gets initilized', () async {
    // Seems like Flutter test SDK slways sets platform to Android
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await initAnalytics(measurementId: 'someId', apiSecret: 'someSecret');
    expect(ambilytics, isNotNull);
    expect(firebaseAnalytics, null);
    expect(isInitialized(), true);
    debugDefaultTargetPlatformOverride = null;
  });
}

class MockAmbyliticsObserver extends Mock implements AmbyliticsObserver {}
