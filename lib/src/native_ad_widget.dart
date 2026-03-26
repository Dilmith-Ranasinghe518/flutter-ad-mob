import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';

/// A reusable widget for displaying Native Ads (Small and Medium).
class AdMobNative extends StatefulWidget {
  final String adUnitId;
  final TemplateType templateType;
  final double? height;
  final double? width;
  final void Function(Ad ad)? onAdLoaded;
  final void Function(Ad ad, LoadAdError error)? onAdFailedToLoad;

  const AdMobNative({
    super.key,
    required this.adUnitId,
    this.templateType = TemplateType.small,
    this.height,
    this.width,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdMobNative> createState() => _AdMobNativeState();
}

class _AdMobNativeState extends State<AdMobNative> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final effectiveId = FlutterAdMobManager.getEffectiveAdUnitId(
      widget.adUnitId,
      'ca-app-pub-3940256099942544/2247696110', // Test Android Native
      'ca-app-pub-3940256099942544/3986624511', // Test iOS Native
    );

    if (effectiveId == null) return;

    _nativeAd = NativeAd(
      adUnitId: effectiveId,
      factoryId: 'adFactoryExample', // This is ignored when using templateStyle
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
          widget.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.onAdFailedToLoad?.call(ad, error);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return SizedBox(
        height: widget.height ?? (widget.templateType == TemplateType.small ? 90 : 320),
        width: widget.width ?? double.infinity,
      );
    }

    return SizedBox(
      height: widget.height ?? (widget.templateType == TemplateType.small ? 90 : 320),
      width: widget.width ?? double.infinity,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
