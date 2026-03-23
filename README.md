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
      url: https://github.com/your-username/flutter-ad-mob.git
      ref: main
```

*(Note: Replace `your-username` with your actual GitHub username, and `flutter-ad-mob` with the repository name you use when pushing this project to GitHub.)*

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

### 1. Initialization
In your `main.dart`, initialize the SDK before calling `runApp`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_ad_mob/flutter_ad_mob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterAdMobManager.initialize();
  runApp(const MyApp());
}
```

### 2. Banner Ads
Use the `AdMobBanner` widget anywhere in your widget tree:
```dart
AdMobBanner(
  adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
  adSize: AdSize.banner, // Optional: defaults to standard banner
  placeholderWidget: const SizedBox.shrink(), // Shown before the ad loads
)
```

### 3. Interstitial Ads
Load the ad before showing it (e.g., in `initState` or before a transition):
```dart
// Load
FlutterAdMobManager.loadInterstitialAd(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Interstitial ID
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
  adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test Rewarded ID
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
  adUnitId: 'ca-app-pub-3940256099942544/9257395921', // Test App Open ID
);

// Show (e.g., in AppLifecycleState.resumed event)
FlutterAdMobManager.showAppOpenAd(
  onAdDismissed: () {
    print("App Open ad dismissed. Proceed to app usage.");
  },
);
```
