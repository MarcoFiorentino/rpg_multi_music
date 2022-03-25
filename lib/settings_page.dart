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
  final ScrollController scrollController = ScrollController();
  FilesProvider provider;
  int numDir = 1;
  List<Color> colors = [];

  Future<void> _pickDirectory(BuildContext context, bool external, String dirName, int rowIndex) async {

    String dirPath = await FilePicker.platform.getDirectoryPath();

    setState(() {
      if (dirPath.isNotEmpty) {
        SharedPreferencesManager.saveKV(dirName, dirPath);
        SharedPreferencesManager.saveDirList(dirName, rowIndex);
      }
    });
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
    provider = Provider.of<FilesProvider>(context, listen: false);
    if (numDir < provider.directories.length) {
      numDir = provider.directories.length;
    }

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
                  'Number of directories: ',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  child: Text("-"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(20, 20)),
                  onPressed: () {
                    changeNumDir(-1);
                  },
                ),
                Text(
                  numDir.toString(),
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  child: Text("+"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(20, 20)),
                  onPressed: () {
                    changeNumDir(1);
                  },
                )
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
          ],
        ),
    );
  }

  void changeNumDir(int val) {
    setState(() {
      numDir += val;
      if(numDir < 1) {
        numDir = 1;
      }
    });
  }

  // Creo una riga di pulsanti per le musiche
  Row buildMusicRow(BuildContext context, int rowIndex) {
    var dirName = "Directory"+rowIndex.toString();
    if (colors.length < rowIndex + 1) {
      colors.add(Colors.green);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
              SharedPreferencesManager.saveColorsList(newColor.value.toString(), rowIndex);
              provider.getColors();
            });
          },
          /// long press to open, another behaviour is clickToOpen to open
          behaviour: ButtonBehaviour.clickToOpen,
          /// initial color
          defaultColor: colors[rowIndex],
          /// fanLikeAnimationConfig is a preset, you can import this from the package
          animationConfig: fanLikeAnimationConfig,
          /// simpleColors is a preset, you can import this from the package
          colorList: defaultAvailableColors,
          /// size of the clickable button in the middle
          buttonSize: 30,
          /// height of each piece (outerRadius - innerRadius of a piece)
          pieceHeight: 25,
          /// starting radius of the donut shaped wheel
          innerRadius: 30,
        )
      ],
    );
  }
}
