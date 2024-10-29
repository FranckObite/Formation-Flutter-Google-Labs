import 'package:admobtest/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  RequestConfiguration requestConfiguration = RequestConfiguration(
      testDeviceIds: [
        '05d5468c-8a90-4034-a13b-5876c3275a6a',
        '7a188f19-1e47-45dc-9826-92f2009ceb34'
      ]);

  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}


//You can see ads hete showing but taking time to load because of internet
//this is will only shows ads testing purpose and if love on production  then ads will also show on all devices
