# IDWise Uni-App Sample

This is a sample uni-app project demonstrating the integration of the IDWise SDK native plugin for iOS.

## Overview

This project showcases how to integrate and use the IDWise uni plugin for identity verification and document scanning in a uni-app application. The plugin provides seamless access to IDWise's powerful verification capabilities within the uni-app framework.

## Features

- **SDK Initialization**: Initialize the IDWise SDK with custom theme support
- **Journey Management**: Start and resume verification journeys
- **Device Status**: Check if a device is blocked from verification
- **Event Handling**: Complete callback system for all journey events
- **Theme Support**: System default, light, and dark theme options

## Plugin Information

- **Plugin Name**: idwise-uni-plugin
- **Version**: 6.1.1
- **Platform**: iOS (Android support coming soon)

## Prerequisites

Before running this project, ensure you have:

- **HBuilderX**: Download from [https://www.dcloud.io/hbuilderx.html](https://www.dcloud.io/hbuilderx.html)
  - Use the App Development Edition
  - Version 3.1.0 or higher
- **macOS**: Required for iOS development
- **Xcode**: Latest version recommended
- **IDWise Credentials**:
  - Client Key (obtain from IDWise dashboard)
  - Flow ID (configure in IDWise dashboard)

## Project Structure

```
IDWisePluginTest/
├── nativeplugins/
│   └── idwise-uni-plugin/          # IDWise native plugin
│       ├── ios/                     # iOS implementation
│       │   ├── IDWiseSDK.framework
│       │   ├── ShieldPtr.framework
│       │   ├── FingerprintPro.framework
│       │   ├── IDWiseModule.h
│       │   ├── IDWiseModule.m
│       │   ├── IDWiseSDKBridge.swift
│       │   └── ...
│       └── package.json
├── pages/
│   └── idwise/
│       └── idwise.vue              # Main test page
├── manifest.json                    # App configuration
├── pages.json                       # Page routing
└── App.vue
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/idwise/idwise-uniapp-sample.git
cd idwise-uniapp-sample
```

### 2. Open in HBuilderX

1. Open HBuilderX
2. File → Open Directory → Select the cloned project folder
3. Wait for project to load

### 3. Configure Your Credentials

Open `pages/idwise/idwise.vue` and update with your credentials, or enter them in the app UI:

- **Client Key**: Your IDWise client key from the dashboard
- **Flow ID**: Your configured flow ID

## Running the Project

### iOS Simulator/Device

1. In HBuilderX, click **Run** → **Run to Phone or Emulator** → **iOS Simulator**
2. Or click **Run** → **Run to Phone or Emulator** → **iOS Device** (requires Apple Developer account)

### Custom Base Package

For native plugin support, you may need to create a custom base package:

1. In HBuilderX, click **Run** → **Cloud Packaging** → **Custom Base Package**
2. Select iOS platform
3. Wait for packaging to complete
4. Run the app using the custom base package

## Usage

### Basic Usage

```javascript
// Load the plugin
this.IDWise = uni.requireNativePlugin('idwise-uni-plugin');

// Initialize SDK
this.IDWise.initialize({
  clientKey: 'YOUR_CLIENT_KEY',
  theme: 'system_default'
}, (result) => {
  if (result.success) {
    console.log('SDK initialized');
  }
});

// Start a journey
this.IDWise.startJourney({
  flowId: 'YOUR_FLOW_ID',
  referenceNumber: 'optional-reference',
  locale: 'en'
}, (event) => {
  console.log('Journey event:', event);
});
```

### Available Methods

- `initialize(options, callback)` - Initialize the SDK
- `startJourney(options, callback)` - Start a new verification journey
- `resumeJourney(options, callback)` - Resume an existing journey
- `isDeviceBlocked()` - Check if device is blocked

### Journey Events

- `onJourneyStarted` - Journey has started successfully
- `onJourneyResumed` - Journey has been resumed
- `onJourneyCompleted` - Journey completed (check `isSuccessful` flag)
- `onJourneyCancelled` - Journey was cancelled by user or system
- `onJourneyBlocked` - Journey blocked due to security/compliance reasons
- `onError` - An error occurred during the journey

## Configuration

### manifest.json

The `manifest.json` file contains important configuration for the plugin:

```json
{
  "app-plus": {
    "modules": {
      "idwise-uni-plugin": {}
    },
    "nativePlugins": {
      "idwise-uni-plugin": { ... }
    },
    "distribute": {
      "ios": {
        "privacyDescription": {
          "NSCameraUsageDescription": "Camera is required for document scanning and selfie verification",
          "NSLocationWhenInUseUsageDescription": "Location is used for fraud prevention and security",
          "NFCReaderUsageDescription": "NFC is required to read passport chip data for verification"
        }
      }
    }
  }
}
```

## Documentation

For complete documentation on using the IDWise uni plugin, see the [Installation and Usage Guide](https://github.com/idwise/idwise-uniapp-sample/blob/main/INSTALLATION_GUIDE.md).

## Troubleshooting

### Plugin Not Loading

If the plugin returns `null` or `undefined`:

1. Verify the plugin folder is in `nativeplugins/idwise-uni-plugin`
2. Check `manifest.json` has the correct module and nativePlugins configuration
3. Clean build and rebuild the project in HBuilderX
4. Create a custom base package via cloud packaging

### Camera Permission Issues

Ensure the following is in your `manifest.json`:

```json
"ios": {
  "privacyDescription": {
    "NSCameraUsageDescription": "Camera is required for document scanning and selfie verification"
  }
}
```

### Build Errors

1. Verify all framework files are present in the `ios` folder
2. Clean derived data in Xcode
3. Ensure Xcode version is up to date
4. Check that frameworks are properly embedded in `package.json`

## Support

For questions and support:

- **IDWise Documentation**: Contact your IDWise account manager
- **uni-app Documentation**: [https://uniapp.dcloud.io](https://uniapp.dcloud.io)
- **Issues**: [GitHub Issues](https://github.com/idwise/idwise-uniapp-sample/issues)

## License

This sample project is provided for demonstration purposes. The IDWise SDK is subject to the terms of your IDWise license agreement.

## Version

- **App Version**: 1.0.0
- **Plugin Version**: 6.1.1
- **Last Updated**: 2026-02-02

---

**IDWise** - Intelligent Identity Verification
