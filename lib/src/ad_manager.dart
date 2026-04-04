import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_environment.dart';

/// A simple singleton-like manager for Google Mobile Ads
/// to easily load and show Interstitial and Rewarded ads.
class FlutterAdMobManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static AppOpenAd? _appOpenAd;

  static AdEnvironment _environment = AdEnvironment.hybrid;
  static AdEnvironment get environment => _environment;

  static String? _interstitialAdUnitId;
  static String? _rewardedAdUnitId;
  static String? _rewardedInterstitialAdUnitId;
  static String? _appOpenAdUnitId;

  static bool _isInterstitialAdLoading = false;
  static bool _isRewardedAdLoading = false;
  static bool _isRewardedInterstitialAdLoading = false;
  static bool _isAppOpenAdLoading = false;
  static bool _isShowingAd = false;
  static DateTime? _lastAdDismissedTimestamp;

  /// Returns [true] if any full-screen ad is currently being displayed.
  static bool get isShowingAd => _isShowingAd;

  /// Call this in `main()` before `runApp()`
  /// ensuring `WidgetsFlutterBinding.ensureInitialized()` has been called.
  /// You can provide your Live Ad Unit IDs here to automatically preload and cache them!
  static Future<void> initialize({
    AdEnvironment environment = AdEnvironment.hybrid,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
    String? rewardedInterstitialAdUnitId,
    String? appOpenAdUnitId,
  }) async {
    _environment = environment;
    if (_environment != AdEnvironment.disable) {
      await MobileAds.instance.initialize();
      
      if (interstitialAdUnitId != null) loadInterstitialAd(adUnitId: interstitialAdUnitId);
      if (rewardedAdUnitId != null) loadRewardedAd(adUnitId: rewardedAdUnitId);
      if (rewardedInterstitialAdUnitId != null) loadRewardedInterstitialAd(adUnitId: rewardedInterstitialAdUnitId);
      if (appOpenAdUnitId != null) loadAppOpenAd(adUnitId: appOpenAdUnitId);
    }
  }

  /// Helper to determine which Ad Unit ID to use based on the environment.
  static String? getEffectiveAdUnitId(String providedAdUnitId, String testAndroidId, String testIosId) {
    if (_environment == AdEnvironment.disable) return null;
    if (_environment == AdEnvironment.enable) return providedAdUnitId;
    // AdEnvironment.hybrid
    return kReleaseMode ? providedAdUnitId : (Platform.isAndroid ? testAndroidId : testIosId);
  }

  /// Load an Interstitial Ad.
  /// Call this ahead of time. Once loaded and shown, it will automatically reload itself.
  static void loadInterstitialAd({required String adUnitId}) {
    _interstitialAdUnitId = adUnitId;
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    
    final effectiveId = getEffectiveAdUnitId(
      adUnitId, 
      'ca-app-pub-3940256099942544/1033173712', 
      'ca-app-pub-3940256099942544/4411468910',
    );
    if (effectiveId == null) return;

    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: effectiveId,
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
  /// Returns [true] if the ad was successfully shown, [false] if it wasn't loaded yet.
  /// Takes an optional callback [onAdDismissed] that is triggered when the user 
  /// closes the ad.
  static bool showInterstitialAd({void Function()? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show interstitial ad before it was loaded.');
      if (!_isInterstitialAdLoading && _interstitialAdUnitId != null) {
        // Retry loading if it had failed previously!
        loadInterstitialAd(adUnitId: _interstitialAdUnitId!);
      }
      return false;
    }
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('FlutterAdMobManager: InterstitialAd showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: InterstitialAd dismissed.');
        onAdDismissed?.call();
        if (_interstitialAdUnitId != null) {
          loadInterstitialAd(adUnitId: _interstitialAdUnitId!);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: InterstitialAd failed to show: $error');
        onAdDismissed?.call();
        if (_interstitialAdUnitId != null) {
          loadInterstitialAd(adUnitId: _interstitialAdUnitId!);
        }
      },
    );
    
    _interstitialAd!.show();
    return true;
  }

  /// Load a Rewarded Ad.
  /// Call this ahead of time. Once loaded and shown, it will automatically reload itself.
  static void loadRewardedAd({required String adUnitId}) {
    _rewardedAdUnitId = adUnitId;
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    
    final effectiveId = getEffectiveAdUnitId(
      adUnitId, 
      'ca-app-pub-3940256099942544/5224354917', 
      'ca-app-pub-3940256099942544/1712480198',
    );
    if (effectiveId == null) return;

    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: effectiveId,
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
  /// Returns [true] if the ad was successfully shown, [false] if it wasn't loaded yet.
  /// [onUserEarnedReward] is called when the user earns the reward.
  /// [onAdDismissed] is called when the ad is closed (optional).
  static bool showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    void Function()? onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show rewarded ad before it was loaded.');
      if (!_isRewardedAdLoading && _rewardedAdUnitId != null) {
        // Retry loading if it had failed previously!
        loadRewardedAd(adUnitId: _rewardedAdUnitId!);
      }
      return false;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('FlutterAdMobManager: RewardedAd showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: RewardedAd dismissed.');
        onAdDismissed?.call();
        if (_rewardedAdUnitId != null) {
          loadRewardedAd(adUnitId: _rewardedAdUnitId!);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: RewardedAd failed to show: $error');
        onAdDismissed?.call();
        if (_rewardedAdUnitId != null) {
          loadRewardedAd(adUnitId: _rewardedAdUnitId!);
        }
      },
    );
    
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('FlutterAdMobManager: User earned reward: ${reward.amount}');
      onUserEarnedReward(reward);
    });
    return true;
  }

  /// Load a Rewarded Interstitial Ad.
  /// Call this ahead of time. Once loaded and shown, it will automatically reload itself.
  static void loadRewardedInterstitialAd({required String adUnitId}) {
    _rewardedInterstitialAdUnitId = adUnitId;
    if (_isRewardedInterstitialAdLoading || _rewardedInterstitialAd != null) return;
    
    final effectiveId = getEffectiveAdUnitId(
      adUnitId, 
      'ca-app-pub-3940256099942544/5354046379', 
      'ca-app-pub-3940256099942544/6978759866',
    );
    if (effectiveId == null) return;

    _isRewardedInterstitialAdLoading = true;
    RewardedInterstitialAd.load(
      adUnitId: effectiveId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialAdLoading = false;
          debugPrint('FlutterAdMobManager: RewardedInterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isRewardedInterstitialAdLoading = false;
          _rewardedInterstitialAd = null;
          debugPrint('FlutterAdMobManager: RewardedInterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the loaded Rewarded Interstitial Ad.
  /// Returns [true] if the ad was successfully shown, [false] if it wasn't loaded yet.
  /// [onUserEarnedReward] is called when the user earns the reward.
  /// [onAdDismissed] is called when the ad is closed (optional).
  static bool showRewardedInterstitialAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    void Function()? onAdDismissed,
  }) {
    if (_rewardedInterstitialAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show rewarded interstitial ad before it was loaded.');
      if (!_isRewardedInterstitialAdLoading && _rewardedInterstitialAdUnitId != null) {
        // Retry loading if it had failed previously!
        loadRewardedInterstitialAd(adUnitId: _rewardedInterstitialAdUnitId!);
      }
      return false;
    }
    
    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('FlutterAdMobManager: RewardedInterstitialAd showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: RewardedInterstitialAd dismissed.');
        onAdDismissed?.call();
        if (_rewardedInterstitialAdUnitId != null) {
          loadRewardedInterstitialAd(adUnitId: _rewardedInterstitialAdUnitId!);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: RewardedInterstitialAd failed to show: $error');
        onAdDismissed?.call();
        if (_rewardedInterstitialAdUnitId != null) {
          loadRewardedInterstitialAd(adUnitId: _rewardedInterstitialAdUnitId!);
        }
      },
    );
    
    _rewardedInterstitialAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('FlutterAdMobManager: User earned reward: ${reward.amount}');
      onUserEarnedReward(reward);
    });
    return true;
  }

  /// Load an App Open Ad.
  /// Call this when the app starts. Once loaded and shown, it will automatically reload itself.
  static void loadAppOpenAd({required String adUnitId}) {
    _appOpenAdUnitId = adUnitId;
    if (_isAppOpenAdLoading || _appOpenAd != null) return;
    
    final effectiveId = getEffectiveAdUnitId(
      adUnitId, 
      'ca-app-pub-3940256099942544/9257395921', 
      'ca-app-pub-3940256099942544/5575463023',
    );
    if (effectiveId == null) return;

    _isAppOpenAdLoading = true;

    AppOpenAd.load(
      adUnitId: effectiveId,
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
  /// Returns [true] if the ad was successfully shown, [false] if it wasn't loaded yet.
  /// Typically called when the app life cycle state changes to resumed.
  /// Takes an optional callback [onAdDismissed].
  static bool showAppOpenAd({void Function()? onAdDismissed}) {
    if (_appOpenAd == null) {
      debugPrint('FlutterAdMobManager: Attempt to show App Open ad before it was loaded.');
      if (!_isAppOpenAdLoading && _appOpenAdUnitId != null) {
        // Retry loading if it had failed previously!
        loadAppOpenAd(adUnitId: _appOpenAdUnitId!);
      }
      return false;
    }

    // Don't show if another ad is currently showing or was just dismissed (cooldown)
    if (_isShowingAd || (_lastAdDismissedTimestamp != null && DateTime.now().difference(_lastAdDismissedTimestamp!) < const Duration(seconds: 1))) {
      debugPrint('FlutterAdMobManager: AppOpenAd skipped because another ad is active or recently dismissed.');
      return false;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('FlutterAdMobManager: AppOpenAd showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: AppOpenAd dismissed.');
        onAdDismissed?.call();
        if (_appOpenAdUnitId != null) {
          loadAppOpenAd(adUnitId: _appOpenAdUnitId!);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        _lastAdDismissedTimestamp = DateTime.now();
        debugPrint('FlutterAdMobManager: AppOpenAd failed to show: $error');
        onAdDismissed?.call();
        if (_appOpenAdUnitId != null) {
          loadAppOpenAd(adUnitId: _appOpenAdUnitId!);
        }
      },
    );

    _appOpenAd!.show();
    return true;
  }
}
