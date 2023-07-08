import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ambilytics/ambilytics.dart';

void main() {
  test('Ambylitics with empty params doesn\'t get initilized', () {
    initAnalytics();
    expect(ambilytics, null);
    expect(firebaseAnalytics, null);
    expect(isInitialized(), false);
  });
}

class MockAmbyliticsObserver extends Mock implements AmbyliticsObserver {}
