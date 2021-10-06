import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:provider/provider.dart';

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

    Future<void> _pickDirectory(BuildContext context, bool external, String dir) async {

      String newDirectory = await FilePicker.platform.getDirectoryPath();

      setState(() {
        if (newDirectory.isNotEmpty) {
          SharedPreferencesManager.saveKV(dir, newDirectory);
        }
        provider.getFilesList();
      });
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
                  'First directory: ',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                  _pickDirectory(context, false, SharedPreferencesManager.firstDirectory);
                  },
                ),
                Flexible(
                  flex: 2,
                  child:
                    provider.directories[SharedPreferencesManager.firstDirectory] != null ? Text(provider.directories[SharedPreferencesManager.firstDirectory]) : Container(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Second directory: ',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                    _pickDirectory(context, false, SharedPreferencesManager.secondDirectory);
                  },
                ),
                Flexible(
                  flex: 2,
                  child:
                  provider.directories[SharedPreferencesManager.secondDirectory] != null ? Text(provider.directories[SharedPreferencesManager.secondDirectory]) : Container(),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
