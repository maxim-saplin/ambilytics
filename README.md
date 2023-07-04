# Ambilytics

Enable Google Analytics for all Flutter platforms: Android, iOS, macOS, Web, Windows, and Linux.

As of now, the Firebase Analytics Flutter plugin from the Google team only supports 4 platforms (Android, iOS, macOS, and Web) due to Google Analytics 4 (GA4) fully supporting only those platforms. For Windows and Linux, there's no out-of-the-box support.

*Ambilytics* Flutter plugin solves this issue by enabling GA4 Measurement Protocol for unsupported platforms (Windows and Linux) and creating a unified interface that abstracts away interaction with 2 different analytics backends:
- Firebase Analytics
- GA4 Measurement Protocol

This way, no matter the platform you target with your project, by configuring Google Analytics console, importing the package, and setting navigation observer, you get the capability to send app start and screen view events, as well as send any custom events.

## Features

- Unified analytics interface for all Flutter platforms
- Automatic app start and screen view event tracking
- Custom event tracking support
- Configurable navigation observer for easy integration
- Seamless interaction with Firebase Analytics and GA4 Measurement Protocol

## Challenges

- Limited standard reports in GA4 for unsupported platforms
- No automatic geo, demographic, and language data collection for Measurement Protocol

## Configuring Analytics

1. Set up Google Analytics console and create a new GA4 property.
2. Create a new Firebase project and link it to your GA4 property.
3. Add Firebase Analytics for Android, iOS, macOS, and Web platforms.
4. Configure GA4 Measurement Protocol for Windows and Linux platforms.
5. Add the *Ambilytics* Flutter package to your project.
6. Set up the Ambilytics navigation observer in your Flutter project.

## Using Reports

1. Access Google Analytics console to view reports for each platform.
2. Use custom dimensions to differentiate events by platform (Android, Linux, etc.) in GA4 reports.
3. Customize your reports to display custom events and event parameters.
4. Utilize Realtime view to monitor custom event parameters.

## Example

Check out the `example` folder for a counter app that demonstrates how to use the Ambilytics plugin.

## Documentation

For detailed usage instructions and configuration options, please refer to the full documentation.

## Contributing

We welcome contributions to improve Ambilytics! Feel free to open issues, submit pull requests, or provide feedback.

## License

This project is licensed under the [MIT License](LICENSE).
