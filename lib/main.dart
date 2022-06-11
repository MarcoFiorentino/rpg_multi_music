import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:gdr_multi_music/settings_page.dart';
import 'package:gdr_multi_music/ad_helper.dart';
import 'package:gdr_multi_music/files_provider.dart';
import 'package:gdr_multi_music/music_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: false);
    filesProvider.getFilesList();
    filesProvider.getSettings();
    filesProvider.getBackgroundImages();

    return MaterialApp(
      title: 'Multi music Handler',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  ValueNotifier<double> _notifier;

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _notifier = ValueNotifier<double>(0);
    AdHelper.homeBanner.load();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);
    final AdWidget adWidget = AdWidget(ad: AdHelper.homeBanner);

    return MaterialApp(
      //Gestisco le tab dell`app
      home: Scaffold(
        backgroundColor: Color(int.parse(filesProvider.settings[4])),
        appBar: AppBar(
          backgroundColor: Color(int.parse(filesProvider.settings[1])),
          title: Text(
              "Multi music handler",
              style: TextStyle(color: Color(int.parse(filesProvider.settings[2]))),
          ),
          actions: [
            IconButton(
              icon: Icon(
                  Icons.settings_rounded,
                  color: Color(int.parse(filesProvider.settings[2])),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(loc: AppLocalizations.of(context))),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            (filesProvider.settings[3] == "assets/Background/None.jpg") ?
              SizedBox.shrink() :
              OverflowBox(
                maxWidth: MediaQuery.of(context).size.width * 10,
                alignment: Alignment.topLeft,
                child: AnimatedBuilder(
                  animation: _notifier,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(-_notifier.value, 0),
                      child: Image.asset(
                        filesProvider.settings[3],
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fitHeight
                      ),
                    );
                  },
                ),
              ),
            MusicPage(
              notifier: _notifier,
              loc: AppLocalizations.of(context)
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 50,
          color: Color(int.parse(filesProvider.settings[1])),
          child: adWidget
        ),
      ),
    );
  }
}
