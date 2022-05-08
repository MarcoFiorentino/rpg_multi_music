import 'package:flutter/material.dart';
import 'package:multi_music_handler/settings_page.dart';
import 'package:provider/provider.dart';

import 'files_provider.dart';
import 'music_page.dart';

void main() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);

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
              Container() :
              OverflowBox(
                maxWidth: MediaQuery.of(context).size.width * 4,
                // alignment: Alignment.topLeft, // Se si vuole l'immagine di sfondo che comincia dal bordo sinistro, altrimenti comincia dal centro
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
        // Usabile per la pubblicità?
        // bottomNavigationBar: BottomNavigationBar(
        //   items: <BottomNavigationBarItem>[
        //     new BottomNavigationBarItem(
        //       icon: new Icon(Icons.library_books, size: 22.0),
        //       label: "Text",
        //       backgroundColor: Colors.pink,
        //     ),
        //     new BottomNavigationBarItem(
        //       icon: new Icon(Icons.library_books, size: 22.0),
        //       label: "Text",
        //       backgroundColor: Colors.pink,
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
