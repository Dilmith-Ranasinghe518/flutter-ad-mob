# flutter_ad_mob

A generic Flutter package that wraps Google Mobile Ads for minimum coding and easy reuse across your Flutter apps.

## Installation

Add this package to your Flutter app using Git in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Optionally include google_mobile_ads in your host app if you need more advanced control
  # Otherwise, this package provides it transitively.
  flutter_ad_mob:
    git:
      url: https://github.com/Dilmith-Ranasinghe518/flutter-ad-mob.git
      ref: main
```

*(Note: Make sure to fetch the latest changes if you have other contributors.)*

## Required App Configuration

Because Google Mobile Ads requires application-level configurations, you **must** configure your Android and iOS applications before utilizing this package.

### Android
Update your `android/app/src/main/AndroidManifest.xml` with your AdMob App ID:
```xml
<manifest>
    <application>
        <!-- Sample AdMob App ID: ca-app-pub-3940256099942544~3347511713 -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

### iOS
Update your `ios/Runner/Info.plist` with your AdMob App ID:
```xml
<key>GADApplicationIdentifier</key>
<!-- Sample AdMob App ID: ca-app-pub-3940256099942544~1458002511 -->
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

## Usage

### 1. Initialization and Environment Mode
In your `main.dart`, initialize the SDK before calling `runApp`. You can precisely control when ads are shown using the `AdEnvironment` enum:

- `AdEnvironment.enable`: Shows real/live ads using the IDs you provide.
- `AdEnvironment.disable`: Disables ads completely (won't load or show).
- `AdEnvironment.hybrid` **(Default)**: Shows live ads in release mode, and perfectly falls back to Google's standard Test Ad IDs when debugging!

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ad_mob/flutter_ad_mob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set your AdEnvironment here!
  await FlutterAdMobManager.initialize(
    environment: AdEnvironment.hybrid, 
  );
  
  runApp(const MyApp());
}
```

Since the library intelligently falls back to Test Ads using `AdEnvironment.hybrid`, you should simply pass your **Live Ad Unit IDs** everywhere in your app, and forget about the boilerplate logic.

### 2. Banner Ads
Use the `AdMobBanner` widget anywhere in your widget tree:
```dart
AdMobBanner(
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // Your LIVE Banner ID
  adSize: AdSize.banner, // Optional: defaults to standard banner
  placeholderWidget: const SizedBox.shrink(), // Shown before the ad loads
)
```

### 3. Interstitial Ads
Load the ad before showing it (e.g., in `initState` or before a transition):
```dart
// Load
FlutterAdMobManager.loadInterstitialAd(
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // Your LIVE Interstitial ID
);

// Show later
FlutterAdMobManager.showInterstitialAd(
  onAdDismissed: () {
    print("Ad dismissed. Move to next screen!");
  },
);
```

### 4. Rewarded Ads
Like Interstitial ads, load them ahead of time:
```dart
// Load
FlutterAdMobManager.loadRewardedAd(
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // Your LIVE Rewarded ID
);

// Show later
FlutterAdMobManager.showRewardedAd(
  onUserEarnedReward: (RewardItem reward) {
    print("User earned ${reward.amount} of ${reward.type}");
  },
  onAdDismissed: () {
    print("Rewarded ad dismissed.");
  },
);
```

### 5. App Open Ads
Load them ahead of time (e.g., when the app launches):
```dart
// Load
FlutterAdMobManager.loadAppOpenAd(
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // Your LIVE App Open ID
);

// Show (e.g., in AppLifecycleState.resumed event)
FlutterAdMobManager.showAppOpenAd(
  onAdDismissed: () {
    print("App Open ad dismissed. Proceed to app usage.");
  },
);
```
