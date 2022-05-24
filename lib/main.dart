import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdr_multi_music/settings_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'ad_helper.dart';
import 'files_provider.dart';
import 'music_page.dart';

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
    filesProvider.getTranslations();
    filesProvider.getLanguages();
    filesProvider.getBackgroundImages();

    return MaterialApp(
      title: 'Multi music Handler',
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
        backgroundColor: Color(int.parse(filesProvider.settings[5])),
        appBar: AppBar(
          backgroundColor: Color(int.parse(filesProvider.settings[2])),
          title: Text(
              "Multi music handler",
              style: TextStyle(color: Color(int.parse(filesProvider.settings[3]))),
          ),
          actions: [
            IconButton(
              icon: Icon(
                  Icons.settings_rounded,
                  color: Color(int.parse(filesProvider.settings[3])),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            (filesProvider.settings[4] == "none") ?
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
                        filesProvider.settings[4],
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fitHeight
                      ),
                    );
                  },
                ),
              ),
            MusicPage(
              notifier: _notifier,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 50,
          color: Color(int.parse(filesProvider.settings[2])),
          child: adWidget
        ),
      ),
    );
  }
}
