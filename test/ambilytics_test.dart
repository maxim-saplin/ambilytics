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
    // !In debug mode test fails due to frozen FB Analytics init

    // // in fact this assertion doesn't hold cause there's endless wait inside when firebase starts inint and test just preoceeds due t no actual await
    //expect(() async => await initAnalytics(), throwsAssertionError);
    var flag = false;
    try {
      await initAnalytics();
    } catch (_) {
      flag = true;
    }
    expect(flag, true);
    expect(ambilytics, null);
    expect(firebaseAnalytics, null);
    expect(isAmbyliticsInitialized, false);
    expect(initError, isNotNull);
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

  test('Ambylitics sends custom_event', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    var mock = MockAmbilyticsSession();
    setMockAmbilytics(mock);
    // Hiding MP paramas to use mocked instance instead
    await initAnalytics(
        //measurementId: 'someId', apiSecret: 'someSecret',
        fallbackToMP: true);
    expect(isAmbyliticsInitialized, true);
    clearInteractions(mock);
    sendEvent('custom_event', {'custom_param': 'val1'});
    final captured =
        verify(() => mock.sendEvent(captureAny(), captureAny())).captured;
    expect(captured[0], 'custom_event');
    expect((captured[1] as Map)['custom_param'], 'val1');
    debugDefaultTargetPlatformOverride = null;
  });

  test('Ambylitics can skip init and sendsEvent() doesn\'t throw', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    var mock = MockAmbilyticsSession();
    setMockAmbilytics(mock);
    // Hiding MP paramas to use mocked instance instead
    await initAnalytics(dontInintilize: true);
    expect(isAmbyliticsInitialized, false);
    clearInteractions(mock);
    sendEvent('custom_event', {'custom_param': 'val1'});
    final captured =
        verifyNever(() => mock.sendEvent(captureAny(), captureAny())).captured;
    expect(captured.length, 0);
    debugDefaultTargetPlatformOverride = null;
  });

  test('Firebase analytics sends app_launch event with correct platfrom',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var mock = MockFirebaseAnalytics();
    when(() => mock.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
        callOptions: any(named: 'callOptions'))).thenAnswer((_) async {});
    setMockFirebase(mock);
    await initAnalytics(fallbackToMP: true);
    expect(isAmbyliticsInitialized, true);
    final captured = verify(() => mock.logEvent(
        name: captureAny(named: 'name'),
        parameters: captureAny(named: 'parameters'),
        callOptions: captureAny(named: 'callOptions'))).captured;
    expect(captured[0], 'app_launch');
    expect((captured[1] as Map)['platform'], 'iOS');
    debugDefaultTargetPlatformOverride = null;
  });

  test('Firebase analytics sends custom_event', () async {
    var mock = MockFirebaseAnalytics();
    setMockFirebase(mock);
    when(() => mock.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
        callOptions: any(named: 'callOptions'))).thenAnswer((_) async {});
    await initAnalytics(fallbackToMP: true);
    expect(isAmbyliticsInitialized, true);
    clearInteractions(mock);
    sendEvent('custom_event', {'custom_param': 'val1'});
    final captured = verify(() => mock.logEvent(
        name: captureAny(named: 'name'),
        parameters: captureAny(named: 'parameters'),
        callOptions: captureAny(named: 'callOptions'))).captured;
    expect(captured[0], 'custom_event');
    expect((captured[1] as Map)['custom_param'], 'val1');
  });
}

//TODO, better add separate widget tests when /example is ready and simulate navigation there
class MockAmbyliticsObserver extends Mock implements AmbyliticsObserver {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockAmbilyticsSession extends Mock implements AmbilyticsSession {}
