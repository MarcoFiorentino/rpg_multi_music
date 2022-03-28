import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_color_picker_wheel/flutter_color_picker_wheel.dart';

import 'package:music_handler/files_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {
  // Variabili condivise
  final ScrollController scrollController = ScrollController();
  FilesProvider provider;
  int numDir = 1;
  List<String> colors = [];

  // Alla selezione di una directory salvo la coppia nome-path ed il nome della directory nella lista
  Future<void> _pickDirectory(BuildContext context, bool external, String dirName, int rowIndex) async {

    String dirPath = await FilePicker.platform.getDirectoryPath();

    setState(() {
      if (dirPath.isNotEmpty) {
        SharedPreferencesManager.saveKV(dirName, dirPath, true);
        SharedPreferencesManager.saveDirList(dirName, rowIndex, true);
        SharedPreferencesManager.saveColorsList("0xFF009000", rowIndex, true);
      }
    });

    //Aggiorno l'elenco di directory e file
    provider.getFilesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings UI')),
      body: buildSettingsList(context),
    );
  }

  Widget buildSettingsList(BuildContext context) {
    provider = Provider.of<FilesProvider>(context, listen: true);
    // Recupero il numero di directory salvate ed i colori per andare a costruire l'interfaccia
    if (numDir < provider.directories.length) {
      numDir = provider.directories.length;
    }
    colors = provider.colors;

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Directories: ',
                  style: TextStyle(fontSize: 20),
                ),
              ]
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: numDir,
                itemBuilder: (BuildContext context, int rowIndex) {
                  return buildMusicRow(context, rowIndex);
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
            ElevatedButton(
              child: Text("+"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: Color(int.parse("0xFF009000")), fixedSize: Size(20, 20)),
              onPressed: () {
                setState(() {
                  numDir += 1;
                });
              },
            )
          ],
        ),
    );
  }

  // Elimino una directory salvata
  void deleteDir(String dirName, int rowIndex) {
    if (provider.directories.length > rowIndex) {
      SharedPreferencesManager.saveKV(dirName, "", false);
      SharedPreferencesManager.saveDirList("", rowIndex, false);
      SharedPreferencesManager.saveColorsList("", rowIndex, false);

      //Aggiorno l'elenco di directory e file
      provider.removeFromDirs(dirName);
      provider.getFilesList();
    }
  }

  // Creo una riga di pulsanti per le musiche
  Row buildMusicRow(BuildContext context, int rowIndex) {
    var dirName = "Directory"+rowIndex.toString();
    if (colors.length < rowIndex + 1) {
      colors.add("0xFF009000");
    }

    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Directory ' + (rowIndex+1).toString() +': ',
          style: TextStyle(fontSize: 20),
        ),
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () {
            _pickDirectory(context, false, dirName, rowIndex);
          },
        ),
        Flexible(
          flex: 2,
          child: provider.directories[dirName] != null ? Text(provider.directories[dirName]) : Container(),
        ),
        WheelColorPicker(
          onSelect: (Color newColor) {
            setState(() {
              SharedPreferencesManager.saveColorsList(newColor.value.toString(), rowIndex, true);
              provider.getColors();
            });
          },
          behaviour: ButtonBehaviour.clickToOpen,
          defaultColor: Color(int.parse(colors[rowIndex])),
          animationConfig: fanLikeAnimationConfig,
          colorList: defaultAvailableColors,
          buttonSize: 30,
          pieceHeight: 25,
          innerRadius: 30,
        ),
        ElevatedButton(
          child: Text("X"),
          style: ElevatedButton.styleFrom(elevation: 8.0, primary: Color(int.parse("0xFF009000")), fixedSize: Size(10, 20)),
          onPressed: () {

            deleteDir(dirName, rowIndex);
          },
        )
      ],
    );
  }
}
