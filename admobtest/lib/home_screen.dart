import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd bannerAd;

  bool isBannerAdReady = false;

  late InterstitialAd interstitialAd;

  bool isInterstitialAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: "ca-app-pub-3560714578588021/5377782974",
        listener: BannerAdListener(onAdLoaded: (load) {
          setState(() {
            isBannerAdReady = true;
          });
          print("Banner is loading : $load");
        }, onAdFailedToLoad: (ad, error) {
          isBannerAdReady = false;
          ad.dispose();
          print(
              "====== une exception a été rencontrée lors de l'exécution de Banner: $error ======");
        }),
        request: AdRequest())
      ..load();

    InterstitialAd.load(
        adUnitId: "ca-app-pub-3560714578588021/2751619631",
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          setState(() {
            isInterstitialAdReady = true;
            interstitialAd = ad;
          });
          print("InterstitialAd is loading : $ad");
        }, onAdFailedToLoad: (error) {
          isInterstitialAdReady = false;
        }));
  }

  void showInterstitialAd() {
    if (isInterstitialAdReady) {
      interstitialAd.show();
      interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          setState(() {
            isInterstitialAdReady = false;
          });

          //load new ad

          InterstitialAd.load(
            adUnitId: "ca-app-pub-3940256099942544/2247696110",
            request: AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                setState(() {
                  isInterstitialAdReady = true;
                  interstitialAd = ad;
                });
                print("InterstitialAd is loading : $ad");
              },
              onAdFailedToLoad: (error) {
                isInterstitialAdReady = false;
              },
            ),
          );
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();

          setState(() {
            isInterstitialAdReady = false;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bannerAd.dispose();

    if (isBannerAdReady) {
      interstitialAd.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Ads"),
      ),
      body: Column(
        children: [
          //i am using on this buttong only for testing
          ElevatedButton(
              onPressed: () {
                showInterstitialAd();
              },
              child: Text("Show Interstitial Ad"))
        ],
      ),
      bottomNavigationBar: isBannerAdReady
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(ad: bannerAd),
            )
          : null,
    );
  }
}


//app is completed, both ads added and it will work fine when app is live, but for now i am just testing ads so i will also add my emulator to admob test device
// to show ads for testing purpose.
//o




/* l'application est terminée, les deux annonces ont été ajoutées et cela fonctionnera correctement lorsque l'application sera en ligne, mais pour l'instant, je teste simplement les annonces, je vais donc également ajouter mon émulateur au périphérique de test Admob
pour diffuser des annonces à des fins de test.
sinon, les publicités fonctionnent correctement et fonctionnent également pour les applications en direct et de production. */
