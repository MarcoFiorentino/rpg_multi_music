import 'dart:io';

import 'globals.dart';

import 'package:flutter/material.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {
  Globals _globals = Globals();
  Directory selectedLocalDirectory;
  Directory selectedExternalDirectory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings UI')),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {

    void toggleSwitch(bool value) {

      if(_globals.useExternalMemory == false)
      {
        setState(() {
          _globals.useExternalMemory = true;
        });
      }
      else
      {
        setState(() {
          _globals.useExternalMemory = false;
        });
      }

      _globals.getFilesList();
    }

    Future<void> _pickDirectory(BuildContext context, bool external) async {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root;
      Directory directory;
      if (external) {
        root = storageInfo[1].rootDir; //storageInfo[1] for SD card, getting the root directory
        directory = selectedExternalDirectory;
      } else {
        root = storageInfo[0].rootDir; //storageInfo[1] for SD card, getting the root directory
        directory = selectedLocalDirectory;
      }

      if (directory == null) {
        directory = Directory(root);
      }

      Directory newDirectory = await FolderPicker.pick(
          allowFolderCreation: true,
          context: context,
          rootDirectory: directory,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))
      );

      setState(() {
        if (external) {
          selectedExternalDirectory = newDirectory;
        } else {
          selectedLocalDirectory = newDirectory;
        }
        print(newDirectory);
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Memoria da usare:',
            style: TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Locale',
                style: TextStyle(fontSize: 20),
              ),
              Switch(
                onChanged: toggleSwitch,
                value: _globals.useExternalMemory,
                activeColor: Colors.blue,
                activeTrackColor: Colors.yellow,
                inactiveThumbColor: Colors.redAccent,
                inactiveTrackColor: Colors.orange,
              ),
              Text(
                'Esterna',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Locale: ',
                style: TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  _pickDirectory(context, false);
                },
              ),
              selectedLocalDirectory != null ? Text("${selectedLocalDirectory.path}") : Container(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esterna: ',
                style: TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  _pickDirectory(context, true);
                },
              ),
              selectedExternalDirectory != null ? Text("${selectedExternalDirectory.path}") : Container(),
            ],
          ),
        ],
      ),
    );
  }
}