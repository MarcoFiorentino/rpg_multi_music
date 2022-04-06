import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/presets/animation_config_presets.dart';
import 'package:flutter_color_picker_wheel/presets/color_presets.dart';
import 'package:flutter_color_picker_wheel/widgets/flutter_color_picker_wheel.dart';
import 'package:nanoid/nanoid.dart';
import 'package:music_handler/shared_preferences_manager.dart';
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
  bool fieldsEdited = false;
  int colIndex;

  String colTitle = "New column";
  String directoryId = nanoid(10);
  String directoryPath = "Directory path";
  String directoryColor = "0xFF009000";
  String directoryName = "Directory name";

  bool isEditingText = false;
  TextEditingController editingController;
  FilesProvider provider;

  @override
  void initState() {
    newCol = widget.newCol;
    colIndex = widget.colIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    provider = Provider.of<FilesProvider>(context, listen: false);
    editingController = TextEditingController(text: directoryName);

    // Se apro una colonna esistente e non ho fatto modifiche
    // Prepopolo i campi con i dati in memoria
    if (!newCol && !fieldsEdited) {
      colTitle = "Edit column";
      directoryId = provider.dirsIds[colIndex];
      directoryPath  = provider.dirsPaths[colIndex];
      directoryColor = provider.dirsColors[colIndex];
      directoryName = provider.dirsNames[colIndex];
    }

    return AlertDialog(
      title: Text(colTitle),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  pickDirectory();
                },
              ),
              Flexible(
                flex: 2,
                child: Text(directoryPath),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Color: "),
              WheelColorPicker(
                onSelect: (Color newColor) {
                  setState(() {
                    directoryColor = newColor.value.toString();
                    fieldsEdited = true;
                  });
                },
                behaviour: ButtonBehaviour.clickToOpen,
                defaultColor: Color(int.parse(directoryColor)),
                animationConfig: fanLikeAnimationConfig,
                colorList: defaultAvailableColors,
                buttonSize: 30,
                pieceHeight: 25,
                innerRadius: 30,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Name: "),
              Flexible(
                flex: 2,
                child: editTitleTextField(),
              ),
            ],
          ),
          newCol? Container() : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Delete Column: "),
              ElevatedButton(
                child: Text("X"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Color(int.parse("0xFF009000")), fixedSize: Size(10, 20)),
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
                child: const Text('Abort'),
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
                child: const Text('Save'),
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
        fieldsEdited = true;
      }
    });
  }

  // Gestisco il campo di testo editabile
  Widget editTitleTextField() {
    if (isEditingText) {
      return Center(
        child: TextField(
          onSubmitted: (newValue) {
            setState(() {
              directoryName = newValue;
              fieldsEdited = true;
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
              fontSize: 18.0,
            ),
          )
      );
    }
  }

  // Salvo la nuova colonna
  void saveColumn() {
    // Salvo l'id in DirsId
    if (newCol) {
      SharedPreferencesManager.updateDirList(directoryId);
    }

    // Salvo il trittico come lista usando l'id come chiave
    List<String> dirCharacteristics = [directoryPath, directoryColor, directoryName];
    SharedPreferencesManager.updateKV(directoryId, true, dirCharacteristics);

    provider.getFilesList();
  }

  // Elimino una directory salvata
  void deleteDir() {
    // Cancello l'id da DirsId
    SharedPreferencesManager.updateDirList(directoryId);

    // Cancello il trittico come lista usando l'id come chiave
    SharedPreferencesManager.updateKV(directoryId, false);

    provider.getFilesList();
  }
}
