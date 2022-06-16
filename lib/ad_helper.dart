import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static BannerAd homeBanner = BannerAd(
    adUnitId: 'ca-app-pub-5556746391287393/8462929248',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  static BannerAd settingsBanner = BannerAd(
    adUnitId: 'ca-app-pub-5556746391287393/1331115504',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
}