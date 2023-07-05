Enable Google Analytics for all Flutter platforms: Android, iOS, macOS, Web, Windows, and Linux.

As of now, the Firebase Analytics Flutter plugin (from Google team) works with 4 platforms (Android, iOS, macOS, and Web). This is due to Google Analytics 4 (GA4) limitations. For Windows and Linux, there's no out-of-the-box support.

*Ambilytics* Flutter plugin solves this issue by enabling GA4 Measurement Protocol for unsupported platforms (Windows and Linux) and creating a unified interface that abstracts away interaction with 2 different analytics backends:
- Firebase Analytics
    - You enable and configure it for any of the required platforms (Android, iOS, macOS, Web)
    - *Note:* as of July 2023 macOS is in Beta and may be displayed as iOS platfroms when dealing with Firebase/Google Analytics consoles, just choose proper Data Stream name for it in GA console
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

1. Set up Google Analytics console and create a new GA4 property.
2. Create a new Firebase project and link it to your GA4 property.
3. Add Firebase Analytics for Android, iOS, macOS, and Web platforms.
4. Configure GA4 Measurement Protocol for Windows and Linux platforms.
5. Add the *Ambilytics* Flutter package to your project.
6. Set up the Ambilytics navigation observer in your Flutter project.

# Using Reports

1. Access Google Analytics console to view reports for each platform.
2. Use custom dimensions to differentiate events by platform (Android, Linux, etc.) in GA4 reports.
3. Customize your reports to display custom events and event parameters.
4. Utilize Realtime view to monitor custom event parameters.

# Contributing

We welcome contributions to improve Ambilytics! Feel free to open issues, submit pull requests, or provide feedback.