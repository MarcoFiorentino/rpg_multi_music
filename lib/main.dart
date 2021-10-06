import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'files_provider.dart';
import 'music_page.dart';
import 'settings_page.dart';

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

    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);
    filesProvider.getFilesList();

    return MaterialApp(
      title: 'Music Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Gestisco le tab dell'app
      home: DefaultTabController(
        // length: 3,
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Music Handler'),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
            // bottom: TabBar(
            //   tabs: [
            //     Tab(
            //       icon: Icon(Icons.queue_music_outlined),
            //       text: 'Musica',
            //     ),
            //     // Tab(
            //     //   icon: Icon(Icons.flash_on_outlined),
            //     //   text: 'Generatori',
            //     // ),
            //     // Tab(
            //     //   icon: Icon(Icons.alarm_on_outlined),
            //     //   text: 'Iniziativa',
            //     // ),
            //   ],
            // ),
          ),
          body: TabBarView(
            children: [
              MusicPage(),
              // Container(color: Colors.green),
              // Container(color: Colors.red),
              // GeneratorPage(),
              // InitiativePage(),
            ],
          ),
        ),
      ),
    );
  }
}
