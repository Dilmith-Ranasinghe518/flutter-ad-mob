import 'package:flutter/material.dart';
import 'package:flutter_ad_mob/flutter_ad_mob.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterAdMobManager.initialize();

  // Load App Open Ad on launch
  FlutterAdMobManager.loadAppOpenAd(
    adUnitId: Platform.isAndroid 
      ? 'ca-app-pub-3940256099942544/9257395921' 
      : 'ca-app-pub-3940256099942544/5575463023',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AdMob Package Test',
      home: AdTestScreen(),
    );
  }
}

class AdTestScreen extends StatefulWidget {
  const AdTestScreen({super.key});

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAds();
  }

  void _loadAds() {
    FlutterAdMobManager.loadInterstitialAd(
      adUnitId: Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/1033173712' 
        : 'ca-app-pub-3940256099942544/4411468910',
    );
    FlutterAdMobManager.loadRewardedAd(
      adUnitId: Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/5224354917' 
        : 'ca-app-pub-3940256099942544/1712480198',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAdMobManager.showAppOpenAd(
        onAdDismissed: () {
          // Preload next app open ad
          FlutterAdMobManager.loadAppOpenAd(
            adUnitId: Platform.isAndroid 
              ? 'ca-app-pub-3940256099942544/9257395921' 
              : 'ca-app-pub-3940256099942544/5575463023',
          );
        }
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Test App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                FlutterAdMobManager.showInterstitialAd(
                  onAdDismissed: () {
                    // Reload for next time
                    _loadAds();
                  }
                );
              },
              child: const Text('Show Interstitial Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FlutterAdMobManager.showRewardedAd(
                  onUserEarnedReward: (reward) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Received ${reward.amount} ${reward.type}')),
                    );
                  },
                  onAdDismissed: () {
                    // Reload for next time
                    _loadAds();
                  }
                );
              },
              child: const Text('Show Rewarded Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FlutterAdMobManager.showAppOpenAd(
                  onAdDismissed: () {
                    // Preload next app open ad
                    FlutterAdMobManager.loadAppOpenAd(
                      adUnitId: Platform.isAndroid 
                        ? 'ca-app-pub-3940256099942544/9257395921' 
                        : 'ca-app-pub-3940256099942544/5575463023',
                    );
                  }
                );
              },
              child: const Text('Show App Open Ad (Manual trigger)'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdMobBanner(
        adUnitId: Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/6300978111' 
          : 'ca-app-pub-3940256099942544/2934735716',
      ),
    );
  }
}
