import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';

/// A ready-to-use Flutter widget to display a generic Banner Ad.
/// Simply instantiate it with your `adUnitId`.
class AdMobBanner extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;
  final Widget? placeholderWidget;

  const AdMobBanner({
    super.key,
    required this.adUnitId,
    this.adSize = AdSize.banner,
    this.placeholderWidget,
  });

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final effectiveId = FlutterAdMobManager.getEffectiveAdUnitId(
      widget.adUnitId, 
      'ca-app-pub-3940256099942544/6300978111', 
      'ca-app-pub-3940256099942544/2934735716',
    );

    if (effectiveId == null) return;

    _bannerAd = BannerAd(
      adUnitId: effectiveId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMobBanner: BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return the placeholder or shrink if not loaded yet
    return widget.placeholderWidget ?? const SizedBox.shrink();
  }
}
