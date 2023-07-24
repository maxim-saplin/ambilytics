Enable Google Analytics for **all** Flutter platforms: Android, iOS, macOS, Web, Windows, and Linux.

As of now, the Firebase Analytics Flutter plugin (from Google team) works with 4 platforms (Android, iOS, macOS, and Web). This is due to Google Analytics 4 (GA4) limitations. For Windows and Linux, there's no out-of-the-box support.

*Ambilytics* Flutter plugin solves this issue by enabling GA4 Measurement Protocol for unsupported platforms (Windows and Linux) and creating a unified interface that abstracts away interaction with 2 different analytics backends:
- Google/Firebase Analytics
    - You enable and configure it for any of the required platforms (Android, iOS, macOS, Web)
    - *Note:* as of July 2023 macOS is in Beta and may be displayed as iOS platform in Firebase/Google Analytics consoles, choose proper Data Stream name for it in GA console
- GA4 Measurement Protocol
    - You create a separate Web stream to track events sent from Windows/Linux

This way, no matter the platform you target with your Flutter project. By creating Firebase project, configuring Google Analytics property, importing the package, and setting navigation observer, you get the capability to send `app_start` and `screen_view` events, as well as send any custom events.

# Features

- Unified analytics interface for all Flutter platforms
- Seamless interaction with Firebase Analytics and GA4 Measurement Protocol
- Automatic app start and screen view event tracking
    - `app_start` custom event is sent during initialization, `platform` parameter contains name of the platform
    - When `AmbyliticsObserver` is configured `screen_view` is sent on Firebase platforms along with `screen_view_cust` via Measurement Protocol (either for all platforms or only Windows/Linux, configurable)
- Custom event tracking
- Configurable navigation observer for easy integration

Check `/example` folder for usage detail.

# Challenges

- Limited standard reports in GA4 for unsupported platforms
    - You might need to create custom dimensions and customize standard reports
- Measurement protocol doesn't support sending standard events, e.g. instead if `screen_view` events sent via Firebase, a custom event `screen_view_cust` is sent (with screen name param). 
    - This make standard Events report not useful for all 6 platforms. Yet the package allowed sending both events, which make it possible to create a custom report that can track screen views across all platforms.
- No automatic geo, demographic, and language data collection for Measurement Protocol

# Configuring Analytics

Historically Firebase Analytics was used for app analytics and Google Analytics for web. Now they are closely integrated products and used together. In order to proceed you'll need a Google Account. Using this account you will set-up a project in Firebase Console which will be linked to a property in Google Analytics. All reports will be available in Google Analytics Console.

Bellow you can find detailed instruction for 2 scenarios:
1. Adding analytics from scratch
2. Adding it to existing Flutter app


## a) Setup from scratch

The below instructions are based on this manual: https://firebase.google.com/docs/flutter/setup?platform=ios

