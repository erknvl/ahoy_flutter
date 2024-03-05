# Flutter Ahoy

A straightforward and efficient first party analytics and visit tracking library, designed to seamlessly integrate with your Rails [Ahoy](http://github.com/ankane/ahoy) backend highly inspired by [Ahoy iOS Library](https://github.com/namolnad/ahoy-ios).

## Key Features

- 🌖 Comprehensive user visit tracking
- 📥 Attribution of visits through UTM & referrer parameters
- 📆 Easy-to-use, in-house event tracking

## Getting Started
****
To integrate Flutter Ahoy into your project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
 flutter_ahoy: ^latest_version
```

Replace `latest_version` with the most recent version of the package.

## How to Use

To begin using Flutter Ahoy, you'll need to create an instance of the Ahoy client. This requires a configuration object that includes a `baseUrl` and an `ApplicationEnvironment` object.

```dart
import 'package:flutter_ahoy/flutter_ahoy.dart';

final ahoy = Ahoy(
 configuration: AhoyConfiguration(
    environment: ApplicationEnvironment(
      platform: Platform.operatingSystem,
      appVersion: "1.0.2",
      osVersion: Platform.operatingSystemVersion,
    ),
    baseUrl: "https://your-server.com",
 ),
);
```

### Configuration Options

The configuration object offers sensible defaults, but you can customize various settings:

- visitDuration _(30 minutes)_
- urlRequestHandler _(`Client()`)_
- Routing
 - ahoyPath _("ahoy")_
 - visitsPath _("visits")_
 - eventsPath _("events")_

For additional customization, you can provide your own `AhoyTokenManager` and `RequestInterceptor`s during initialization.

### Tracking Visits

To track a visit, initialize your Ahoy client and then call the `trackVisit` method. This is typically done at the application's startup.

```dart
ahoy.trackVisit().then((visit) => print(visit));
```

### Sending Events

Once a visit is successfully tracked, you can start sending events to your server.

```dart
// For batch event tracking, use the `trackEvents` function
var eventsToSend = [
 Event(name: "ride_details.update_driver_rating", properties: {"driver_id": 4}),
 Event(name: "ride_details.increase_tip", properties: {"driver_id": 4}),
];

ahoy.trackEvents(eventsToSend).then((_) => eventsToSend.clear());

// For individual event tracking, use the `trackEvent` method
ahoy.trackEvent("ride_details.update_driver_rating", properties: {"driver_id": 4});

// If an event doesn't require properties, you can omit them
ahoy.trackEvent("ride_details.update_driver_rating");
```

### Additional Features

You can access the current visit directly through the `currentVisit` property of your Ahoy client. Additionally, the `headers` property allows you to include `Ahoy-Visitor` and `Ahoy-Visit` tokens in your requests as needed.
