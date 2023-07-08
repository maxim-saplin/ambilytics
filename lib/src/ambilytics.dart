import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class Events {
  static const counterClicked = "counter_clicked";
}

AmbilyticsSession? ambilytics;
FirebaseAnalytics? firebaseAnalytics;

bool _initialized = false;

bool isInitialized() => _initialized;

/// Prepares analytics for usage.
/// If the platform is Android, iOS, macOS, or Web, Firebase Analytics will be used ([firebaseAnalytics] instance will be initialized).
/// Otherwise, GA4 Measurement protocol and custom events will be used ([ambilytics] instance will be initialized).
/// If [sendAppLaunch] is true, "app_launch" will be ent with "platfrom" param value corresponding runtime platform (i.e. Windows)
/// If [dontInintilize] is `true`, analytics will not be initialized, any analytics calls will be ingonred,
/// [firebaseAnalytics] and [ambilytics] instances will be null. Usefull for the scanarious when toy wish to disable analytics.
/// [apiSecret] and [measurementId] must be set in order to enable GA4 Measurement protocol and have [ambilytics] initialized.
/// [userId] allows overriding user identifier. If not provided, default user ID will be used by Firebase Analytics OR
/// or a GUID will be created and put to shared_preferences storage (for Windows and Linux).
Future<void> initAnalytics(
    {bool sendAppLaunch = true,
    bool dontInintilize = false,
    String? measurementId,
    String? apiSecret,
    String? userId}) async {
  if (dontInintilize) return;
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        kIsWeb) {
      await Firebase.initializeApp();
      firebaseAnalytics = FirebaseAnalytics.instance;
      if (userId != null) {
        await firebaseAnalytics!.setUserId(id: userId);
      }
      _initialized = true;
      if (sendAppLaunch) {
        _sendAppLaunchEvent();
      }
      return;
    }

    // Use measurement protocol

    var ambiUserId = userId;

    if (ambiUserId == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ambiUserId = prefs.getString('userId');
      if (ambiUserId == null) {
        ambiUserId = const Uuid().v4();
        await prefs.setString('userId', ambiUserId);
      }
    }
    if (measurementId != null && apiSecret != null) {
      ambilytics = AmbilyticsSession(measurementId, apiSecret,
          'test_user_${defaultTargetPlatform.name}', false);
    }
    if (ambilytics != null || firebaseAnalytics != null) {
      _initialized = true;
      if (sendAppLaunch) {
        _sendAppLaunchEvent();
      }
    } else {
      assert(true,
          'Neither Firebase Analytics nor Measurement Protocol have been initialized');
    }
  } catch (e) {
    assert(false, 'Can\'t init anaytics due to error.\n\n$e');
    _initialized = false;
  }
}

void _sendAppLaunchEvent() {
  final params = {'platform': defaultTargetPlatform.name};
  sendEvent(PredefinedEvents.appLaunch, params);
}

void sendEvent(String eventName, [Map<String, Object?>? params]) {
  assert(!reservedGa4Events.contains(eventName));
  assert(eventName.isNotEmpty && eventName.length <= 40,
      'Event name should be between 1 and 40 characters long');
  if (firebaseAnalytics != null) {
    firebaseAnalytics!.logEvent(name: eventName, parameters: params);
  } else if (ambilytics != null) {
    ambilytics!.sendEvent(eventName, params);
  }
}

// TODO, add docs on propper setup of native projects
// e.g. If you develop for Android, permission inside the manifest tag in the AndroidManifest.xml must be added

//macOS
// macOS needs you to request a specific entitlement in order to access the network. To do that open macos/Runner/DebugProfile.entitlements and add the following key-value pair.
// <key>com.apple.security.network.client</key>
// <true/>
// Then do the same thing in macos/Runner/Release.entitlements.

/// Filter out non PageRoute ones
bool defaultRouteFilter(Route<dynamic>? route) => route is PageRoute;

/// Accepts any routes, e.g. the ones added via showDialog()
bool anyRouteFilter(Route<dynamic>? route) => true;
String? defaultNameExtractor(RouteSettings settings) => settings.name;

