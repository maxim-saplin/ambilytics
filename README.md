Enable Google Analytics for all Flutter platforms: Android, iOS, macOS, Web + Windows and Linux.

As of now Firebase analytics Flutter plugin from Google team only supports 4 platforms (Android, iOS, macOS and Web) - this is due to Google Analytics 4 (GA4) fully supports only those platforms. For Windows and Linux there's no out of the box support.

*Ambylitics* Flutter plugin solves the issue by enabling GA4 Measurement Protocol for unsupported platforms (Windows and Linux) and creating a unified interface that abstracts away interaction with 2 different analytics backends:
- Firebase analytics
- GA4 Measurement protocol

This way no matter the platform you target with you project by configuring Google Analytics console,importing the package, and setting navigation observer you get the capability to send app start and screen view events, as well as send any custom events.

# Features

# Challenges

# Configuring Analytics

# Using reports