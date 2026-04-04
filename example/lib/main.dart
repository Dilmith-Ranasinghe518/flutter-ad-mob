import 'package:flutter/material.dart';
import 'package:flutter_ad_mob/flutter_ad_mob.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize and automatically start preloading ads!
  await FlutterAdMobManager.initialize(
    environment: AdEnvironment.hybrid,
    interstitialAdUnitId: Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/1033173712' 
        : 'ca-app-pub-3940256099942544/4411468910',
    rewardedAdUnitId: Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/5224354917' 
        : 'ca-app-pub-3940256099942544/1712480198',
    rewardedInterstitialAdUnitId: Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/5354046379' 
        : 'ca-app-pub-3940256099942544/6978759866',
    appOpenAdUnitId: Platform.isAndroid 
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
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    // Wait for 3 seconds to let ads load.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // Show the App Open Ad.
    final didShow = FlutterAdMobManager.showAppOpenAd(
      onAdDismissed: () {
        // Navigate to the next screen after the ad is dismissed.
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const AdTestScreen())
          );
        }
      }
    );

    // If the ad doesn't show (e.g. not loaded), navigate anyway.
    if (!didShow) {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const AdTestScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text('Flutter AdMob Loading...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class AdTestScreen extends StatefulWidget {
  const AdTestScreen({super.key});

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> { // Removed WidgetsBindingObserver

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
                final didShow = FlutterAdMobManager.showInterstitialAd();
                if (!didShow) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Interstitial Ad is still loading... please wait!')),
                  );
                }
              },
              child: const Text('Show Interstitial Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final didShow = FlutterAdMobManager.showRewardedAd(
                  onUserEarnedReward: (reward) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Received ${reward.amount} ${reward.type}')),
                    );
                  }
                );
                if (!didShow) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rewarded Ad is still loading a video... please wait!')),
                  );
                }
              },
              child: const Text('Show Rewarded Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final didShow = FlutterAdMobManager.showRewardedInterstitialAd(
                  onUserEarnedReward: (reward) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rewarded Interstitial: Received ${reward.amount} ${reward.type}')),
                    );
                  }
                );
                if (!didShow) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rewarded Interstitial Ad is still loading...')),
                  );
                }
              },
              child: const Text('Show Rewarded Interstitial Ad'),
            ),
            ElevatedButton(
              onPressed: () {
                final didShow = FlutterAdMobManager.showAppOpenAd();
                if (!didShow) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App Open Ad is still loading...')),
                  );
                }
              },
              child: const Text('Show App Open Ad (Manual trigger)'),
            ),
            const SizedBox(height: 30),
            const Text('Native Ad (Small):'),
            AdMobNative(
              adUnitId: Platform.isAndroid 
                ? 'ca-app-pub-3940256099942544/2247696110' 
                : 'ca-app-pub-3940256099942544/3986624511',
              templateType: TemplateType.small,
            ),
            const SizedBox(height: 30),
            const Text('Native Ad (Medium):'),
            AdMobNative(
              adUnitId: Platform.isAndroid 
                ? 'ca-app-pub-3940256099942544/2247696110' 
                : 'ca-app-pub-3940256099942544/3986624511',
              templateType: TemplateType.medium,
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
