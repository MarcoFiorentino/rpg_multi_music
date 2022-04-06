import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    return MaterialApp(
      title: 'Music Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).title),
          ),
          body: TabBarView(
            children: [
              MusicPage(),
            ],
          ),
        ),
      ),
    );
  }
}
