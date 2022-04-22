import 'package:flutter/material.dart';
import 'package:multi_music_handler/settings_page.dart';
import 'package:multi_music_handler/sliding_image.dart';
import 'package:provider/provider.dart';

import 'files_provider.dart';
import 'music_page.dart';

void main() => runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: false);
    filesProvider.getFilesList();
    filesProvider.getSettings();
    filesProvider.getLanguages(context);

    return MaterialApp(
      title: 'Multi music Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  int _screenCount = 1;
  ImageProvider _image;

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<double>(0);
    _image = Image.asset(
        "assets/mappa.jpg",
        // height: MediaQuery.of(context).size.height,
        // fit: BoxFit.fitHeight
    ).image;
    // _image = NetworkImage(
    //     "https://w.wallhaven.cc/full/r2/wallhaven-r276qj.png");
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      //Gestisco le tab dell`app
      home: Scaffold(
        appBar: AppBar(
          title: Text("Multi music handler"),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_rounded),
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
            AnimatedBuilder(
              animation: _notifier,
              builder: (context, _) {
                // return Transform.translate(
                //   offset: Offset(-_notifier.value, 0),
                //   child: Image.asset(
                //       "assets/mappa.jpg",
                //       height: MediaQuery.of(context).size.height,
                //       fit: BoxFit.fitHeight
                //   ),
                // );
                return Container(
                  child: SlidingImage(
                    notifier: _notifier,
                    screenCount: _screenCount,
                    image: _image,
                  )
                );
              },
            ),
            MusicPage(
              notifier: _notifier,
            ),
          ],
        ),
        // body: Container(
        //   child: MusicPage(),
        //   decoration: BoxDecoration(
        //     image: DecorationImage (
        //       image: AssetImage("assets/app-background.png"),
        //       opacity: 0.7,
        //       fit: BoxFit.fitHeight,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
