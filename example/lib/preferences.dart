import 'package:ambilytics/ambilytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShareAnalyticsPreference extends StatefulWidget {
  const ShareAnalyticsPreference({super.key});

  @override
  ShareAnalyticsPreferenceState createState() =>
      ShareAnalyticsPreferenceState();
}

class ShareAnalyticsPreferenceState extends State<ShareAnalyticsPreference> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    getShareAnalyticsPreference().then((value) {
      _disableAnalytics(value);
    });
  }

  void _disableAnalytics(bool value) {
    setState(() {
      _isChecked = value;
      isAmbilyticsDisabled = !_isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) {
            _disableAnalytics(value ?? false);
            saveShareAnalyticsPreference(_isChecked);
          },
        ),
        const Text("share analytics"),
      ],
    );
  }
}

const String _key = 'shareAnalytics';

Future<void> saveShareAnalyticsPreference(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_key, value);
}

Future<bool> getShareAnalyticsPreference() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_key) ?? true;
}