/// Alternative to [FirebaseAnalyticsObserver] which intercepts
/// Flutter nivigation events and send screen view events.
/// The difference is that for unsupported platforms (e.g. Linux, Window)
/// of if FirebaseAnalytics is not configured
/// the app uses Measurement Protocol and sends custom 'screen_view_cust'
/// event together with screen name.
class AmbyliticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  AmbyliticsObserver(
      {this.nameExtractor = defaultNameExtractor,
      this.routeFilter = defaultRouteFilter,
      this.alwaySendScreenViewCust = false,
      Function(PlatformException error)? onError})
      : assert(_initialized, 'Ambilytics must be initialized first') {
    if (firebaseAnalytics != null) {
      faObserver = FirebaseAnalyticsObserver(
          analytics: firebaseAnalytics!,
          nameExtractor: nameExtractor,
          routeFilter: routeFilter,
          onError: onError);
    }
  }

  FirebaseAnalyticsObserver? faObserver;
  final ScreenNameExtractor nameExtractor;
  final RouteFilter routeFilter;
  final bool alwaySendScreenViewCust;
  void Function(PlatformException error)? onError;

  void _sendScreenView(Route<dynamic> route) {
    assert(route.settings.name != null, 'Route name cannot be null');
    final name = route.settings.name!;
    if (ambilytics != null) {
      ambilytics!
          .sendEvent(PredefinedEvents.screenViewCust, {'screen_name': name});
    } else {
      firebaseAnalytics!.logEvent(
          name: PredefinedEvents.screenViewCust,
          parameters: {'screen_name': name});
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (faObserver != null) {
      faObserver!.didPush(route, previousRoute);
      if (!alwaySendScreenViewCust) return;
    }
    if (routeFilter(route)) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (faObserver != null) {
      faObserver!.didReplace(newRoute: newRoute, oldRoute: oldRoute);
      if (!alwaySendScreenViewCust) return;
    }
    if (newRoute != null && routeFilter(newRoute)) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (faObserver != null) {
      faObserver!.didPop(route, previousRoute);
      if (!alwaySendScreenViewCust) return;
    }
    if (previousRoute != null &&
        routeFilter(previousRoute) &&
        routeFilter(route)) {
      _sendScreenView(previousRoute);
    }
  }
}

class AmbilyticsSession {
  AmbilyticsSession(this.measutementId, this.apiSecret, this.userId,
      [this.useValidationServer = false]) {
    _sessionId = sessionStarted.toIso8601String();
  }

  final String measutementId;
  final String apiSecret;
  final String userId;

  final DateTime sessionStarted = DateTime.now().toUtc();
  String get sessionId => _sessionId;
  String _sessionId = '';

  // https://developers.google.com/analytics/devguides/collection/protocol/ga4/validating-events?client_type=gtag
  final bool useValidationServer;

  /// Sends an event to the analytics service.
  /// If platform is Android, iOS, macOS, or Web, Firebase Analytics will be used.
  /// Otherwise, GA4 Measurement protocol and custom events will be used.
  /// [eventName] is the name of the event. Max length is 40 characters.
  /// [params] is a Map of additional parameters to attach to the event.
  void sendEvent(String eventName, Map<String, Object?>? params) {
    // TODO, check what happens in prod if requirements are not met
    assert(!reservedGa4Events.contains(eventName));
    assert(eventName.length <= 40);
    assert(
        eventName.isNotEmpty &&
            RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(eventName),
        'Event name should start with a letter and contain only letters, numbers, and underscores.');

    Map<String, Object?>? defParams = {
      'engagement_time_msec':
          DateTime.now().toUtc().difference(sessionStarted).inMilliseconds,
      'session_id': sessionId,
    };
    if (params != null) {
      defParams.addAll(params);
    }

    var body = jsonEncode({
      'client_id': defaultTargetPlatform.name,
      'user_id': userId,
      'events': [
        {'name': eventName, 'params': defParams}
      ]
    });

    // TODO, resolve CORS issues
    // for the timebeing Web client is started with browser having CORS disabled via terminal command:
    // flutter run -d chrome --web-browser-flag "--disable-web-security"

    var headers = {
      'Content-Type': 'application/json',
    };

    //if (window.locales.isNotEmpty) {
    headers['Accept-Language'] =
        PlatformDispatcher.instance.locale.toLanguageTag();
    //}

    http.post(
      Uri.parse(
          'https://www.google-analytics.com/${useValidationServer ? 'debug/' : ''}mp/collect?measurement_id=$measutementId&api_secret=$apiSecret'),
      headers: headers,
      body: body,
    );
  }
}

abstract class PredefinedEvents {
  static const appLaunch = "app_launch";
  static const screenViewCust = "screen_view_cust";
}

/// [GA4] Automatically collected events, they are forbidden for use
/// https://support.google.com/analytics/answer/9234069
const Set<String> reservedGa4Events = {
  'ad_activeview',
  'ad_click',
  'ad_exposure',
  'ad_impression',
  'ad_query',
  'ad_reward',
  'adunit_exposure',
  'app_background',
  'app_clear_data',
  'app_exception',
  'app_remove',
  'app_store_refund',
  'app_store_subscription_cancel',
  'app_store_subscription_convert',
  'app_store_subscription_renew',
  'app_uninstall',
  'app_update',
  'app_upgrade',
  'click',
  'dynamic_link_app_open',
  'dynamic_link_app_update',
  'dynamic_link_first_open',
  'error',
  'file_download',
  'firebase_campaign',
  'firebase_in_app_message_action',
  'firebase_in_app_message_dismiss',
  'firebase_in_app_message_impression',
  'first_open',
  'first_visit',
  'form_start',
  'form_submit',
  'in_app_purchase',
  'notification_dismiss',
  'notification_foreground',
  'notification_open',
  'notification_receive',
  'os_update',
  'page_view',
  'screen_view',
  'scroll',
  'session_start',
  'session_start_with_rollout',
  'user_engagement',
  'video_complete',
  'video_progress',
  'video_start',
  'view_search_results'
};