### Prepare command-line tools
1. Install the Firebase CLI (https://firebase.google.com/docs/cli#setup_update_cli)
2. Log into Firebase using your Google account by running the following command:
```bash
firebase login
```
- you can logout via `logut` command and than repeat the `login` command to change the account
3. Install the FlutterFire CLI by running the following command from any directory:
```bash
dart pub global activate flutterfire_cli
```
- you might need to add the cli to path, e.g. `export PATH="$PATH":"$HOME/.pub-cache/bin"` for macOS

### Configure Firebase/Google Analytics for each target platform
1. In terminal change directory to your Flutter project
2. Run Firebase core initialization script
```bash
flutterfire configure
```
3. Use the generated `firebase_options.dart` to initialize `Ambylitics` (see below) 
4. Open Firebase Console (https://console.firebase.google.com/) and choose used above project. Click `Analytics->Dashboard` tab to the left, click `Enable Google Analytics` button. You will be presented with a wizard that will link Google Analytics account to Firebase project. At the last step `Add the Google Analytics SDK` just click `Finish` button as `flutterfire configure` command above has already taken care of that.

At this point you have Firebase/Google Analytics setup for 4 platforms (Android, iOS, macOS and web). Next you need to configure Measurement Protocol to cover Windows and Linux and start using Ambylitics in your Dart code and start sending events.

**Notes:**
- Running the command will show the list of existing Firebase projects to choose one OR will suggest to create a new project.
- Firebase Analytics requires native projects to be configured. I.e. various plists for macOS/iOS, google-services.json for Android etc. The above command takes care of that
- Each time a new platform is added to Flutter app you need to rerun the above command
- App ID, API keys etc. will be saved to a newly created `firebase_options.dart` file
- This step only covers Android, iOS, macOS and Web platforms
- You can have each platform configured individually/manually without any CLI (e.g. follow the instructions from Firebase console)
- You can even skip Firebase set-up and have all 6 platforms using Measurement Protocol (assuming the limitations mentioned above)

Here's an example for `flutterfire configure` output:
```bash
user@users-MacBook-Pro example % flutterfire configure
i Found 4 Firebase projects.                                                                                                                             
✔ Select a Firebase project to configure your Flutter application with · <create a new project>                                                          
✔ Enter a project id for your new Firebase project (e.g. my-cool-project) · ambilytics-example                                                           
i New Firebase project ambilytics-example created successfully.                                                                                          
✔ Which platforms should your configuration support (use arrow keys & space to select)? · ios, macos, web, android                                       
i Firebase android app com.example.example is not registered on Firebase project ambilytics-example.                                                     
i Registered a new Firebase android app on Firebase project ambilytics-example.                                                                          
i Firebase ios app com.example.example is not registered on Firebase project ambilytics-example.                                                         
i Registered a new Firebase ios app on Firebase project ambilytics-example.                                                                              
i Firebase macos app com.example.example.RunnerTests is not registered on Firebase project ambilytics-example.                                           
i Registered a new Firebase macos app on Firebase project ambilytics-example.                                                                            
i Firebase web app ambilytics_example (web) is not registered on Firebase project ambilytics-example.                                                    
i Registered a new Firebase web app on Firebase project ambilytics-example.                                                                              
? The files android/build.gradle & android/app/build.gradle will be updated to apply Firebase configuration and gradle build plugins. Do you want to cont
✔ The files android/build.gradle & android/app/build.gradle will be updated to apply Firebase configuration and gradle build plugins. Do you want to continue? · yes 

Firebase configuration file lib/firebase_options.dart generated successfully with the following Firebase apps:

Platform  Firebase App Id
web       1:777853418226:web:69da4a4f2a495cbc99cdeb
android   1:777853418226:android:d5ffad29eb40783199cdeb
ios       1:777853418226:ios:5e6533e94fef227899cdeb
macos     1:777853418226:ios:e32e65cdbc373d6599cdeb

Learn more about using this file and next steps from the documentation:
 > https://firebase.google.com/docs/flutter/setup
```

### Measurement Protocol 


## b) Adding to Flutter app already using Firebase Analytics

# Using Ambilytics in your app

1. Add `firebase_core` and `ambilytics` packages to `dependencies` section of `pubspec.yaml`:
```yaml
dependencies:
dependencies:
  flutter:
    sdk: flutter  
  cupertino_icons: ^1.0.2
  firebase_core:
  ambilytics:
    path: ../
```
2. Import Ambylitics:
```dart
import 'package:ambilytics/ambilytics.dart' as ambilytics;
```
3. In the `main` function add initialization call:
```dart
void main() async {
  // This one
  await ambilytics.initAnalytics(firebaseOptions: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```
- it's assumed that you have `firebase_options.dart` generated by `flutterfire` (see above)
4. If you want to track navigation events, add navigator observer to `MaterialApp`, e.g.:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Here
      navigatorObservers: ambilytics.isAmbyliticsInitialized
          ? [
              ambilytics.AmbyliticsObserver(
                  routeFilter: ambilytics.anyRouteFilter,
                  alwaySendScreenViewCust: true)
            ]
          : [],
      routes: {
        '/': (context) => HomeScreen(
              title: 'Home',
              analyticsError: ambilytics.initError,
            ),
        '/color/red': (context) => const ColorScreen(),
        '/color/yellow': (context) => const ColorScreen()
      },
    );
  }
}
```
5. You can send custom events via Ambilytics `sendEvent` function:
```dart
  void _incrementCounter() {
    setState(() {
      _counter++;
      // Here
      ambylitics.sendEvent(counterClicked, null);
    });
  }
```

# Using Reports

The reports can be see in both Google Analytics Console (https://analytics.google.com) and Firebase Console (https://console.firebase.google.com/). They are same.

1. Access Google Analytics console to view reports for each platform.
2. Use custom dimensions to differentiate events by platform (Android, Linux, etc.) in GA4 reports.
3. Customize your reports to display custom events and event parameters.
4. Utilize Realtime view to monitor custom event parameters.

# Known issues/Troubleshooting

## 1. Can't build macOS/iOS project with 'Error run pod install' or alike
In terminal go t macOS or iOS folder, remove `Podfile.lock` and run `pod repo update`

## 2. Android build fails (:app:mapReleaseSourceSetPaths)
If you get error 
```
Execution failed for task ':app:mapReleaseSourceSetPaths'.
> Error while evaluating property 'extraGeneratedResDir' of task ':app:mapReleaseSourceSetPaths'
```

Go to `android/build.gradle` and update `com.google.gms:google-services` version, e.g.:
```gradle
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        // START: FlutterFire Configuration
        classpath 'com.google.gms:google-services:4.3.15'
        // END: FlutterFire Configuration
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
```

## 3. Android build fails (minSdkVersion mismatch)
Go to `android/app/build.gradle` and change `minSdkVersion` version from `flutter.minSdkVersion` to `19`.

## 4. No data in Google Analytics reports
All reports outside `Realtime` can take up to a day to be in sync

## 4. No data in Realtime reports (on Android, iOS, macOS)
For mobile platforms (Android, iOS) Firebase Analytics uploads/processes data in batches, i.e. it takes some time to collect and than send and display it (presumably for battery saving). As a result you get jagged events (i.e. some come right away, some take time).