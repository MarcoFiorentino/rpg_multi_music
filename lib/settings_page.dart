import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

import 'package:music_handler/files_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings UI')),
      body: buildSettingsList(context),
    );
  }

  Widget buildSettingsList(BuildContext context) {
    final FilesProvider provider = Provider.of<FilesProvider>(context, listen: false);

    void toggleSwitch(bool value) {
      if (provider.useExternalMemory == false) {
        setState(() {
          provider.useExternalMemory = true;
        });
      } else {
        setState(() {
          provider.useExternalMemory = false;
        });
      }

      provider.getFilesList();
    }

    Future<void> _pickDirectory(BuildContext context, bool external) async {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root;
      Directory directory;
      if (external) {
        root = storageInfo[1].rootDir; //storageInfo[1] for SD card, getting the root directory
        directory = provider.selectedExternalDirectory;
      } else {
        root = storageInfo[0].rootDir; //storageInfo[1] for SD card, getting the root directory
        directory = provider.selectedLocalDirectory;
      }

      if (directory == null) {
        directory = Directory(root);
      }

      Directory newDirectory = await FolderPicker.pick(
          allowFolderCreation: true, context: context, rootDirectory: directory, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))));

      setState(() {
        if (external) {
          provider.selectedExternalDirectory = newDirectory;
        } else {
          provider.selectedLocalDirectory = newDirectory;
        }

        provider.getFilesList();
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
                value: provider.useExternalMemory,
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
              provider.selectedLocalDirectory != null ? Text("${provider.selectedLocalDirectory.path}") : Container(),
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
              provider.selectedExternalDirectory != null ? Text("${provider.selectedExternalDirectory.path}") : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
