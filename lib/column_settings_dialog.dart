import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/presets/animation_config_presets.dart';
import 'package:flutter_color_picker_wheel/presets/color_presets.dart';
import 'package:flutter_color_picker_wheel/widgets/flutter_color_picker_wheel.dart';
import 'package:multi_music_handler/shared_preferences_manager.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';

import 'files_provider.dart';

class ColumnSettingsDialog extends StatefulWidget {
  ColumnSettingsDialog({this.newCol, this.colIndex});

  final bool newCol;
  final int colIndex;

  @override
  _ColumnSettingsDialogState createState() => _ColumnSettingsDialogState();
}

class _ColumnSettingsDialogState extends State<ColumnSettingsDialog> {
  bool newCol;
  int colIndex;

  String colTitle;
  String directoryId;
  String directoryPath;
  String directoryColor;
  String directoryName;
  String fontColor;

  bool isEditingText = false;
  TextEditingController editingController;
  FilesProvider filesProvider;

  @override
  void initState() {
    super.initState();
    newCol = widget.newCol;
    colIndex = widget.colIndex;

    filesProvider = Provider.of<FilesProvider>(context, listen: false);
    colTitle = filesProvider.translations[0]["new_column"];
    directoryId = nanoid(10);
    directoryPath = filesProvider.translations[0]["directory_path"];
    directoryColor = filesProvider.settings[2];
    directoryName = filesProvider.translations[0]["directory_name"];
    fontColor = "4280361249";

    // Se apro una colonna esistente e non ho fatto modifiche
    // Pre-popolo i campi con i dati in memoria
    if (!newCol) {
      colTitle = filesProvider.translations[0]["edit_column"];
      directoryId = filesProvider.dirsIds[colIndex];
      directoryPath  = filesProvider.dirsPaths[colIndex];
      directoryColor = filesProvider.dirsColors[colIndex];
      directoryName = filesProvider.dirsNames[colIndex];
      fontColor = filesProvider.fontsColors[colIndex];
    }
  }

  @override
  Widget build(BuildContext context) {

    editingController = TextEditingController(text: directoryName);

    return AlertDialog(
      title: Container(
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Text(
          colTitle,
          style: TextStyle(
            fontSize: 20,
            color: Color(int.parse(fontColor)),
          ),
        ),
        decoration: BoxDecoration(
          color: Color(int.parse(directoryColor)),
          image: DecorationImage (
            image: AssetImage("assets/btn-single-border.png"),
            fit: BoxFit.fill,
            centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
          ),
        ),
      ),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.folder_rounded),
                color: Colors.grey,
                onPressed: () {
                  pickDirectory();
                },
              ),
              Flexible(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    pickDirectory();
                  },
                  child: Text(
                    directoryPath,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.color_lens_rounded),
                color: Colors.grey,
                onPressed: () {},
              ),
              // Text(
              //     filesProvider.translations[0]["color"] + ": ",
              //     style: TextStyle(
              //         fontSize: 15
              //     ),
              // ),
              WheelColorPicker(
                onSelect: (Color newColor) {
                  setState(() {
                    directoryColor = newColor.withOpacity(0.85).value.toString();
                  });
                },
                behaviour: ButtonBehaviour.clickToOpen,
                defaultColor: Color(int.parse(directoryColor)),
                animationConfig: fanLikeAnimationConfig,
                colorList: defaultAvailableColors,
                buttonSize: 25,
                pieceHeight: 25,
                innerRadius: 30,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.drive_file_rename_outline),
                color: Colors.grey,
                onPressed: () {},
              ),
              // Text(
              //     filesProvider.translations[0]["name"] + ": ",
              //     style: TextStyle(
              //         fontSize: 15
              //     ),
              // ),
              Flexible(
                flex: 2,
                child: editTitleTextField(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.format_color_text),
                color: Colors.grey,
                onPressed: () {},
              ),
              // Text(
              //   filesProvider.translations[0]["font_color"] + ": ",
              //   style: TextStyle(
              //       fontSize: 15
              //   ),
              // ),
              DropdownButton<String>(
                value: fontColor,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String data) {
                  setState(() {
                    fontColor = data;
                  });
                },
                items: filesProvider.appFontColors.map((String name, String value) {
                  return MapEntry(
                      name,
                      DropdownMenuItem<String>(
                        value: value,
                        child: Text(filesProvider.translations[0][filesProvider.appFontColors.entries.firstWhere((element) => element.value == value).key]),
                      )
                  );
                }).values.toList(),
              ),
            ],
          ),
          newCol? Container() : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //     filesProvider.translations[0]["delete_column"] + ": ",
              //     style: TextStyle(
              //         fontSize: 15
              //     ),
              // ),
              Spacer(),
              ElevatedButton(
                  child: Icon(Icons.delete_rounded),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Color(int.parse(directoryColor)), fixedSize: Size(10, 20)),
                  onPressed: () {
                    // Cancello la directory e chiudo il popup
                    deleteDir();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ],
      ),
      actions: [
        Row (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  // Chiudo il popup
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: Text(filesProvider.translations[0]["abort"]),
              ),
              TextButton(
                onPressed: () {
                  // Salvo la colonna e chiudo il popup
                  saveColumn();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: Text(filesProvider.translations[0]["save"]),
              ),
            ]
        )
      ],
    );
  }

  // Gestisco il directoryPicker
  Future<void> pickDirectory() async {

    String dirPath = await FilePicker.platform.getDirectoryPath();

    setState(() {
      if (dirPath.isNotEmpty) {
        directoryPath = dirPath;
      }
    });
  }

  // Gestisco il campo di testo editabile
  Widget editTitleTextField() {
    if (isEditingText) {
      return Center(
        child: TextField(
          onChanged: (newValue) {
              directoryName = newValue;
          },
          onSubmitted: (newValue) {
            setState(() {
              isEditingText = false;
            });
          },
          autofocus: true,
          controller: editingController,
        ),
      );
    } else {
      return InkWell(
          onTap: () {
            setState(() {
              isEditingText = true;
            });
          },
          child: Text(
            directoryName,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          )
      );
    }
  }

  // Salvo la nuova colonna
  void saveColumn() {
    // Salvo l`id in DirsId
    if (newCol) {
      SharedPreferencesManager.updateDirList(directoryId);
    }

    // Salvo il trittico come lista usando l`id come chiave
    List<String> dirCharacteristics = [directoryPath, directoryColor, directoryName, fontColor];
    SharedPreferencesManager.updateKV(directoryId, true, dirCharacteristics);

    filesProvider.getFilesList();
  }

  // Elimino una directory salvata
  void deleteDir() {
    // Cancello l`id da DirsId
    SharedPreferencesManager.updateDirList(directoryId);

    // Cancello il trittico come lista usando l`id come chiave
    SharedPreferencesManager.updateKV(directoryId, false);

    filesProvider.getFilesList();
  }
}
