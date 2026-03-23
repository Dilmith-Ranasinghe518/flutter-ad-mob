import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A simple singleton-like manager for Google Mobile Ads
/// to easily load and show Interstitial and Rewarded ads.
class FlutterAdMobManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd;

  static bool _isInterstitialAdLoading = false;
  static bool _isRewardedAdLoading = false;
  static bool _isAppOpenAdLoading = false;

  /// Call this in `main()` before `runApp()`
  /// ensuring `WidgetsFlutterBinding.ensureInitialized()` has been called.
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Load an Interstitial Ad.
  /// Call this ahead of time (e.g. `initState` or right after previous ad completes)
  static void loadInterstitialAd({required String adUnitId}) {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          debugPrint('FlutterAdMobManager: InterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
          debugPrint('FlutterAdMobManager: InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the loaded Interstitial Ad.
  /// Takes an optional callback [onAdDismissed] that is triggered when the user 
  /// closes the ad, or immediately if the ad wasn't loaded.
  static void showInterstitialAd({void Function()? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show interstitial ad before it was loaded.');
      onAdDismissed?.call();
      return;
    }
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('FlutterAdMobManager: InterstitialAd showed.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        debugPrint('FlutterAdMobManager: InterstitialAd dismissed.');
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        debugPrint('FlutterAdMobManager: InterstitialAd failed to show: $error');
        onAdDismissed?.call();
      },
    );
    
    _interstitialAd!.show();
  }

  /// Load a Rewarded Ad.
  /// Call this ahead of time (e.g. `initState` or right after previous ad completes)
  static void loadRewardedAd({required String adUnitId}) {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          debugPrint('FlutterAdMobManager: RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          _rewardedAd = null;
          debugPrint('FlutterAdMobManager: RewardedAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the loaded Rewarded Ad.
  /// [onUserEarnedReward] is called when the user earns the reward.
  /// [onAdDismissed] is called when the ad is closed (optional).
  static void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    void Function()? onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show rewarded ad before it was loaded.');
      onAdDismissed?.call();
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('FlutterAdMobManager: RewardedAd showed.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        debugPrint('FlutterAdMobManager: RewardedAd dismissed.');
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        debugPrint('FlutterAdMobManager: RewardedAd failed to show: $error');
        onAdDismissed?.call();
      },
    );
    
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('FlutterAdMobManager: User earned reward: ${reward.amount}');
      onUserEarnedReward(reward);
    });
  }

  /// Load an App Open Ad.
  /// Call this when the app starts or is resumed.
  static void loadAppOpenAd({required String adUnitId}) {
    if (_isAppOpenAdLoading || _appOpenAd != null) return;
    _isAppOpenAdLoading = true;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          debugPrint('FlutterAdMobManager: AppOpenAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdLoading = false;
          _appOpenAd = null;
          debugPrint('FlutterAdMobManager: AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the loaded App Open Ad.
  /// Typically called when the app life cycle state changes to resumed.
  /// Takes an optional callback [onAdDismissed].
  static void showAppOpenAd({void Function()? onAdDismissed}) {
    if (_appOpenAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show App Open ad before it was loaded.');
      onAdDismissed?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('FlutterAdMobManager: AppOpenAd showed.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        debugPrint('FlutterAdMobManager: AppOpenAd dismissed.');
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        debugPrint('FlutterAdMobManager: AppOpenAd failed to show: $error');
        onAdDismissed?.call();
      },
    );

    _appOpenAd!.show();
  }
}
