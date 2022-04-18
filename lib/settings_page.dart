import 'package:flutter/material.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:music_handler/string_extension.dart';
import 'package:provider/provider.dart';

import 'package:music_handler/files_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {

  FilesProvider filesProvider;

  List<String> languages = [];

  List<String> settings = [
    "en", // Lingua di default
    "true" // Schermo sempre attivo di default
  ];

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);

    languages = filesProvider.languages;

    return Scaffold(
      appBar: AppBar(title: Text(filesProvider.translations[0]["settings"])),
      body: buildSettings(context),
    );
  }

  Widget buildSettings(BuildContext context) {
    if (filesProvider.settings.length > 0) {
      settings = filesProvider.settings;
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
                filesProvider.translations[0]["language"] + " :",
                style: TextStyle(fontSize: 20),
              ),
              DropdownButton<String>(
                value: settings[0],
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black, fontSize: 18),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String data) {
                  setState(() {
                    settings[0] = data;
                    SharedPreferencesManager.updateKV("Settings", true, settings);
                    filesProvider.getSettings();
                  });
                },
                items: languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(filesProvider.translations[0]["screen_always_on"]),
              Switch(
                value: settings[1].toBoolean(),
                onChanged: (value) {
                  setState(() {
                    settings[1] = value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, settings);
                    filesProvider.getSettings();
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: Text(filesProvider.translations[0]["signal_bug_request_feature"]),
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Text(
                  filesProvider.translations[0]["click_here"],
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () async => await canLaunch("https://docs.google.com/forms/d/157plh_pe5kAZxtOqZdbcnqFMjr-uagaaqKPa_szpP-c/edit?usp=sharing")
                    ? await launch("https://docs.google.com/forms/d/157plh_pe5kAZxtOqZdbcnqFMjr-uagaaqKPa_szpP-c/edit?usp=sharing")
                    : throw filesProvider.translations[0]["url_error"],
              ),
            ],
          )
        ],
      ),
    );
  }
}