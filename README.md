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

*🔥 **Smart Auto-Preloading:** By providing your Ad Unit IDs during initialization, the package automatically pre-caches ads in the background. Once an ad is shown and dismissed, it intelligently prepares the next one without any code!*

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ad_mob/flutter_ad_mob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set your AdEnvironment here and seamlessly preload your ads!
  await FlutterAdMobManager.initialize(
    environment: AdEnvironment.hybrid, 
    interstitialAdUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy', // Your LIVE Interstitial ID
    rewardedAdUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',     // Your LIVE Rewarded ID
    appOpenAdUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',      // Your LIVE App Open ID
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
Because of **Smart Auto-Preloading**, you don't need to manually load ads! Just call `show` anywhere:
```dart
bool didShow = FlutterAdMobManager.showInterstitialAd();
if (!didShow) {
  print("Ad is still loading in the background. Please wait!");
}
```

### 4. Rewarded Ads
```dart
bool didShow = FlutterAdMobManager.showRewardedAd(
  onUserEarnedReward: (RewardItem reward) {
    print("User earned ${reward.amount} of ${reward.type}");
  },
);
if (!didShow) {
  print("Rewarded video is still downloading... Please wait!");
}
```

### 5. App Open Ads
```dart
// Show (e.g., in AppLifecycleState.resumed event)
bool didShow = FlutterAdMobManager.showAppOpenAd();
if (!didShow) {
  print("App Open ad is still loading!");
}
```
